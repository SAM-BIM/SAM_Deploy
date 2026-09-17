# H12 - installer payload provenance audit.
#
# Classifies every managed/native binary in a staged installer payload into one of
# three buckets and enforces provenance only where it actually applies:
#
#   A. SAM-owned managed  (a .dll/.gha/.rhp produced by a non-test project in a
#      pinned SAM-BIM submodule)               -> FileVersion must equal SAMVersion,
#                                                  ProductVersion must equal
#                                                  InformationalVersion (when supplied)
#   B. SAM-owned native   (SAM.Occt.Native.dll) -> same rule as A
#   C. Third-party        (everything else)     -> reported only, NOT compared to
#                                                  SAMVersion - except OpenCASCADE's
#                                                  own TK*.dll runtime, which must
#                                                  match the pinned OCCT SDK version
#
# This replaces the earlier "every DLL must equal SAMVersion" H12 wording (wrong -
# third-party/vendor binaries must keep their own upstream version) with the
# classification documented in RELEASE_VALIDATION.md.
#
# Ownership (SAM-owned vs third-party) is determined PRIMARILY by an ownership map
# built from each pinned submodule's own non-test *.csproj files: for every such
# project, its own compiled output identity - <AssemblyName> (or the csproj's base
# name when AssemblyName is not set), plus a `.gha` sibling for anything under a
# `Grasshopper\` folder, plus a `<TargetExt>` override such as `.rhp` when the
# project sets one - is registered as SAM-owned. This matches H12's actual wording
# ("produced by a non-test project in a pinned submodule") rather than a filename
# guess, so a SAM-owned binary that does not happen to be named `SAM.*` cannot
# silently be classified as third-party. A payload file matching the `SAM.*` naming
# convention is ALSO always treated as SAM-owned even if the ownership-map walk
# missed it (fail-safe net, flagged UNATTRIBUTED so a human can see the gap) -
# under-attribution must never silently downgrade a real SAM binary to
# "third-party, unchecked".
#
# The OpenCASCADE toolkit set and its expected version are resolved from the SAME
# physical OCCT SDK the native build itself uses (TKernel.dll's own embedded
# FileVersion, and every TK*.dll actually present next to it) rather than an
# independently hard-coded value - see Resolve-OcctSdkIdentity. This is also what
# correctly separates a genuine OpenCASCADE toolkit (TKernel.dll, TKBRep.dll, ...)
# from an unrelated DLL that merely happens to start with a case-insensitive "tk"
# (e.g. Tcl/Tk's own tk86.dll) - membership is checked against the real SDK content,
# not a naming pattern.
#
# IMPORTANT - scope lock (see AGENTS.md / the approved H12 plan): if this script
# finds a SAM-owned provenance violation that is not one of the 8 SAM_OCCT managed
# assemblies or SAM.Occt.Native.dll, DO NOT silently fix it, allowlist it, or widen
# this script's rules to make it pass. Stop and report it - it means the payload has
# a provenance defect in some OTHER repo that needs its own investigation.

param(
    [Parameter(Mandatory = $true)]
    [string]$PayloadRoot,

    # Root containing the pinned SAM-BIM submodule checkouts (SAM, SAM_OCCT, ...).
    # Defaults to the parent of the .github folder this script lives in (the
    # SAM_Deploy repo root), so it works both in CI (cwd = repo root) and locally.
    [string]$RepoRoot,

    [string]$SAMVersion = $env:SAMVersion,
    [string]$InformationalVersion = $env:InformationalVersion,

    # Where installer.yml's own "Build OCCT native engine" step downloads/caches the
    # OCCT SDK. Read TKernel.dll's own FileVersion + enumerate its own TK*.dll
    # siblings from here - the actual resolved SDK identity, not a separate guess.
    [string]$OcctSdkRoot = 'C:\OCCT',

    # Used ONLY when $OcctSdkRoot has no SDK to read (e.g. a local dry run without
    # the SDK downloaded). Reflects the pinned Q3 SDK version so the script still
    # behaves sensibly offline; ignored whenever TKernel.dll can be resolved.
    [string]$OcctSdkVersion = '8.0.0',

    # Report-only by default (section 18: dry-run before the PR). CI passes -Enforce.
    [switch]$Enforce,

    [string]$ReportPath = 'h12-audit-report.md',
    [string]$CsvPath = 'h12-audit-report.csv'
)

