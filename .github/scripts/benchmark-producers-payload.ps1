# Benchmark producers payload: stage and gate (roadmap S06).
#
# SAM_UI's Run Simulation > Both launches two engine producers, benchmark-tas.exe (SAM_Tas) and
# benchmark-openstudio.exe (SAM_OpenStudio), which each write a B1a document over SAM_Validation's
# SAM.Analytical.Benchmark.dll. SAM_UI looks for them beside SAM Analytical.exe (AppContext.BaseDirectory,
# i.e. the installed %APPDATA%\SAM) when SAM_BENCHMARK_TAS / SAM_BENCHMARK_OPENSTUDIO are not set.
# BuildAll_Release builds both, but nothing copies them into %APPDATA%\SAM, so the payload never had them.
#
# SAM Analytical.exe is self-contained (SelfContained=true), so the payload root holds its private .NET
# runtime (hostfxr.dll, coreclr.dll, ...). A framework-dependent apphost placed there finds that hostfxr.dll,
# runs as self-contained and fails ("You must install or update .NET"), and the installer installs no .NET.
# The producers are therefore published self-contained for win-x64 over the SAM assemblies BuildAll already
# built (BuildProjectReferences=false), and run on the app's runtime.
#
# Each producer resolves its samCommit from the +revision of SAM.Analytical.dll's InformationalVersion,
# which only a stamped (SAM_Deploy CI) build carries; a developer build needs a manual SAM_COMMIT.
#
# -Mode Stage  publishes each producer to <PublishRoot>\<name>, copies its own files
#              (<name>.exe/.dll/.runtimeconfig.json/.deps.json) to the payload root, and copies any file of its
#              dependency closure the payload does not already have. An existing payload file is never
#              overwritten; Assert reports a different copy.
# -Mode Assert reports (never changes) that, for each producer:
#   1. its own files are at the payload root and equal its published output;
#   2. its runtimeconfig.json is self-contained (includedFrameworks, no framework reference) and has no
#      additionalProbingPaths, and no <name>.runtimeconfig.dev.json is staged;
#   3. every file of its dependency closure is in the payload: the runtime and native assets its deps.json
#      lists (RID-specific win/win-x64 assets under their relative path, the rest at the payload root), plus,
#      for a producer whose output holds only its own closure (benchmark-openstudio), every other DLL there
#      (the OpenStudio SDK native libraries come from the package's targets, not from deps.json);
#   4. each SAM-owned dependency (SAM.*) and the runtime host (hostfxr, hostpolicy, coreclr, clrjit,
#      System.Private.CoreLib) is byte-identical to the one the producer was published with, and any other
#      differing copy is not an older assembly version;
#   5. with -InformationalVersion: the producer is stamped with it, and the payload's SAM.Analytical.dll
#      carries a +<hex> revision, so the producer reports samCommit without SAM_COMMIT;
#   6. the staged producer starts from the payload (the .NET host resolves it): "--help" exits 0.
# Exit code 1 on any failure.

param(
    [Parameter(Mandatory = $true)]
    [ValidateSet('Stage', 'Assert')]
    [string]$Mode,

    [Parameter(Mandatory = $true)]
    [string]$PayloadRoot,

    [Parameter(Mandatory = $true)]
    [string]$RepoRoot,

    [string]$PublishRoot = '',

    [string]$Configuration = 'Release',

    [string]$InformationalVersion = '',

    [string]$MSBuild = 'msbuild'
)

$ErrorActionPreference = 'Stop'

foreach ($p in @($PayloadRoot, $RepoRoot)) {
    if (-not (Test-Path -LiteralPath $p)) { throw "Path not found: $p" }
}
$PayloadRoot = (Resolve-Path -LiteralPath $PayloadRoot).Path
$RepoRoot = (Resolve-Path -LiteralPath $RepoRoot).Path
if (-not $PublishRoot) { $PublishRoot = Join-Path $RepoRoot 'SAM_Installer\benchmark-producers' }

$producers = @(
    [pscustomobject]@{ Name = 'benchmark-tas'; Project = (Join-Path $RepoRoot 'SAM_Tas\benchmark\SAM.Analytical.Tas.Benchmark.Cli\SAM.Analytical.Tas.Benchmark.Cli.csproj'); Platform = ''; OwnClosureFolder = $false },
    [pscustomobject]@{ Name = 'benchmark-openstudio'; Project = (Join-Path $RepoRoot 'SAM_OpenStudio\benchmark\SAM.Analytical.OpenStudio.Benchmark\SAM.Analytical.OpenStudio.Benchmark.csproj'); Platform = 'x64'; OwnClosureFolder = $true }
)
$ownSuffixes = @('.exe', '.dll', '.runtimeconfig.json', '.deps.json')
$runtimeHost = @('hostfxr.dll', 'hostpolicy.dll', 'coreclr.dll', 'clrjit.dll', 'System.Private.CoreLib.dll')

