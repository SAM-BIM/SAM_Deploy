# Reporting / PDF payload gate.
#
# SAM Analytical.exe's "Space Assumptions PDF" command (SAM_UI#121) needs, next to the
# executable in the installed %APPDATA%\SAM:
#   - the reporting assemblies from SAM (SAM.Core.Reporting, SAM.Analytical.Reporting,
#     SAM.Core.Reporting.Pdf - the last embeds the Noto Sans fonts);
#   - PDFsharp-MigraDoc 6.2.0 and its Microsoft dependencies. SAM.Core.Reporting.Pdf is a
#     netstandard library, so SAM\build never carries these; only SAM_UI's PackageReference
#     puts them into SAM_UI\build and from there into the payload;
#   - the licences for the embedded font (SIL OFL 1.1) and for PDFsharp/MigraDoc (MIT).
#
# A development machine can hide a gap here (an old %APPDATA%\SAM, a NuGet cache), so this
# checks the STAGED payload itself:
#   1. every required file exists and is non-empty;
#   2. every assembly the reporting assemblies reference, transitively, resolves to a file in
#      the payload root or to the .NET 8 shared runtime SAM Analytical.exe runs on;
#   3. SAM.Core.Reporting.Pdf.dll embeds both Noto Sans faces;
#   4. PdfSharp*/MigraDoc* in the payload root are all PDFsharp-MigraDoc 6.2.0, and no other
#      copy sits anywhere under the payload except the per-Revit-year folders (SAM_Revit's own
#      PDFsharp, a separate deployment path, reported only).
# Exit code 1 on any failure.

param(
    [Parameter(Mandatory = $true)]
    [string]$PayloadRoot,

    # Folder holding Microsoft.NETCore.App and Microsoft.WindowsDesktop.App.
    [string]$SharedRuntimeRoot = (Join-Path $env:ProgramFiles 'dotnet\shared'),

    [string]$ExpectedPdfSharpVersion = '6.2.0'
)

$ErrorActionPreference = 'Stop'

if (-not (Test-Path $PayloadRoot)) { throw "Payload root not found: $PayloadRoot" }
# One DirectoryInfo for every enumeration, so paths compare in one form (no 8.3 vs long-name mismatch).
$payloadDirectory = New-Object System.IO.DirectoryInfo((Resolve-Path $PayloadRoot).Path)
$PayloadRoot = $payloadDirectory.FullName

$failures = New-Object System.Collections.Generic.List[string]
function Fail([string]$message) { $failures.Add($message); Write-Host "FAIL: $message" }

$requiredFiles = @(
    'SAM.Core.Reporting.dll',
    'SAM.Analytical.Reporting.dll',
    'SAM.Core.Reporting.Pdf.dll',
    'PdfSharp.dll',
    'PdfSharp.System.dll',
    'PdfSharp.Shared.dll',
    'PdfSharp.Charting.dll',
    'MigraDoc.DocumentObjectModel.dll',
    'MigraDoc.Rendering.dll',
    'Microsoft.Extensions.Logging.Abstractions.dll',
    'licenses\NotoSans\OFL.txt',
    'licenses\PDFsharp-MigraDoc\LICENSE.txt'
)

Write-Host '--- Required reporting/PDF files ---'
foreach ($relative in $requiredFiles) {
    $path = Join-Path $PayloadRoot $relative
    if (-not (Test-Path $path -PathType Leaf)) { Fail "missing: $relative"; continue }
    $length = (Get-Item $path).Length
    if ($length -le 0) { Fail "empty: $relative"; continue }
    $version = [System.Diagnostics.FileVersionInfo]::GetVersionInfo($path).FileVersion
    Write-Host ("OK   {0,-50} {1,10} bytes  {2}" -f $relative, $length, $version)
}

# --- Assembly metadata (System.Reflection.Metadata under pwsh; reflection-only load under Windows PowerShell)
$useMetadataReader = $PSVersionTable.PSEdition -eq 'Core'
if ($useMetadataReader) { Add-Type -AssemblyName System.Reflection.Metadata }

function Get-AssemblyInfo([string]$path) {
    if ($useMetadataReader) {
        $stream = [System.IO.File]::OpenRead($path)
        try {
            $peReader = New-Object System.Reflection.PortableExecutable.PEReader($stream)
            try {
                if (-not $peReader.HasMetadata) { return $null }
                $reader = [System.Reflection.Metadata.PEReaderExtensions]::GetMetadataReader($peReader)
                $references = foreach ($handle in $reader.AssemblyReferences) {
                    $reader.GetString($reader.GetAssemblyReference($handle).Name)
                }
                $resources = foreach ($handle in $reader.ManifestResources) {
                    $reader.GetString($reader.GetManifestResource($handle).Name)
                }
                return [pscustomobject]@{ References = @($references); Resources = @($resources) }
            }
            finally { $peReader.Dispose() }
        }
        finally { $stream.Dispose() }
    }

    try { $assembly = [System.Reflection.Assembly]::ReflectionOnlyLoadFrom($path) }
    catch { return $null }
    return [pscustomobject]@{
        References = @($assembly.GetReferencedAssemblies() | ForEach-Object { $_.Name })
        Resources  = @($assembly.GetManifestResourceNames())
    }
}

