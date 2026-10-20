param(
    [Parameter(Mandatory)] [string[]] $Comparisons,   # compare-persisted.ps1 outputs (cmp-os-*.json); read only
    [Parameter(Mandatory)] [string] $SourceModel,     # the S05 input model (box-aperture.json, sha256 99ba2ab9...)
    [string] $Out
)
# S06 check, added after review and scoped to the S06 OpenStudio comparisons of the box fixture. It is not a general
# result-identity rule.
#
# The raw comparisons report exactMatch=false because the OpenStudio route names each window subsurface
# SAM_SUBSURFACE_<panel name>_<n>_<hex8> after the aperture of the run's model copy, so the name differs between runs.
# A result path is <result type>/<name>/<load type>/<reference>/<field>. SAM_OpenStudio Modify/AddResults.cs
# (LookupPanel, Referenced) attaches a subsurface result to the Panel hosting that aperture and sets the result's
# Reference to that panel's Guid. The reference is therefore a host-panel Guid, not an aperture Guid.
#
# The comparison files are left as measured. For each difference the script checks:
#   1. the path is a generated subsurface name plus a 32-hex reference (anything else fails);
#   2. the reference is the Guid of exactly one SAM.Analytical.Panel object in the source model's AdjacencyCluster;
#      that panel is not a Shade and hosts exactly one Aperture, so the fixture maps panel -> window unambiguously
#      (a missing panel, a duplicate Guid, or zero or several apertures fails);
#   3. on each side the reference carries exactly one generated name, and no name appears under two references
#      (a unique 1:1 mapping);
#   4. after mapping, each field has exactly one value per side, and the values are numerically equal.
$ErrorActionPreference = 'Stop'

$model = Get-Content $SourceModel -Raw | ConvertFrom-Json
$panels = New-Object System.Collections.ArrayList
function Find-Panels($o) {
    if ($null -eq $o) { return }
    if ($o -is [System.Management.Automation.PSCustomObject]) {
        if ("$($o._type)" -like 'SAM.Analytical.Panel,*') { [void]$panels.Add($o) }
        foreach ($p in $o.PSObject.Properties) { Find-Panels $p.Value }
    } elseif ($o -is [System.Collections.IEnumerable] -and -not ($o -is [string])) {
        foreach ($x in $o) { Find-Panels $x }
    }
}
Find-Panels $model.AdjacencyCluster.Objects
$panelsByRef = @{}
foreach ($p in $panels) {
    $key = ("$($p.Guid)" -replace '-', '').ToLowerInvariant()
    if (-not $panelsByRef.ContainsKey($key)) { $panelsByRef[$key] = New-Object System.Collections.ArrayList }
    [void]$panelsByRef[$key].Add($p)
}
$hosts = @($panels | Where-Object { @($_.Apertures | Where-Object { $null -ne $_ }).Count -gt 0 })

$lines = @("Source model: $(Split-Path $SourceModel -Leaf) sha256 $((Get-FileHash $SourceModel -Algorithm SHA256).Hash.ToLowerInvariant().Substring(0, 8)); $($panels.Count) Panel objects in AdjacencyCluster.Objects, $($hosts.Count) of them host apertures")
$failed = $false
foreach ($c in $Comparisons) {
    $j = Get-Content $c -Raw | ConvertFrom-Json
    $diffs = @($j.differences)
    $lines += "== $(Split-Path $c -Leaf): exactMatch=$($j.exactMatch) numbers=$($j.baselineNumbers)/$($j.candidateNumbers) differences=$($diffs.Count) (as measured)"
    $rows = foreach ($d in $diffs) {
        $p = $d.path -split '/'
        if ($p.Count -ne 5 -or $p[1] -notmatch '^SAM_SUBSURFACE_.+_\d+_[0-9A-F]{8}$' -or $p[3] -notmatch '^[0-9a-f]{32}$') {
            $lines += "  FAIL: difference outside a generated subsurface name: $($d.path)"; $failed = $true; continue
        }
        [pscustomobject]@{ Name = $p[1]; Ref = $p[3]; Field = $p[4]; B = $d.baseline; C = $d.candidate }
    }
    # No generated name may sit under two references on the same side.
    foreach ($side in 'B', 'C') {
        foreach ($g in @($rows | Where-Object { $null -ne $_.$side } | Group-Object Name)) {
            if (@($g.Group | ForEach-Object Ref | Sort-Object -Unique).Count -ne 1) { $lines += "  FAIL: name $($g.Name) under several references"; $failed = $true }
        }
    }
    $refs = @($rows | Group-Object Ref)
    foreach ($g in $refs) {
        $problems = @()
        $found = @(if ($panelsByRef.ContainsKey($g.Name)) { $panelsByRef[$g.Name] })
        $panelText = 'none'
        if ($found.Count -ne 1) { $problems += "$($found.Count) Panel objects with this Guid" }
        else {
            $panel = $found[0]
            $apertures = @($panel.Apertures | Where-Object { $null -ne $_ })
            $panelText = "Panel '$($panel.Name)' $($panel.PanelType), $($apertures.Count) aperture(s)"
            if ("$($panel.PanelType)" -eq 'Shade') { $problems += 'shade panel' }
            if ($apertures.Count -ne 1) { $problems += "$($apertures.Count) apertures (mapping not unambiguous)" }
        }
        $bn = @($g.Group | Where-Object { $null -ne $_.B } | ForEach-Object Name | Sort-Object -Unique)
        $cn = @($g.Group | Where-Object { $null -ne $_.C } | ForEach-Object Name | Sort-Object -Unique)
        if ($bn.Count -ne 1 -or $cn.Count -ne 1) { $problems += "names baseline $($bn.Count) / candidate $($cn.Count) (need 1/1)" }
        $fields = @($g.Group | ForEach-Object Field | Sort-Object -Unique)
        $values = @()
        foreach ($f in $fields) {
            $bv = @($g.Group | Where-Object { $_.Field -eq $f -and $null -ne $_.B } | ForEach-Object B)
            $cv = @($g.Group | Where-Object { $_.Field -eq $f -and $null -ne $_.C } | ForEach-Object C)
            if ($bv.Count -ne 1 -or $cv.Count -ne 1) { $problems += "field '$f' has $($bv.Count)/$($cv.Count) values"; continue }
            if ([double]$bv[0] -ne [double]$cv[0]) { $problems += "field '$f' differs: $($bv[0]) vs $($cv[0])" }
            $values += "$f=$($cv[0])"
        }
        if ($problems.Count) { $failed = $true }
        $lines += "  {0} reference {1} -> {2}; baseline {3} -> candidate {4}; {5}{6}" -f `
            $(if ($problems.Count) { 'FAIL' } else { 'OK  ' }), $g.Name, $panelText, ($bn -join ','), ($cn -join ','), ($values -join ', '),
            $(if ($problems.Count) { ' -- ' + ($problems -join '; ') } else { '' })
    }
    $lines += "  references mapped: $($refs.Count); aperture-hosting panels in the model: $($hosts.Count)"
}
$lines += "Result: $(if ($failed) { 'FAIL' } else { 'every difference is a generated subsurface name; each reference is the Guid of one aperture-hosting Panel (one aperture each) and maps 1:1 between runs; mapped values are numerically equal' })"
$lines
if ($Out) { Set-Content -Path $Out -Value $lines -Encoding UTF8 }
if ($failed) { exit 1 }
