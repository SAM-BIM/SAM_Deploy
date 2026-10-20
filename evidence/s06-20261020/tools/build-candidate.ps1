param(
    [Parameter(Mandatory)] [string] $Commit,             # SAM_Deploy commit to build (the S06 branch head)
    [string] $Out = 'C:\TasOut\s06\candidate-build',
    [string[]] $SkipSteps = @()
)
# S06 harness: an isolated local replay of SAM_Deploy installer.yml at one SAM_Deploy commit.
#  - SAM_Deploy is cloned to $Out\SAM_Deploy; its 24 submodules are cloned from the sibling SAM-BIM checkouts (local, no
#    network) at the gitlink commits;
#  - APPDATA / USERPROFILE / LOCALAPPDATA point into $Out, so post-builds never touch the real %APPDATA%\SAM;
#  - SAMVersion / InformationalVersion / SAMSourceRevision are computed as the "Compute SAMVersion" step does, with run
#    number 0 (no CI run has it) on branch sow/2026-Q4;
#  - each installer.yml step's run block is executed verbatim (extract-step.ps1) under Windows PowerShell 5.1;
#  - deviation: the OCCT native engine is not built from the OCCT SDK (not on this laptop): the prebuilt native runtime
#    from the sibling SAM_OCCT\build is seeded into the sandbox %APPDATA%\SAM and SAM_OCCT_SKIP_NATIVE_BUILD=true;
#  - Inno Setup packaging is not run: the installer would install into the real %APPDATA%\SAM.
$ErrorActionPreference = 'Stop'
$root = '<SAM-BIM>'
$deploy = Join-Path $Out 'SAM_Deploy'
$workflow = Join-Path $deploy '.github\workflows\installer.yml'
if (Test-Path $Out) { throw "$Out exists; use a fresh folder" }
foreach ($d in "$Out\AppData", "$Out\Profile\Desktop", "$Out\Profile\Documents", "$Out\LocalAppData", "$Out\logs") { New-Item -ItemType Directory -Force $d | Out-Null }
$log = Join-Path $Out 'logs\build-candidate.log'
function Log([string] $m) { $line = "$((Get-Date).ToUniversalTime().ToString('o')) $m"; Write-Host $line; for ($i = 0; $i -lt 20; $i++) { try { [IO.File]::AppendAllText($log, $line + "`r`n"); break } catch { Start-Sleep -Milliseconds 250 } } }

function Invoke-GitChecked([string[]] $a) {
    $saved = $ErrorActionPreference; $ErrorActionPreference = 'Continue'
    try { $o = @(& git.exe @a 2>&1); $c = $LASTEXITCODE } finally { $ErrorActionPreference = $saved }
    if ($c -ne 0) { throw "git $($a -join ' ') failed: $($o -join ' ')" }
    return $o
}

Log "clone SAM_Deploy $Commit"
Invoke-GitChecked @('clone', '--quiet', '--no-checkout', "$root\SAM_Deploy", $deploy) | Out-Null
Invoke-GitChecked @('-C', $deploy, 'checkout', '--quiet', '--detach', $Commit) | Out-Null
$paths = @(Invoke-GitChecked @('-C', $deploy, 'config', '-f', '.gitmodules', '--get-regexp', '^submodule\..*\.path$') | ForEach-Object { ($_ -split ' ', 2)[1] })
Invoke-GitChecked @('-C', $deploy, 'submodule', '--quiet', 'init') | Out-Null
foreach ($p in $paths) {
    $name = @(Invoke-GitChecked @('-C', $deploy, 'config', '-f', '.gitmodules', '--get-regexp', '^submodule\..*\.path$') | Where-Object { ($_ -split ' ', 2)[1] -eq $p } | ForEach-Object { (($_ -split ' ', 2)[0]) -replace '^submodule\.(.*)\.path$', '$1' })[0]
    Invoke-GitChecked @('-C', $deploy, 'config', "submodule.$name.url", "$root\$p") | Out-Null
}
Invoke-GitChecked @('-C', $deploy, '-c', 'protocol.file.allow=always', 'submodule', '--quiet', 'update', '--init') | Out-Null
$pins = @(Invoke-GitChecked @('-C', $deploy, 'submodule', 'status'))
$pins | Set-Content -Encoding UTF8 (Join-Path $Out 'logs\submodule-status.txt')
if (@($pins | Where-Object { $_ -notmatch '^ ' }).Count -gt 0) { throw "submodules not at their gitlinks: $($pins -join '; ')" }
Log "$($pins.Count) submodules checked out at their gitlinks"

