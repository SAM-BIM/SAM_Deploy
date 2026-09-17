# H12 - installer payload provenance audit.
#
# Classifies every managed/native binary in a staged installer payload into one of
# three buckets and enforces provenance only where it actually applies:
#
#   A. SAM-owned managed  (a .dll/.gha/.rhp produced by a non-test SAM project in a
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
# Ownership (SAM-owned vs third-party) is determined primarily by filename
# convention (SAM-owned files are named `SAM.*` by repo-wide convention, plus the
# one native exception SAM.Occt.Native.dll) and corroborated against an ownership
# map built by walking each pinned submodule's OWN build output - not guessed from
# the payload alone. A SAM-owned file that cannot be attributed to any checked-out
# pinned repository is still audited as SAM-owned (fail safe: under-attribution
# must never silently downgrade a real SAM binary to "third-party, unchecked") but
# is flagged UNATTRIBUTED so a human can see the ownership map missed it.
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

    # Pinned OpenCASCADE SDK version (native/SAM.Occt.Native's TK*.dll runtime).
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

Write-Host "H12 payload audit"
Write-Host "  PayloadRoot           : $PayloadRoot"
Write-Host "  RepoRoot              : $RepoRoot"
Write-Host "  SAMVersion            : $SAMVersion"
Write-Host "  InformationalVersion  : $(if ($InformationalVersion) { $InformationalVersion } else { '<not supplied - ProductVersion not enforced>' })"
Write-Host "  OcctSdkVersion        : $OcctSdkVersion"
Write-Host "  Mode                  : $(if ($Enforce) { 'ENFORCE' } else { 'report-only' })"

# -----------------------------------------------------------------------------
# 1. Ownership map: walk every pinned submodule's own build output and record
#    which repo produced which SAM-owned filename. Used for attribution/reporting
#    only - classification itself is by naming convention (see header).
# -----------------------------------------------------------------------------
$submoduleNames = @()
$gitmodulesPath = Join-Path $RepoRoot '.gitmodules'
if (Test-Path -LiteralPath $gitmodulesPath) {
    $submoduleNames = (Get-Content -LiteralPath $gitmodulesPath) |
        Select-String -Pattern '^\s*path\s*=\s*(\S+)' |
        ForEach-Object { $_.Matches[0].Groups[1].Value }
}
if ($submoduleNames.Count -eq 0) {
    throw "No submodules found in $gitmodulesPath - cannot build an ownership map."
}

# filename (lowercase) -> list of {Repo, Path}
$ownershipMap = @{}
foreach ($repoName in $submoduleNames) {
    $repoPath = Join-Path $RepoRoot $repoName
    if (-not (Test-Path -LiteralPath $repoPath)) { continue }

    Get-ChildItem -Path $repoPath -Recurse -File -Include '*.dll', '*.gha', '*.rhp' -ErrorAction SilentlyContinue |
        Where-Object {
            $_.Name -match '^SAM\.' -and
            $_.FullName -notmatch '\\obj\\' -and
            $_.FullName -notmatch '\\(Testing|Tests?)\\' -and
            $_.FullName -notmatch '(?i)\.(Tests?|UnitTests|IntegrationTests|GrasshopperTests)\.(dll|gha|rhp)$'
        } | ForEach-Object {
            $key = $_.Name.ToLowerInvariant()
            if (-not $ownershipMap.ContainsKey($key)) { $ownershipMap[$key] = @() }
            $ownershipMap[$key] += [pscustomobject]@{ Repo = $repoName; Path = $_.FullName }
        }
}
Write-Host "Ownership map built from $($submoduleNames.Count) pinned repos: $($ownershipMap.Count) distinct SAM-owned filenames observed in repo build output."

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

    # OpenCASCADE toolkits are named TK<UppercaseWord>.dll (TKernel, TKBRep, TKMath,
    # TKBin, ...) - a case-SENSITIVE match on "TK" + an uppercase letter. This
    # deliberately excludes unrelated third-party DLLs that happen to start with a
    # case-insensitive "tk" (e.g. Tcl/Tk's own tk86.dll, pulled in transitively by
    # OCCT's Draw/GUI toolkits on some SDK layouts) from being misclassified as an
    # OpenCASCADE toolkit and wrongly held to the pinned OCCT SDK version.
    $class =
        if ($key -eq 'sam.occt.native.dll') { 'SAM-owned native' }
        elseif ($name -match '^SAM\..+\.(dll|gha|rhp)$') { 'SAM-owned managed' }
        elseif ($name -cmatch '^TK[A-Z]') { 'Third-party (OCCT SDK)' }
        else { 'Third-party' }

    $fvi = $null
    try { $fvi = [System.Diagnostics.FileVersionInfo]::GetVersionInfo($f.FullName) } catch {}
    $fileVersion = if ($fvi) { $fvi.FileVersion } else { $null }
    $productVersion = if ($fvi) { $fvi.ProductVersion } else { $null }

    $owners = $ownershipMap[$key]
    $ownerRepos = if ($owners) { ($owners.Repo | Select-Object -Unique) -join ',' } else { $null }
    $attributed = [bool]$owners

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
            $expected = $OcctSdkVersion
            $status = if ($fileVersion -and $fileVersion.StartsWith($OcctSdkVersion)) { 'OK' } else { 'MISMATCH' }
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
        OwnerRepo       = if ($attributed) { $ownerRepos } else { if ($class -like 'SAM-owned*') { 'UNATTRIBUTED' } else { '' } }
        FileVersion     = $fileVersion
        ProductVersion  = $productVersion
        Expected        = $expected
        Status          = $status
    })
}

Write-Host "Payload scanned: $($rows.Count) .dll/.gha/.rhp files under $PayloadRoot"

# -----------------------------------------------------------------------------
# 3. Report.
# -----------------------------------------------------------------------------
$byClass = $rows | Group-Object Class | Sort-Object Name
foreach ($g in $byClass) {
    Write-Host ("  {0,-24} : {1,4} files" -f $g.Name, $g.Count)
}

$violations = $rows | Where-Object { $_.Status -in @('MISMATCH', 'TEST_BINARY_IN_PAYLOAD') }

$reportLines = New-Object System.Collections.Generic.List[string]
$reportLines.Add('# H12 payload provenance audit')
$reportLines.Add('')
$reportLines.Add("SAMVersion: ``$SAMVersion``  InformationalVersion: ``$InformationalVersion``  OcctSdkVersion: ``$OcctSdkVersion``")
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