$failures = New-Object System.Collections.Generic.List[string]
function Fail([string]$message) { $failures.Add($message); Write-Host "FAIL: $message" }

function Get-Sha([string]$path) { (Get-FileHash -LiteralPath $path -Algorithm SHA256).Hash }

function Get-AssemblyVersion([string]$path) {
    try { return [Reflection.AssemblyName]::GetAssemblyName($path).Version } catch { return $null }
}

# Relative payload path -> assembly version the producer was published with (null when not managed or not listed).
function Get-Closure([string]$directory, $producer) {
    $result = [ordered]@{}
    $deps = Get-Content -LiteralPath (Join-Path $directory "$($producer.Name).deps.json") -Raw | ConvertFrom-Json
    $target = $deps.targets.($deps.runtimeTarget.name)
    foreach ($library in $target.PSObject.Properties) {
        if ($library.Name -like "$($producer.Name)/*") { continue }
        $value = $library.Value
        if ($value.PSObject.Properties['runtime']) {
            foreach ($asset in $value.runtime.PSObject.Properties) { $result[[IO.Path]::GetFileName($asset.Name)] = $asset.Value.assemblyVersion }
        }
        if ($value.PSObject.Properties['native']) {
            foreach ($asset in $value.native.PSObject.Properties) { $result[[IO.Path]::GetFileName($asset.Name)] = $null }
        }
        if ($value.PSObject.Properties['runtimeTargets']) {
            foreach ($asset in $value.runtimeTargets.PSObject.Properties) {
                if ($asset.Value.rid -in @('win', 'win-x64')) { $result[$asset.Name.Replace('/', '\')] = $asset.Value.assemblyVersion }
            }
        }
    }
    if ($producer.OwnClosureFolder) {
        foreach ($file in Get-ChildItem -LiteralPath $directory -Filter '*.dll' -File) {
            if (($file.BaseName -ne $producer.Name) -and -not $result.Contains($file.Name)) { $result[$file.Name] = $null }
        }
    }
    return $result
}

foreach ($producer in $producers) {
    Write-Host "--- $($producer.Name) ($Mode) ---"
    $published = Join-Path $PublishRoot $producer.Name

    if ($Mode -eq 'Stage') {
        if (Test-Path -LiteralPath $published) { Remove-Item -LiteralPath $published -Recurse -Force }
        $arguments = @($producer.Project, '/restore', '/t:Publish', '/m:1', '/nr:false', '/v:m',
            "/p:Configuration=$Configuration", '/p:RuntimeIdentifier=win-x64', '/p:SelfContained=true',
            '/p:BuildProjectReferences=false', "/p:PublishDir=$published\", '/p:UseSharedCompilation=false')
        if ($producer.Platform) { $arguments += "/p:Platform=$($producer.Platform)" }
        Write-Host "RUN: $MSBuild $($arguments -join ' ')"
        & $MSBuild @arguments
        if ($LASTEXITCODE -ne 0) { Fail "$($producer.Name): self-contained publish failed (exit $LASTEXITCODE)"; continue }
    }

    Write-Host "published output: $published"
    $ownFiles = @($ownSuffixes | ForEach-Object { "$($producer.Name)$_" })
    $missingOwn = @($ownFiles | Where-Object { -not (Test-Path -LiteralPath (Join-Path $published $_)) })
    if ($missingOwn.Count -gt 0) {
        Fail "$($producer.Name): published output missing $($missingOwn -join ', ') in $published"
        continue
    }
    $closure = Get-Closure $published $producer

    if ($Mode -eq 'Stage') {
        foreach ($name in $ownFiles) {
            Copy-Item -LiteralPath (Join-Path $published $name) -Destination (Join-Path $PayloadRoot $name) -Force
            Write-Host ("STAGED   {0}  {1}" -f (Get-Sha (Join-Path $PayloadRoot $name)).Substring(0, 12), $name)
        }
        $added = 0
        foreach ($relative in $closure.Keys) {
            $destination = Join-Path $PayloadRoot $relative
            if (Test-Path -LiteralPath $destination) { continue }
            $source = Join-Path $published $relative
            if (-not (Test-Path -LiteralPath $source)) { Fail "$($producer.Name): dependency $relative is in neither the payload nor $published"; continue }
            New-Item -ItemType Directory -Force -Path (Split-Path -Parent $destination) | Out-Null
            Copy-Item -LiteralPath $source -Destination $destination
            Write-Host "ADDED    $relative (not in the payload before)"
            $added++
        }
        Write-Host "$($closure.Count) dependencies; $added added; existing payload files left unchanged."
        continue
    }

    foreach ($name in $ownFiles) {
        $staged = Join-Path $PayloadRoot $name
        if (-not (Test-Path -LiteralPath $staged)) { Fail "$($producer.Name): $name is not at the payload root"; continue }
        if ((Get-Sha $staged) -ne (Get-Sha (Join-Path $published $name))) { Fail "$($producer.Name): staged $name differs from its published output" }
    }
    if (Test-Path -LiteralPath (Join-Path $PayloadRoot "$($producer.Name).runtimeconfig.dev.json")) {
        Fail "$($producer.Name): $($producer.Name).runtimeconfig.dev.json is staged (developer probing paths)"
    }
    $runtimeConfigPath = Join-Path $PayloadRoot "$($producer.Name).runtimeconfig.json"
    if (Test-Path -LiteralPath $runtimeConfigPath) {
        $runtimeOptions = (Get-Content -LiteralPath $runtimeConfigPath -Raw | ConvertFrom-Json).runtimeOptions
        if ($runtimeOptions.PSObject.Properties['framework'] -or $runtimeOptions.PSObject.Properties['frameworks'] -or -not $runtimeOptions.PSObject.Properties['includedFrameworks']) {
            Fail "$($producer.Name): runtimeconfig.json is framework-dependent; beside the app's private runtime it cannot start"
        }
        if ($runtimeOptions.PSObject.Properties['additionalProbingPaths']) { Fail "$($producer.Name): runtimeconfig.json declares additionalProbingPaths" }
        if ($runtimeOptions.PSObject.Properties['includedFrameworks']) {
            Write-Host ("RUNTIME  {0}" -f (($runtimeOptions.includedFrameworks | ForEach-Object { "$($_.name) $($_.version)" }) -join ', '))
        }
    }

    $same = 0; $differentOther = 0
    foreach ($relative in $closure.Keys) {
        $staged = Join-Path $PayloadRoot $relative
        $source = Join-Path $published $relative
        if (-not (Test-Path -LiteralPath $staged)) { Fail "$($producer.Name): dependency $relative is missing from the payload"; continue }
        if (-not (Test-Path -LiteralPath $source)) { Fail "$($producer.Name): dependency $relative is missing from its published output"; continue }
        if ((Get-Sha $staged) -eq (Get-Sha $source)) { $same++; continue }
        $leaf = Split-Path -Leaf $relative
        if ($leaf -like 'SAM.*') {
            Fail "$($producer.Name): payload $relative differs from the SAM assembly it was published with (stale or mixed payload)"
            continue
        }
        if ($runtimeHost -contains $leaf) {
            Fail "$($producer.Name): payload $relative differs from the runtime it was published with (app and producer on different .NET runtimes)"
            continue
        }
        $required = if ($closure[$relative]) { [version]$closure[$relative] } else { Get-AssemblyVersion $source }
        $present = Get-AssemblyVersion $staged
        if ($required -and $present -and ($present -lt $required)) {
            Fail "$($producer.Name): payload $relative is assembly version $present, older than the $required it was published with"
        } else {
            Write-Host "NOTE     $relative differs from the producer's copy (payload version $present, published with $required)"
            $differentOther++
        }
    }
    Write-Host "$($closure.Count) dependencies: $same byte-identical, $differentOther other copies differ without an older version."

    if ($InformationalVersion) {
        $productVersion = [Diagnostics.FileVersionInfo]::GetVersionInfo((Join-Path $PayloadRoot "$($producer.Name).dll")).ProductVersion
        if ($productVersion -ne $InformationalVersion) { Fail "$($producer.Name): ProductVersion '$productVersion' is not the build's InformationalVersion '$InformationalVersion'" }
        else { Write-Host "STAMPED  $($producer.Name).dll $productVersion" }
    }

    $exe = Join-Path $PayloadRoot "$($producer.Name).exe"
    if (Test-Path -LiteralPath $exe) {
        $savedPreference = $ErrorActionPreference
        try {
            $ErrorActionPreference = 'Continue'
            $output = @(& $exe --help 2>&1)
            $code = $LASTEXITCODE
        } finally { $ErrorActionPreference = $savedPreference }
        if ($code -ne 0) { Fail "$($producer.Name): '$exe --help' exited $code from the payload: $($output -join ' ')" }
        else { Write-Host "STARTS   $($producer.Name).exe --help exit 0 from the payload" }
    }
}

if ($Mode -eq 'Assert' -and $InformationalVersion) {
    $analytical = Join-Path $PayloadRoot 'SAM.Analytical.dll'
    $productVersion = if (Test-Path -LiteralPath $analytical) { [Diagnostics.FileVersionInfo]::GetVersionInfo($analytical).ProductVersion } else { '' }
    if ($productVersion -notmatch '\+[0-9a-f]{7,64}$') {
        Fail "SAM.Analytical.dll ProductVersion '$productVersion' has no +<hex> revision: the producers would refuse their B1a without SAM_COMMIT"
    } else {
        Write-Host "SAM.Analytical.dll ${productVersion}: the producers report samCommit '$($productVersion.Split('+')[1])' (the SAM_Deploy commit) without SAM_COMMIT"
    }
}

if ($failures.Count -gt 0) {
    Write-Host "::error::Benchmark producers payload $Mode failed: $($failures.Count) problem(s)."
    exit 1
}
Write-Host "Benchmark producers payload $Mode passed."
exit 0
