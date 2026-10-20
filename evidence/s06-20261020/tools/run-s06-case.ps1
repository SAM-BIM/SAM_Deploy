param(
    [Parameter(Mandatory)] [string] $Name,
    [Parameter(Mandatory)] [ValidateSet('TasRunSimulation', 'OpenStudio', 'Both')] [string] $Kind,
    [Parameter(Mandatory)] [ValidateSet('dev', 'installed')] [string] $Candidate,
    [string] $Model = 'C:\TasOut\s06\inputs\box-aperture.json',
    [string] $EpwPath = '',
    [int] $TimeoutMinutes = 20
)
# S06 smoke case (test harness). Reuses the S05/S01b drivers unchanged.
#   dev       = BuildAll_v5's own deployment (sandbox %APPDATA%\SAM), developer-built producers chosen by SAM_BENCHMARK_*,
#               OpenStudio 3.10 first on PATH and SAM_COMMIT for Both (owner decision 2026-10-20, until S06) - the S05 setup.
#   installed = the staged S06 candidate installed into an isolated profile: no SAM_BENCHMARK_*, no SAM_COMMIT, ladybug's
#               OpenStudio 3.11 deliberately FIRST on PATH (3.10 second), .NET host tracing on to show where every assembly
#               of the app and the producers resolves from.
$ErrorActionPreference = 'Stop'
$S06 = 'C:\TasOut\s06'
$R = Join-Path $S06 "runs\$Name"
if (Test-Path $R) { throw "$R exists; each case uses a fresh folder" }
New-Item -ItemType Directory -Force $R | Out-Null
$modelCopy = Join-Path $R (Split-Path -Leaf $Model)
Copy-Item $Model $modelCopy
foreach ($v in 'SAM_COMMIT', 'RUNNER_COMMIT', 'SAM_BENCHMARK_TAS', 'SAM_BENCHMARK_OPENSTUDIO', 'COREHOST_TRACE', 'COREHOST_TRACEFILE', 'COREHOST_TRACE_VERBOSITY') {
    Remove-Item "Env:$v" -ErrorAction SilentlyContinue
}
$os310 = '<SAM-BIM>\.icon-migration\runtime\OpenStudio-3.10.0+86d7e215a1-Windows\bin'
$os311 = 'C:\Program Files\ladybug_tools\openstudio\bin'
if ($Candidate -eq 'dev') {
    $env:APPDATA = "$S06\sandbox\AppData"
    $env:USERPROFILE = "$S06\sandbox\Profile"
    $env:SAM_APP_EXE = "$S06\sandbox\AppData\SAM\SAM Analytical.exe"
    $p = Get-Content "$S06\producers-dev.txt"
    $env:SAM_BENCHMARK_TAS = ($p | Select-String '^tas=').ToString().Substring(4)
    $env:SAM_BENCHMARK_OPENSTUDIO = ($p | Select-String '^openstudio=').ToString().Substring(11)
    $env:PATH = "$os310;" + $env:PATH
    if ($Kind -eq 'Both') { $env:SAM_COMMIT = ($p | Select-String '^samCommit=').ToString().Substring(10) }
} else {
    $env:APPDATA = "$S06\candidate\AppData"
    $env:USERPROFILE = "$S06\candidate\Profile"
    $env:LOCALAPPDATA = "$S06\candidate\LocalAppData"
    $env:SAM_APP_EXE = "$S06\candidate\AppData\SAM\SAM Analytical.exe"
    # No developer folder may be on PATH; only the two OpenStudio runtimes are added (3.11 first on purpose).
    $env:PATH = (@($os311, $os310) + @($env:PATH -split ';' | Where-Object { $_ -and $_ -notmatch 'GitHub\\SAM-BIM' })) -join ';'
    $env:COREHOST_TRACE = '1'
    $env:COREHOST_TRACE_VERBOSITY = '3'
    $env:COREHOST_TRACEFILE = Join-Path $R 'corehost-trace.txt'
}
$ev = Join-Path $R 'evidence'
$tools = "$S06\tools"
Set-Content (Join-Path $R 'environment.txt') -Encoding UTF8 -Value @(
    "candidate=$Candidate kind=$Kind epw=$EpwPath",
    "SAM_APP_EXE=$env:SAM_APP_EXE", "APPDATA=$env:APPDATA", "USERPROFILE=$env:USERPROFILE",
    "SAM_BENCHMARK_TAS=$env:SAM_BENCHMARK_TAS", "SAM_BENCHMARK_OPENSTUDIO=$env:SAM_BENCHMARK_OPENSTUDIO",
    "SAM_COMMIT=$env:SAM_COMMIT", "PATH=$env:PATH")
Start-Transcript -Path (Join-Path $R 'driver-console.txt') | Out-Null
try {
    switch ($Kind) {
        'TasRunSimulation' { & "$tools\drive-tas.ps1" -ModelPath $modelCopy -EvidenceDir $ev -Entry RunSimulationTas -OutputDirectory "$R\out" -ProjectName box -TimeoutMinutes $TimeoutMinutes }
        'Both' { & "$tools\drive-both.ps1" -ModelPath $modelCopy -EvidenceDir $ev -EpwPath $EpwPath -TimeoutMinutes $TimeoutMinutes }
        'OpenStudio' { & "$tools\drive-s05.ps1" -Scenario OpenStudio -ModelPath $modelCopy -EvidenceDir $ev -EpwPath $EpwPath -TimeoutMinutes $TimeoutMinutes }
    }
} finally {
    Stop-Transcript | Out-Null
}
