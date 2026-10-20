param(
    [Parameter(Mandatory)] [string] $A, [Parameter(Mandatory)] [string] $AVersion, [Parameter(Mandatory)] [string] $ARevision,
    [Parameter(Mandatory)] [string] $B, [Parameter(Mandatory)] [string] $BVersion, [Parameter(Mandatory)] [string] $BRevision,
    [string] $Out
)
# S06 repin payload-equivalence check between two installed payload inventories (payload-inventory.ps1): the accepted
# candidate (A, installer run #227) and the repinned build (B). PASS only when:
#   - both payloads have exactly the same relative paths;
#   - every file is byte-identical, or it is an expected stamp difference:
#       * a binary whose FileVersion goes AVersion -> BVersion, whose ProductVersion goes ...+ARevision ->
#         ...+BRevision, and whose length is unchanged (the stamp strings have equal lengths), or
#       * a text file whose stamp-normalised content is identical (payload-inventory.ps1 also normalises SAM_OCCT's
#         build-time AssemblyVersion 1.0.*);
#   - nothing else differs, except two classes that are reported separately: .pdb debug symbols, and the Inno
#     uninstaller's own version label.
# Byte-identical files cover the third-party, .NET runtime and OpenStudio/EnergyPlus native dependencies. The script
# also prints the runtime and dependency inventory those files represent.
$ErrorActionPreference = 'Stop'
function Load($p) {
    $h = @{}
    Import-Csv $p -Delimiter "`t" | ForEach-Object {
        foreach ($c in $_.PSObject.Properties) { if ($c.Value -eq '-') { $c.Value = '' } }   # '-' = empty field
        $h[$_.path.ToLowerInvariant()] = $_
    }
    $h
}
$ha = Load $A; $hb = Load $B
# Inno Setup's per-install uninstall log records install paths and times, so it differs between any two installs (two
# installs of the same EXE also differ only there). It is not part of the payload.
foreach ($h in $ha, $hb) { $h.Remove('unins000.dat') }
$lines = @("A: $(Split-Path $A -Leaf) ($($ha.Count) files, $AVersion +$ARevision); B: $(Split-Path $B -Leaf) ($($hb.Count) files, $BVersion +$BRevision)")
$failed = $false
$onlyA = @($ha.Keys | Where-Object { -not $hb.ContainsKey($_) } | Sort-Object)
$onlyB = @($hb.Keys | Where-Object { -not $ha.ContainsKey($_) } | Sort-Object)
if ($onlyA.Count -or $onlyB.Count) { $failed = $true }
$onlyA | ForEach-Object { $lines += "  FAIL only in A: $($ha[$_].path)" }
$onlyB | ForEach-Object { $lines += "  FAIL only in B: $($hb[$_].path)" }
$identical = 0; $stampBinary = @(); $stampText = @(); $drift = @(); $pdb = @(); $installerLabel = @()
foreach ($k in ($ha.Keys | Where-Object { $hb.ContainsKey($_) } | Sort-Object)) {
    $x = $ha[$k]; $y = $hb[$k]
    if ($x.sha256 -eq $y.sha256) { $identical++; continue }
    # Portable debug symbols are not executable, dependency or runtime content. A deterministic rebuild changes them when
    # the stamp changes: the PDB ID in the header, and the compressed compilation metadata that records the referenced,
    # re-stamped assemblies. They are listed separately and are not counted as stamp-equivalent.
    if ($k.EndsWith('.pdb')) { $pdb += $x.path; continue }
    # Inno Setup's uninstaller carries the installer's own version label (the workflow's version input), not payload.
    if ($k -eq 'unins000.exe' -and $x.fileVersion -eq $y.fileVersion -and $x.length -eq $y.length) { $installerLabel += "$($x.path) ($($x.productVersion) -> $($y.productVersion))"; continue }
    if ($x.stampNormalizedTextSha256) {
        if ($x.stampNormalizedTextSha256 -eq $y.stampNormalizedTextSha256) { $stampText += $x.path } else { $drift += "$($x.path): text differs beyond the stamp" }
        continue
    }
    $pvA = $x.productVersion -replace '\s', ''; $pvB = $y.productVersion -replace '\s', ''
    $ok = $x.length -eq $y.length -and $x.fileVersion -eq $AVersion -and $y.fileVersion -eq $BVersion -and
        $pvA -like "*+$ARevision" -and $pvB -like "*+$BRevision" -and $pvA.Replace($AVersion, '').Replace($ARevision, '') -eq $pvB.Replace($BVersion, '').Replace($BRevision, '')
    if ($ok) { $stampBinary += $x.path } else { $drift += "$($x.path): length $($x.length)->$($y.length), FileVersion '$($x.fileVersion)'->'$($y.fileVersion)', ProductVersion '$($x.productVersion)'->'$($y.productVersion)'" }
}
if ($drift.Count) { $failed = $true }
$lines += "byte-identical: $identical"
$lines += "expected stamp difference, binary (same length; FileVersion $AVersion -> $BVersion; ProductVersion +$ARevision -> +$BRevision): $($stampBinary.Count)"
$lines += "expected stamp difference, text (identical after stamp normalisation): $($stampText.Count)"
$stampText | ForEach-Object { $lines += "    text: $_" }
$lines += "debug symbols (.pdb, not executable/dependency/runtime content; differ as a consequence of the stamp): $($pdb.Count)"
$lines += "installer's own uninstaller label: $(if ($installerLabel.Count) { $installerLabel -join '; ' } else { 'identical' })"
$lines += "other differences (drift): $($drift.Count)"
$drift | ForEach-Object { $lines += "  FAIL drift: $_" }
# Runtime and dependency inventory (from B; each entry is byte-identical to A unless listed above).
$lines += "runtime / dependency inventory (B):"
foreach ($n in 'hostfxr.dll', 'hostpolicy.dll', 'coreclr.dll', 'clrjit.dll', 'System.Private.CoreLib.dll', 'PresentationFramework.dll', 'openstudiolib.dll', 'SAM Analytical.exe', 'benchmark-tas.exe', 'benchmark-openstudio.exe',
    'benchmark-tas.deps.json', 'benchmark-tas.runtimeconfig.json', 'benchmark-openstudio.deps.json', 'benchmark-openstudio.runtimeconfig.json', 'SAM Analytical.runtimeconfig.json', 'SAM Analytical.deps.json') {
    $r = $hb[$n.ToLowerInvariant()]
    if ($r) {
        $state = if ($ha[$n.ToLowerInvariant()].sha256 -eq $r.sha256) { 'identical' } elseif ($stampText -contains $r.path -or $stampBinary -contains $r.path) { 'stamp only' } else { 'DIFFERS' }
        $lines += "  {0}: {1} {2} sha256 {3} ({4})" -f $r.path, $r.fileVersion, $r.productVersion, $r.sha256.Substring(0, 12), $state
    } else { $lines += "  $n : not at the payload root" }
}
$lines += "Result: $(if ($failed) { 'FAIL - payload drift; repeat the affected genuine-installed smoke cases' } else { 'PASS - same files; every difference is the expected stamp' })"
$lines
if ($Out) { Set-Content -Path $Out -Value $lines -Encoding UTF8 }
if ($failed) { exit 1 }