$ErrorActionPreference = 'Stop'

if (-not $RepoRoot) {
    $RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
}
$RepoRoot = (Resolve-Path $RepoRoot).Path

if (-not (Test-Path -LiteralPath $PayloadRoot)) {
    throw "PayloadRoot not found: $PayloadRoot"
}
$PayloadRoot = (Resolve-Path $PayloadRoot).Path

if ([string]::IsNullOrWhiteSpace($SAMVersion)) {
    throw "SAMVersion was not supplied (pass -SAMVersion or set the SAMVersion env var)."
}

# -----------------------------------------------------------------------------
# The 9 approved SAM_OCCT release binaries (H12 plan, SAM_OCCT PR #70), spelled
# exactly as they land in the staged payload root. Verified against the real
# staging pipeline, not guessed:
#   - the 5 non-Grasshopper SAM_OCCT projects ship only a .dll;
#   - each of the 3 Grasshopper SAM_OCCT projects' own PostBuild target ("Local
#     packaging: must succeed", SAM_OCCT/Grasshopper/*/*.csproj) copies its
#     $(TargetPath) to a sibling .gha next to it, and installer.yml's own
#     "Root Grasshopper DLLs -> GHA" staging step independently ensures the same
#     for anything matching ^SAM\..*Grasshopper.*\.dll$ at the payload root - so
#     BOTH the .dll and the .gha are expected to be present;
#   - SAM.Occt.Native.dll is the native wrapper.
# A missing native build, or the known SAM.Core.Grasshopper.OCCT Release|AnyCPU
# OutputPath quirk combined with that project's live-deployment copy being
# IgnoreExitCode="true" (best-effort, so a locked-file failure there does NOT
# fail the build), must not silently pass H12 just because the file was never
# scanned - this list is checked for PRESENCE regardless of what the payload
# walk below finds.
# -----------------------------------------------------------------------------
$RequiredSamOcctBinaries = @(
    'SAM.Core.OCCT.dll'
    'SAM.Geometry.OCCT.Solver.dll'
    'SAM.Analytical.OCCT.Solver.dll'
    'SAM.Geometry.OCCT.dll'
    'SAM.Analytical.OCCT.dll'
    'SAM.Core.Grasshopper.OCCT.dll'
    'SAM.Core.Grasshopper.OCCT.gha'
    'SAM.Geometry.Grasshopper.OCCT.dll'
    'SAM.Geometry.Grasshopper.OCCT.gha'
    'SAM.Analytical.Grasshopper.OCCT.dll'
    'SAM.Analytical.Grasshopper.OCCT.gha'
    'SAM.Occt.Native.dll'
)

