param(
    [Parameter(Mandatory)] [string[]] $Comparisons,   # compare-persisted.ps1 outputs (cmp-os-*.json); read only
    [Parameter(Mandatory)] [string] $SourceModel,     # the S05 input model (box-aperture.json)
    [string] $Out
)
# S06 check, added after review: the raw OpenStudio comparisons report exactMatch=false because the OpenStudio route
# generates a new subsurface name (SAM_SUBSURFACE_SIM_EXT_GLZ_0_<hex>) on every run. Each result path is
#   <result type>/<generated name>/<load type>/<source reference>/<field>
# where <source reference> is the SAM aperture GUID from the input model. This script leaves the comparison files as
# measured. For each difference it checks that every source reference has exactly one generated name on each side (a
# unique mapping), that the reference exists in the source model, and that after mapping each field has exactly one value
# per side and the values are numerically equal. Any other difference fails the check.
$ErrorActionPreference = 'Stop'
$model = [IO.File]::ReadAllText($SourceModel)
$lines = @()
$failed = $false
foreach ($c in $Comparisons) {
    $j = Get-Content $c -Raw | ConvertFrom-Json
    $diffs = @($j.differences)
    $lines += "== $(Split-Path $c -Leaf): exactMatch=$($j.exactMatch) numbers=$($j.baselineNumbers)/$($j.candidateNumbers) differences=$($diffs.Count)"
    $rows = foreach ($d in $diffs) {
        $p = $d.path -split '/'
        if ($p.Count -ne 5 -or $p[1] -notmatch '^SAM_SUBSURFACE_SIM_EXT_GLZ_\d+_[0-9A-F]{8}$' -or $p[3] -notmatch '^[0-9a-f]{32}$') {
            $lines += "  FAIL: difference outside a generated subsurface name: $($d.path)"; $failed = $true; continue
        }
        [pscustomobject]@{ Name = $p[1]; Ref = $p[3]; Field = $p[4]; B = $d.baseline; C = $d.candidate }
    }
    foreach ($g in @($rows | Group-Object Ref)) {
        $bn = @($g.Group | Where-Object { $null -ne $_.B } | ForEach-Object Name | Sort-Object -Unique)
        $cn = @($g.Group | Where-Object { $null -ne $_.C } | ForEach-Object Name | Sort-Object -Unique)
        $fields = @($g.Group | ForEach-Object Field | Sort-Object -Unique)
        $equal = $true
        foreach ($f in $fields) {
            $bv = @($g.Group | Where-Object { $_.Field -eq $f -and $null -ne $_.B } | ForEach-Object B)
            $cv = @($g.Group | Where-Object { $_.Field -eq $f -and $null -ne $_.C } | ForEach-Object C)
            if ($bv.Count -ne 1 -or $cv.Count -ne 1 -or [double]$bv[0] -ne [double]$cv[0]) { $equal = $false }
        }
        $guid = $g.Name.Insert(8, '-').Insert(13, '-').Insert(18, '-').Insert(23, '-')
        $inModel = $model.Contains($guid) -or $model.Contains($g.Name)
        $ok = $bn.Count -eq 1 -and $cn.Count -eq 1 -and $equal -and $inModel
        if (-not $ok) { $failed = $true }
        $lines += "  {0} reference {1}: baseline {2} -> candidate {3}; {4} fields equal={5}; reference in source model={6}" -f `
            $(if ($ok) { 'OK  ' } else { 'FAIL' }), $g.Name, ($bn -join ','), ($cn -join ','), $fields.Count, $equal, $inModel
    }
}
$lines += "Result: $(if ($failed) { 'FAIL' } else { 'every difference is a generated subsurface name uniquely mapped by its source reference, with numerically equal values' })"
$lines
if ($Out) { Set-Content -Path $Out -Value $lines -Encoding UTF8 }
if ($failed) { exit 1 }