function Get-SharedRuntimeDirectory([string]$framework) {
    $root = Join-Path $SharedRuntimeRoot $framework
    if (-not (Test-Path $root)) { return $null }
    Get-ChildItem $root -Directory | Where-Object { $_.Name -match '^8\.0\.\d+$' } |
        Sort-Object { [version]$_.Name } -Descending | Select-Object -First 1 -ExpandProperty FullName
}

$runtimeDirectories = @(
    (Get-SharedRuntimeDirectory 'Microsoft.NETCore.App'),
    (Get-SharedRuntimeDirectory 'Microsoft.WindowsDesktop.App')
) | Where-Object { $_ }
if ($runtimeDirectories.Count -lt 2) { Fail "the .NET 8 shared runtimes were not found under $SharedRuntimeRoot" }

Write-Host '--- Transitive references of the reporting assemblies ---'
$pending = New-Object System.Collections.Generic.Queue[string]
$visited = @{}
foreach ($root in @('SAM.Core.Reporting', 'SAM.Analytical.Reporting', 'SAM.Core.Reporting.Pdf')) { $pending.Enqueue($root) }

$payloadCount = 0
$runtimeCount = 0
while ($pending.Count -gt 0) {
    $name = $pending.Dequeue()
    if ($visited.ContainsKey($name)) { continue }
    $visited[$name] = $true

    if ($name -in @('netstandard', 'mscorlib')) { $runtimeCount++; continue }

    $payloadPath = Join-Path $PayloadRoot "$name.dll"
    if (Test-Path $payloadPath) {
        $payloadCount++
        $info = Get-AssemblyInfo $payloadPath
        if ($null -eq $info) { Fail "unreadable assembly metadata: $name.dll"; continue }
        foreach ($reference in $info.References) { $pending.Enqueue($reference) }
        continue
    }

    $inRuntime = $false
    foreach ($directory in $runtimeDirectories) {
        if (Test-Path (Join-Path $directory "$name.dll")) { $inRuntime = $true; break }
    }
    if ($inRuntime) { $runtimeCount++ } else { Fail "unresolved reference: $name (not in the payload root or the .NET 8 shared runtime)" }
}
Write-Host ("{0} assemblies resolved from the payload, {1} from the .NET 8 shared runtime." -f $payloadCount, $runtimeCount)

Write-Host '--- Embedded fonts ---'
$pdfDll = Join-Path $PayloadRoot 'SAM.Core.Reporting.Pdf.dll'
if (Test-Path $pdfDll) {
    $resources = (Get-AssemblyInfo $pdfDll).Resources
    foreach ($font in @('SAM.Core.Reporting.Pdf.Fonts.NotoSans-Regular.ttf', 'SAM.Core.Reporting.Pdf.Fonts.NotoSans-Bold.ttf')) {
        if ($resources -contains $font) { Write-Host "OK   $font" } else { Fail "font resource not embedded: $font" }
    }
}

Write-Host '--- PDFsharp / MigraDoc versions ---'
$pattern = '^(PdfSharp|MigraDoc)(\..+)?\.dll$'
$payloadDirectory.GetFiles() | Where-Object { $_.Name -match $pattern } | Sort-Object Name | ForEach-Object {
    $info = [System.Diagnostics.FileVersionInfo]::GetVersionInfo($_.FullName)
    $productVersion = ($info.ProductVersion -split '\+')[0]
    if ($productVersion -eq $ExpectedPdfSharpVersion) {
        Write-Host ("OK   {0,-38} {1}  ({2})" -f $_.Name, $productVersion, $info.FileVersion)
    }
    else {
        Fail ("{0} is {1}, expected {2}" -f $_.Name, $productVersion, $ExpectedPdfSharpVersion)
    }
}

foreach ($subdirectory in $payloadDirectory.GetDirectories()) {
    $subdirectory.GetFiles('*.dll', [System.IO.SearchOption]::AllDirectories) | Where-Object { $_.Name -match $pattern } |
        Sort-Object FullName | ForEach-Object {
            $relative = $subdirectory.Name + $_.FullName.Substring($subdirectory.FullName.Length)
            $productVersion = ([System.Diagnostics.FileVersionInfo]::GetVersionInfo($_.FullName).ProductVersion -split '\+')[0]
            if ($subdirectory.Name -match '^Revit \d{4}$') {
                Write-Host ("INFO {0} {1} (SAM_Revit deployment, separate from SAM Analytical)" -f $relative, $productVersion)
            }
            else {
                Fail ("second copy outside the payload root: {0} {1}" -f $relative, $productVersion)
            }
        }
}

if ($failures.Count -gt 0) {
    Write-Host ("Reporting payload gate FAILED: {0} problem(s)." -f $failures.Count)
    exit 1
}

Write-Host 'Reporting payload gate passed.'
exit 0