# A conservative, embedded fallback list of real OpenCASCADE 8.0.0 toolkit names
# (enumerated from the vendor SDK's own win64\vc14\bin\TK*.dll, Q3 2026). Used only
# when $OcctSdkRoot has no SDK to read from directly - see Resolve-OcctSdkIdentity.
$OcctToolkitFallbackNames = @(
    'TKBO.dll', 'TKBRep.dll', 'TKBin.dll', 'TKBinL.dll', 'TKBinTObj.dll', 'TKBinXCAF.dll',
    'TKBool.dll', 'TKCAF.dll', 'TKCDF.dll', 'TKD3DHost.dll', 'TKD3DHostTest.dll', 'TKDCAF.dll',
    'TKDE.dll', 'TKDECascade.dll', 'TKDEGLTF.dll', 'TKDEIGES.dll', 'TKDEOBJ.dll', 'TKDEPLY.dll',
    'TKDESTEP.dll', 'TKDESTL.dll', 'TKDEVRML.dll', 'TKDraw.dll', 'TKExpress.dll', 'TKFeat.dll',
    'TKFillet.dll', 'TKG2d.dll', 'TKG3d.dll', 'TKGeomAlgo.dll', 'TKGeomBase.dll', 'TKHLR.dll',
    'TKHelix.dll', 'TKIVtk.dll', 'TKIVtkDraw.dll', 'TKLCAF.dll', 'TKMath.dll', 'TKMesh.dll',
    'TKMeshVS.dll', 'TKOffset.dll', 'TKOpenGl.dll', 'TKOpenGlTest.dll', 'TKOpenGles.dll',
    'TKOpenGlesTest.dll', 'TKPrim.dll', 'TKQADraw.dll', 'TKRWMesh.dll', 'TKService.dll',
    'TKShHealing.dll', 'TKStd.dll', 'TKStdL.dll', 'TKTObj.dll', 'TKTObjDRAW.dll', 'TKTopAlgo.dll',
    'TKTopTest.dll', 'TKV3d.dll', 'TKVCAF.dll', 'TKViewerTest.dll', 'TKXCAF.dll', 'TKXDEDRAW.dll',
    'TKXMesh.dll', 'TKXSBase.dll', 'TKXSDRAW.dll', 'TKXSDRAWDE.dll', 'TKXSDRAWGLTF.dll',
    'TKXSDRAWIGES.dll', 'TKXSDRAWOBJ.dll', 'TKXSDRAWPLY.dll', 'TKXSDRAWSTEP.dll', 'TKXSDRAWSTL.dll',
    'TKXSDRAWVRML.dll', 'TKXml.dll', 'TKXmlL.dll', 'TKXmlTObj.dll', 'TKXmlXCAF.dll', 'TKernel.dll'
)

function Resolve-OcctSdkIdentity {
    param([string]$SdkRoot, [string]$FallbackVersion, [string[]]$FallbackNames)

    $names = New-Object 'System.Collections.Generic.HashSet[string]' ([StringComparer]::OrdinalIgnoreCase)
    foreach ($n in $FallbackNames) { [void]$names.Add($n) }

    if ($SdkRoot -and (Test-Path -LiteralPath $SdkRoot)) {
        $kernel = Get-ChildItem -Path $SdkRoot -Recurse -Filter 'TKernel.dll' -ErrorAction SilentlyContinue | Select-Object -First 1
        if ($kernel) {
            $version = $FallbackVersion
            try {
                $fvi = [System.Diagnostics.FileVersionInfo]::GetVersionInfo($kernel.FullName)
                if ($fvi.FileVersion) { $version = $fvi.FileVersion }
            } catch {}

            $binDir = $kernel.Directory.FullName
            $resolvedNames = New-Object 'System.Collections.Generic.HashSet[string]' ([StringComparer]::OrdinalIgnoreCase)
            Get-ChildItem -Path $binDir -Filter 'TK*.dll' -ErrorAction SilentlyContinue | ForEach-Object { [void]$resolvedNames.Add($_.Name) }
            if ($resolvedNames.Count -gt 0) {
                return [pscustomobject]@{
                    Version = $version
                    ToolkitNames = $resolvedNames
                    Source = "resolved from $binDir ($($resolvedNames.Count) TK*.dll, TKernel.dll FileVersion)"
                }
            }
        }
    }

    return [pscustomobject]@{
        Version = $FallbackVersion
        ToolkitNames = $names
        Source = "fallback embedded list ($($names.Count) names) - no SDK found at '$SdkRoot'"
    }
}

$occtSdk = Resolve-OcctSdkIdentity -SdkRoot $OcctSdkRoot -FallbackVersion $OcctSdkVersion -FallbackNames $OcctToolkitFallbackNames

Write-Host "H12 payload audit"
Write-Host "  PayloadRoot           : $PayloadRoot"
Write-Host "  RepoRoot              : $RepoRoot"
Write-Host "  SAMVersion            : $SAMVersion"
Write-Host "  InformationalVersion  : $(if ($InformationalVersion) { $InformationalVersion } else { '<not supplied - ProductVersion not enforced>' })"
Write-Host "  OCCT SDK identity     : version=$($occtSdk.Version) ($($occtSdk.Source))"
Write-Host "  Mode                  : $(if ($Enforce) { 'ENFORCE' } else { 'report-only' })"

