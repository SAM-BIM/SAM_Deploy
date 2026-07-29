# Snapshots the Revit build output for one Revit year into a year-stamped folder.
#
# Why this exists: SAM_Revit and SAM_Revit_UI both build to a single shared
# ..\..\build\ directory with no Revit year anywhere in the path, and each
# Release20xx rebuild overwrites the previous one. The staging step downstream
# assigns a file to a year by matching the year in its full path, so files that
# come straight out of build\ match no year at all and fall through to "every
# year" - meaning whichever configuration was rebuilt last would be published
# for all of them.
#
# That was survivable while 2025 and 2026 both targeted net8.0-windows. It is
# not survivable now: Revit 2027 targets net10.0-windows, so publishing the last
# build to every year would put net10 assemblies into the Revit 2025 and 2026
# payloads, which those versions cannot load at all.
#
# So each year's output is copied here, immediately after that year is built,
# into a path containing the year. The staging step reads these in preference to
# build\ (they carry the highest weight), which makes each payload genuinely
# per-year.

param(
    [Parameter(Mandatory = $true)]
    [ValidateSet('2025', '2026', '2027')]
    [string]$Year
)

$ErrorActionPreference = 'Stop'

$root = if ($env:GITHUB_WORKSPACE) { $env:GITHUB_WORKSPACE } else { (Get-Location).Path }
$destRoot = Join-Path $root "_revitsnap\$Year"

$sourceDirs = @(
    (Join-Path $root 'SAM_Revit\build'),
    (Join-Path $root 'SAM_Revit_UI\build')
)

# Same shape the staging step looks for.
$revitNameRegex = '^SAM\..*Revit.*\.(dll|pdb|xml|config|json)$'

New-Item -ItemType Directory -Force -Path $destRoot | Out-Null

$copied = 0
foreach ($dir in $sourceDirs) {
    if (-not (Test-Path $dir)) {
        Write-Host "WARN: $dir not found; nothing to snapshot from it."
        continue
    }

    Get-ChildItem -Path $dir -File -ErrorAction SilentlyContinue |
        Where-Object { $_.Name -match $revitNameRegex } |
        ForEach-Object {
            Copy-Item $_.FullName (Join-Path $destRoot $_.Name) -Force
            $copied++
        }
}

Write-Host "Snapshotted $copied Revit $Year file(s) to $destRoot"

if ($copied -eq 0) {
    throw "Revit $Year snapshot is empty - the rebuild for this year produced no matching output in SAM_Revit\build or SAM_Revit_UI\build."
}

$loader = Join-Path $destRoot 'SAM.Revit.UI.dll'
if (-not (Test-Path $loader)) {
    throw "Revit $Year snapshot is missing SAM.Revit.UI.dll - the add-in loader did not build for this year."
}
