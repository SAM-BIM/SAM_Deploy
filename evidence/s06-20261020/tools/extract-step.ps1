param([Parameter(Mandatory)] [string] $Workflow, [Parameter(Mandatory)] [string] $StepName)
# Returns the verbatim `run: |` script of one installer.yml step (de-indented), for local replay (S06 harness).
$lines = Get-Content -LiteralPath $Workflow
$start = -1
for ($i = 0; $i -lt $lines.Count; $i++) { if ($lines[$i] -match "^\s*- name: $([regex]::Escape($StepName))\s*$") { $start = $i; break } }
if ($start -lt 0) { throw "Step not found: $StepName" }
$stepIndent = ($lines[$start] -replace '^(\s*).*', '$1').Length
$run = -1
for ($i = $start + 1; $i -lt $lines.Count; $i++) {
    $indent = ($lines[$i] -replace '^(\s*).*', '$1').Length
    if ($lines[$i].Trim() -and $indent -le $stepIndent) { break }
    if ($lines[$i] -match '^\s*run: \|\s*$') { $run = $i; break }
}
if ($run -lt 0) { throw "No run block in step: $StepName" }
$runIndent = ($lines[$run] -replace '^(\s*).*', '$1').Length
$body = New-Object System.Collections.Generic.List[string]
$bodyIndent = $null
for ($i = $run + 1; $i -lt $lines.Count; $i++) {
    $line = $lines[$i]
    if ($line.Trim()) {
        $indent = ($line -replace '^(\s*).*', '$1').Length
        if ($indent -le $runIndent) { break }
        if ($null -eq $bodyIndent) { $bodyIndent = $indent }
        $body.Add($line.Substring([Math]::Min($bodyIndent, $indent)))
    } else { $body.Add('') }
}
return ($body -join "`r`n")