# -----------------------------------------------------------------------------
# 1. Ownership map: for every pinned submodule, read each non-test *.csproj's own
#    output identity (AssemblyName + extension) - not a filename guess over build
#    output. See header for why.
# -----------------------------------------------------------------------------
$submoduleNames = @()
$gitmodulesPath = Join-Path $RepoRoot '.gitmodules'
if (Test-Path -LiteralPath $gitmodulesPath) {
    # @(...) forces array semantics even if exactly one path matches - otherwise
    # PowerShell 5.1 unwraps a single pipeline result to a bare scalar and
    # ".Count" silently returns $null (see the identical, more consequential
    # fix on $violations below).
    $submoduleNames = @((Get-Content -LiteralPath $gitmodulesPath) |
        Select-String -Pattern '^\s*path\s*=\s*(\S+)' |
        ForEach-Object { $_.Matches[0].Groups[1].Value })
}
if ($submoduleNames.Count -eq 0) {
    throw "No submodules found in $gitmodulesPath - cannot build an ownership map."
}

function Test-IsTestCsproj {
    param([string]$Path, [string]$Content)
    if ($Path -match '(?i)\\(Testing|Tests?)\\') { return $true }
    $baseName = [System.IO.Path]::GetFileNameWithoutExtension($Path)
    if ($baseName -match '(?i)\.?(Tests?|UnitTests|IntegrationTests|GrasshopperTests)$') { return $true }
    if ($Content -match '(?i)<IsTestProject>\s*true\s*</IsTestProject>') { return $true }
    return $false
}

function Get-ProjectOutputNames {
    param([string]$Path, [string]$Content)
    $asmMatch = [regex]::Match($Content, '(?i)<AssemblyName>\s*([^<]+?)\s*</AssemblyName>')
    $asmName = if ($asmMatch.Success) { $asmMatch.Groups[1].Value } else { [System.IO.Path]::GetFileNameWithoutExtension($Path) }

    $names = New-Object System.Collections.Generic.List[string]
    $names.Add("$asmName.dll")
    if ($Path -match '(?i)\\Grasshopper\\') { $names.Add("$asmName.gha") }
    $extMatch = [regex]::Match($Content, '(?i)<TargetExt>\s*(\.[A-Za-z0-9]+)\s*</TargetExt>')
    if ($extMatch.Success) { $names.Add("$asmName$($extMatch.Groups[1].Value)") }
    return $names
}

# filename (lowercase) -> list of {Repo, Path (source csproj), Kind}
$ownershipMap = @{}
$csprojCount = 0
foreach ($repoName in $submoduleNames) {
    $repoPath = Join-Path $RepoRoot $repoName
    if (-not (Test-Path -LiteralPath $repoPath)) { continue }

    Get-ChildItem -Path $repoPath -Recurse -File -Filter '*.csproj' -ErrorAction SilentlyContinue |
        Where-Object { $_.FullName -notmatch '(?i)\\(obj|bin|packages)\\' } |
        ForEach-Object {
            $csprojCount++
            $content = Get-Content -LiteralPath $_.FullName -Raw
            if (Test-IsTestCsproj -Path $_.FullName -Content $content) { return }

            foreach ($outName in (Get-ProjectOutputNames -Path $_.FullName -Content $content)) {
                $key = $outName.ToLowerInvariant()
                if (-not $ownershipMap.ContainsKey($key)) { $ownershipMap[$key] = @() }
                $ownershipMap[$key] += [pscustomobject]@{ Repo = $repoName; Project = $_.FullName }
            }
        }
}
Write-Host "Ownership map built from $($submoduleNames.Count) pinned repos ($csprojCount non-test/test csproj files scanned): $($ownershipMap.Count) distinct SAM-owned output names."

