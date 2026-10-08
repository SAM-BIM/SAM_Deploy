# Native optimisation payload gate.
#
# SAM_UI's Simulate > Optimisation runs GenOptDocument.RunNative (SAM_Tas) over the SAM.Math
# optimisation kernel. It needs, beside SAM Analytical.exe in the installed %APPDATA%\SAM:
#   - the current SAM.Analytical.Tas.GenOpt.dll (SAM_Tas build);
#   - the current SAM.Math.dll (SAM build). Every other place that ships SAM.Math.dll (the
#     per-Revit-year folders, SAMdependencies, the Rhino 8/9 package) must carry the SAME
#     assembly: SAM_UI detects a stale copy at run time, and a second, older SAM.Math.dll loaded
#     by Rhino or Grasshopper is the same defect.
# Every one of those is a copy-local side effect of a different project's build, and the H12
# audit does not look at the Rhino package or SAMdependencies, so this checks the whole STAGED
# installer tree (SAM_Installer\build), by content hash:
#   1. SAM\build\SAM.Math.dll and SAM_Tas\build\SAM.Analytical.Tas.GenOpt.dll (this job's own
#      build output) exist; they are the intended Q4 sources;
#   2. SAM.Math.dll and SAM.Analytical.Tas.GenOpt.dll exist at the SAM payload root;
#   3. every staged copy of each, anywhere under the stage root, has the source's hash;
#   4. no GenOpt.bat (the retired Java launcher) is staged anywhere.
# It reports; it never overwrites a mismatching copy. Exit code 1 on any failure.

param(
    [Parameter(Mandatory = $true)]
    [string]$StageRoot,

    [Parameter(Mandatory = $true)]
    [string]$RepoRoot
)

$ErrorActionPreference = 'Stop'

foreach ($p in @($StageRoot, $RepoRoot)) {
    if (-not (Test-Path -LiteralPath $p)) { throw "Path not found: $p" }
}
# One DirectoryInfo for every enumeration, so paths compare in one form (no 8.3 vs long-name mismatch).
$stageDirectory = New-Object System.IO.DirectoryInfo((Resolve-Path -LiteralPath $StageRoot).Path)
$StageRoot = $stageDirectory.FullName
$RepoRoot = (Resolve-Path -LiteralPath $RepoRoot).Path
$samRoot = Join-Path $StageRoot 'SAM'

$failures = New-Object System.Collections.Generic.List[string]
function Fail([string]$message) { $failures.Add($message); Write-Host "FAIL: $message" }

function Get-Sha([string]$path) { (Get-FileHash -LiteralPath $path -Algorithm SHA256).Hash }
function Rel([string]$path) { $path.Substring($StageRoot.Length).TrimStart('\', '/') }

$assemblies = @(
    [pscustomobject]@{ Name = 'SAM.Math.dll'; Source = (Join-Path $RepoRoot 'SAM\build\SAM.Math.dll') },
    [pscustomobject]@{ Name = 'SAM.Analytical.Tas.GenOpt.dll'; Source = (Join-Path $RepoRoot 'SAM_Tas\build\SAM.Analytical.Tas.GenOpt.dll') }
)

foreach ($a in $assemblies) {
    Write-Host "--- $($a.Name) ---"
    if (-not (Test-Path -LiteralPath $a.Source)) {
        Fail "$($a.Name): build output not found at $($a.Source)"
        continue
    }
    $expected = Get-Sha $a.Source
    Write-Host ("source   {0}  {1}" -f $expected.Substring(0, 12), $a.Source)

    if (-not (Test-Path -LiteralPath (Join-Path $samRoot $a.Name))) {
        Fail "$($a.Name): missing from the SAM payload root ($samRoot)"
    }

    $copies = @($stageDirectory.GetFiles($a.Name, [System.IO.SearchOption]::AllDirectories))
    foreach ($c in $copies) {
        $hash = Get-Sha $c.FullName
        $ok = $hash -eq $expected
        Write-Host ("{0,-8} {1}  {2}" -f $(if ($ok) { 'OK' } else { 'MISMATCH' }), $hash.Substring(0, 12), (Rel $c.FullName))
        if (-not $ok) { Fail "$($a.Name): staged copy '$(Rel $c.FullName)' differs from the build output $($a.Source)" }
    }
    Write-Host "$($copies.Count) staged cop$(if ($copies.Count -eq 1) { 'y' } else { 'ies' })"
}

Write-Host '--- Retired Java GenOpt launcher ---'
$legacy = @($stageDirectory.GetFiles('GenOpt.bat', [System.IO.SearchOption]::AllDirectories))
foreach ($l in $legacy) { Fail "GenOpt.bat is staged at '$(Rel $l.FullName)' (the Java route is retired)" }
if ($legacy.Count -eq 0) { Write-Host 'No GenOpt.bat staged.' }

if ($failures.Count -gt 0) {
    Write-Host "::error::Native optimisation payload gate failed: $($failures.Count) problem(s)."
    exit 1
}
Write-Host 'Native optimisation payload gate passed.'
exit 0