# Seed the prebuilt OCCT native runtime (deviation, see header).
$samAppData = Join-Path $Out 'AppData\SAM'
New-Item -ItemType Directory -Force $samAppData | Out-Null
$seeded = 0
foreach ($f in Get-ChildItem "$root\SAM_OCCT\build" -File -Filter '*.dll') {
    $managed = $true; try { [void][Reflection.AssemblyName]::GetAssemblyName($f.FullName) } catch { $managed = $false }
    if (-not $managed) { Copy-Item $f.FullName $samAppData; $seeded++ }
}
Log "seeded $seeded native OCCT runtime files from $root\SAM_OCCT\build"

$short = (@(Invoke-GitChecked @('-C', $deploy, 'rev-parse', '--short', 'HEAD'))[0]).Trim()
$env:SAMVersion = '2026.4.0.0'
$env:InformationalVersion = "$($env:SAMVersion)+$short"
$env:SAMSourceRevision = $short
$env:APPDATA = "$Out\AppData"
$env:USERPROFILE = "$Out\Profile"
$env:LOCALAPPDATA = "$Out\LocalAppData"
$env:GITHUB_WORKSPACE = $deploy
$env:SAM_OCCT_SKIP_NATIVE_BUILD = 'true'
$env:NUGET_PACKAGES = '<USERPROFILE>\.nuget\packages'
$vswhere = Join-Path ${env:ProgramFiles(x86)} 'Microsoft Visual Studio\Installer\vswhere.exe'
$msbuild = @(& $vswhere -latest -requires Microsoft.Component.MSBuild -find 'MSBuild\**\Bin\MSBuild.exe')[0]
$env:PATH = (Split-Path $msbuild) + ';' + $env:PATH
Log "SAMVersion=$env:SAMVersion InformationalVersion=$env:InformationalVersion msbuild=$msbuild"
@("SAMVersion=$env:SAMVersion", "InformationalVersion=$env:InformationalVersion", "SAMSourceRevision=$env:SAMSourceRevision", "SAM_Deploy=$((Invoke-GitChecked @('-C', $deploy, 'rev-parse', 'HEAD'))[0])", "msbuild=$msbuild") | Set-Content -Encoding UTF8 (Join-Path $Out 'logs\stamp.txt')

$steps = @(
    'Clean local caches used for packaging', 'Ensure Grasshopper folders exist',
    'Restore (single node)', 'Rebuild (single node)', 'Restore SAM_UI', 'Rebuild SAM_UI (with post-build)',
    'Restore SAM_Rhino_UI', 'Rebuild SAM_Rhino_UI (with post-build)',
    'Rebuild SAM_Revit_UI 2025 (with post-build)', 'Snapshot Revit 2025 outputs',
    'Rebuild SAM_Revit_UI 2026 (with post-build)', 'Snapshot Revit 2026 outputs',
    'Rebuild SAM_Revit_UI 2027 (with post-build)', 'Snapshot Revit 2027 outputs',
    'Stage payload for installer', 'Stage Benchmark producers', 'Assert Benchmark producers payload',
    'Assert reporting/PDF payload', 'Assert native optimisation payload', 'Audit payload versions (H12)')
$results = @()
foreach ($step in $steps) {
    if ($SkipSteps -contains $step) { Log "SKIP $step"; $results += "SKIP  $step"; continue }
    $body = & (Join-Path $PSScriptRoot 'extract-step.ps1') -Workflow $workflow -StepName $step
    # The clean-caches step must keep the seeded native OCCT runtime (CI builds it in a later step instead).
    if ($step -eq 'Clean local caches used for packaging') { $body = "`$seedKeep = Join-Path `$env:APPDATA 'SAM'`r`n" + $body.Replace("(Join-Path `$env:APPDATA 'SAM'),", '') }
    # GitHub's pwsh shell appends this to every run block, so a failing native command fails the step.
    $body += "`r`nif ((Test-Path -LiteralPath variable:\LASTEXITCODE)) { exit `$LASTEXITCODE }`r`n"
    $file = Join-Path $Out ("logs\step-{0:00}.ps1" -f $results.Count)
    Set-Content -LiteralPath $file -Value $body -Encoding UTF8
    $stepLog = [IO.Path]::ChangeExtension($file, '.log')
    if ($step -like 'Rebuild*' -or $step -like 'Restore*' -or $step -like 'Stage Benchmark*') { $env:MSBUILDDISABLENODEREUSE = '1' }
    Log "RUN  $step"
    $started = Get-Date
    Push-Location $deploy
    try { & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $file *> $stepLog; $code = $LASTEXITCODE } finally { Pop-Location }
    $line = "{0,-5} {1} ({2:0} s, exit {3})" -f $(if ($code -eq 0) { 'OK' } else { 'FAIL' }), $step, ((Get-Date) - $started).TotalSeconds, $code
    Log $line; $results += $line
    if ($code -ne 0) { break }
}
$results | Set-Content -Encoding UTF8 (Join-Path $Out 'logs\steps.txt')
$results