# -----------------------------------------------------------------------------
# 2. Walk the staged payload and classify every managed/native binary.
# -----------------------------------------------------------------------------
$testBinaryPattern = '(?i)(\.(Tests?|UnitTests|IntegrationTests|GrasshopperTests)\.(dll|gha|rhp)$|^(xunit|testhost|vstest|Microsoft\.TestPlatform|Microsoft\.VisualStudio\.TestPlatform|coverlet)\b)'

$rows = New-Object System.Collections.Generic.List[object]

Get-ChildItem -Path $PayloadRoot -Recurse -File -Include '*.dll', '*.gha', '*.rhp' -ErrorAction SilentlyContinue | ForEach-Object {
    $f = $_
    $name = $f.Name
    $key = $name.ToLowerInvariant()
    $relPath = $f.FullName.Substring($PayloadRoot.Length).TrimStart('\', '/')

    $isTestBinary = [bool]([regex]::IsMatch($name, $testBinaryPattern))

    $owners = $ownershipMap[$key]
    $ownerRepos = if ($owners) { ($owners.Repo | Select-Object -Unique) -join ',' } else { $null }
    $attributed = [bool]$owners
    $nameLooksSamOwned = [bool]($name -match '^SAM\..+\.(dll|gha|rhp)$')

    $class =
        if ($key -eq 'sam.occt.native.dll') { 'SAM-owned native' }
        elseif ($attributed) { 'SAM-owned managed' }
        elseif ($nameLooksSamOwned) { 'SAM-owned managed' }                 # fail-safe net, see header
        elseif ($occtSdk.ToolkitNames.Contains($name)) { 'Third-party (OCCT SDK)' }
        else { 'Third-party' }

    $fvi = $null
    try { $fvi = [System.Diagnostics.FileVersionInfo]::GetVersionInfo($f.FullName) } catch {}
    $fileVersion = if ($fvi) { $fvi.FileVersion } else { $null }
    $productVersion = if ($fvi) { $fvi.ProductVersion } else { $null }

    $expected = $null
    $status = 'UNVERIFIED'

    switch ($class) {
        'SAM-owned managed' {
            $expected = $SAMVersion
            $status = if ($fileVersion -eq $SAMVersion) { 'OK' } else { 'MISMATCH' }
            if ($InformationalVersion -and $productVersion -ne $InformationalVersion) { $status = 'MISMATCH' }
        }
        'SAM-owned native' {
            $expected = $SAMVersion
            $status = if ($fileVersion -eq $SAMVersion) { 'OK' } else { 'MISMATCH' }
            if ($InformationalVersion -and $productVersion -ne $InformationalVersion) { $status = 'MISMATCH' }
        }
        'Third-party (OCCT SDK)' {
            $expected = $occtSdk.Version
            $status = if ($fileVersion -and $fileVersion.StartsWith($occtSdk.Version)) { 'OK' } else { 'MISMATCH' }
        }
        default {
            $expected = '<not enforced - third-party>'
            $status = 'REPORTED'
        }
    }

    if ($isTestBinary) { $status = 'TEST_BINARY_IN_PAYLOAD' }

    $rows.Add([pscustomobject]@{
        RelativePath    = $relPath
        Name            = $name
        Class           = $class
        OwnerRepo       = if ($attributed) { $ownerRepos } elseif ($class -like 'SAM-owned*') { 'UNATTRIBUTED' } else { '' }
        FileVersion     = $fileVersion
        ProductVersion  = $productVersion
        Expected        = $expected
        Status          = $status
    })
}

Write-Host "Payload scanned: $($rows.Count) .dll/.gha/.rhp files under $PayloadRoot"

# -----------------------------------------------------------------------------
# 3. Required-presence gate: the 9 approved SAM_OCCT release binaries (12 on-disk
#    names - 5 single-file + 3 dll/gha pairs + native) must actually be IN the
#    payload. A file that was never scanned because it is simply missing (a failed
#    native build, or the known best-effort/IgnoreExitCode Grasshopper deployment
#    quietly not running) must fail H12, not pass it by omission.
# -----------------------------------------------------------------------------
$presentNames = New-Object 'System.Collections.Generic.HashSet[string]' ([StringComparer]::OrdinalIgnoreCase)
foreach ($r in $rows) { [void]$presentNames.Add($r.Name) }

foreach ($required in $RequiredSamOcctBinaries) {
    if (-not $presentNames.Contains($required)) {
        $rows.Add([pscustomobject]@{
            RelativePath    = '<missing>'
            Name            = $required
            Class           = if ($required -ieq 'SAM.Occt.Native.dll') { 'SAM-owned native' } else { 'SAM-owned managed' }
            OwnerRepo       = 'SAM_OCCT'
            FileVersion     = $null
            ProductVersion  = $null
            Expected        = $SAMVersion
            Status          = 'MISSING_REQUIRED_BINARY'
        })
    }
}

# -----------------------------------------------------------------------------
# 4. Report.
# -----------------------------------------------------------------------------
$byClass = $rows | Group-Object Class | Sort-Object Name
foreach ($g in $byClass) {
    Write-Host ("  {0,-24} : {1,4} files" -f $g.Name, $g.Count)
}

# @(...) forces array semantics: in Windows PowerShell 5.1, a Where-Object
# pipeline that matches EXACTLY ONE item unwraps to a bare [pscustomobject]
# scalar rather than a one-element array, and a bare object has no ".Count"
# property - so "$violations.Count" would silently evaluate to $null, and
# "$null -gt 0" is $false, making a real single violation (e.g. exactly one
# missing required binary) pass enforcement silently. Caught by the required-
# presence-gate negative test while validating gap #1 - do not remove this.
$violations = @($rows | Where-Object { $_.Status -in @('MISMATCH', 'TEST_BINARY_IN_PAYLOAD', 'MISSING_REQUIRED_BINARY') })

$reportLines = New-Object System.Collections.Generic.List[string]
$reportLines.Add('# H12 payload provenance audit')
$reportLines.Add('')
$reportLines.Add("SAMVersion: ``$SAMVersion``  InformationalVersion: ``$InformationalVersion``  OCCT SDK: version=``$($occtSdk.Version)`` ($($occtSdk.Source))")
$reportLines.Add('')
$reportLines.Add('| Class | Name | Owner repo | FileVersion | ProductVersion | Expected | Status |')
$reportLines.Add('|---|---|---|---|---|---|---|')
foreach ($r in ($rows | Sort-Object Class, Name)) {
    $reportLines.Add("| $($r.Class) | $($r.Name) | $($r.OwnerRepo) | $($r.FileVersion) | $($r.ProductVersion) | $($r.Expected) | $($r.Status) |")
}
$reportLines.Add('')
$reportLines.Add('## Violations')
if ($violations.Count -eq 0) {
    $reportLines.Add('None.')
} else {
    foreach ($v in $violations) {
        $reportLines.Add("- **$($v.Status)** ``$($v.RelativePath)`` (class: $($v.Class), owner: $($v.OwnerRepo)) - FileVersion=``$($v.FileVersion)`` ProductVersion=``$($v.ProductVersion)`` expected=``$($v.Expected)``")
    }
}
$reportLines | Set-Content -LiteralPath $ReportPath -Encoding utf8
$rows | Export-Csv -LiteralPath $CsvPath -NoTypeInformation -Encoding utf8

Write-Host "Report written: $ReportPath"
Write-Host "CSV written:    $CsvPath"

if ($violations.Count -gt 0) {
    Write-Host "::warning::H12 audit found $($violations.Count) violation(s):"
    foreach ($v in $violations) {
        Write-Host "::warning::  [$($v.Status)] $($v.RelativePath) (class=$($v.Class), owner=$($v.OwnerRepo)) FileVersion=$($v.FileVersion) expected=$($v.Expected)"
    }
} else {
    Write-Host "No H12 violations found."
}

if ($Enforce -and $violations.Count -gt 0) {
    Write-Host "::error::H12 audit FAILED in enforce mode - $($violations.Count) violation(s). See $ReportPath."
    exit 1
}

exit 0
