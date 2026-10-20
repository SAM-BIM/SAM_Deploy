param(
    [string] $Installer,
    [string] $Root = 'C:\TasOut\s06\installer-exe',
    [ValidateSet('Install', 'Uninstall')] [string] $Mode = 'Install'
)
# S06 harness: run the genuine Inno Setup installer (or its uninstaller) silently in an isolated profile.
# Inno resolves {userappdata}/{userdocs} through SHGetFolderPath, which expands the registry's %USERPROFILE%-based shell
# folders from the process environment; USERPROFILE/APPDATA/LOCALAPPDATA/TEMP therefore point into $Root\Profile, so
# {userappdata} = $Root\Profile\AppData\Roaming. The script refuses to run unless a native SHGetFolderPath probe in the
# same environment resolves into $Root. The only state outside $Root is Inno's HKCU uninstall key (AppId
# {{6770DD83-5694-4607-8703-B3D3AC3CFD3C}} in the .iss, a literal "}}" in the key name), which must be absent before Install and is removed again by Uninstall.
# The owner's real folders the .iss writes to are listed (path, size, write time) before and after; any difference fails.
$ErrorActionPreference = 'Stop'
$profileDir = Join-Path $Root 'Profile'
$roaming = Join-Path $profileDir 'AppData\Roaming'
$local = Join-Path $profileDir 'AppData\Local'
$temp = Join-Path $local 'Temp'
$uninstallKey = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\{6770DD83-5694-4607-8703-B3D3AC3CFD3C}}_is1'
$realRoaming = [Environment]::GetFolderPath('ApplicationData')
$realDocs = [Environment]::GetFolderPath('MyDocuments')
if ($realRoaming.StartsWith($Root, 'OrdinalIgnoreCase')) { throw 'this shell is already redirected' }
$watched = @("$realRoaming\SAM", "$realRoaming\Grasshopper", "$realRoaming\McNeel\Rhinoceros\packages", "$realRoaming\Autodesk\Revit\Addins", "$realDocs\SAM")

function Get-Listing {
    foreach ($w in $watched) {
        if (Test-Path $w) {
            Get-ChildItem $w -Recurse -Force -File -ErrorAction SilentlyContinue |
                ForEach-Object { "{0}`t{1}`t{2:o}" -f $_.FullName, $_.Length, $_.LastWriteTimeUtc }
        } else { "$w`t<absent>" }
    }
}

function Start-Isolated([string] $exe, [string] $arguments) {
    $psi = New-Object System.Diagnostics.ProcessStartInfo $exe, $arguments
    $psi.UseShellExecute = $false
    $psi.RedirectStandardOutput = $true
    foreach ($kv in @{ USERPROFILE = $profileDir; APPDATA = $roaming; LOCALAPPDATA = $local; TEMP = $temp; TMP = $temp }.GetEnumerator()) {
        $psi.EnvironmentVariables[$kv.Key] = $kv.Value
    }
    $p = [Diagnostics.Process]::Start($psi)
    $out = $p.StandardOutput.ReadToEnd()
    $p.WaitForExit()
    [pscustomobject]@{ ExitCode = $p.ExitCode; Output = $out }
}

foreach ($d in $roaming, $temp, "$profileDir\Desktop", "$profileDir\Documents", "$profileDir\Downloads") { New-Item -ItemType Directory -Force $d | Out-Null }
$probeScript = Join-Path $temp 'shell-folder-probe.ps1'
Set-Content $probeScript -Value @'
Add-Type -Namespace P -Name S -MemberDefinition '[DllImport("shell32.dll", CharSet=CharSet.Unicode)] public static extern int SHGetFolderPathW(System.IntPtr h, int csidl, System.IntPtr t, int f, System.Text.StringBuilder p);'
foreach ($c in 0x1A, 0x05) { $sb = New-Object System.Text.StringBuilder 520; [void][P.S]::SHGetFolderPathW([IntPtr]::Zero, $c, [IntPtr]::Zero, 0, $sb); $sb.ToString() }
'@
$probe = (Start-Isolated 'powershell.exe' "-NoProfile -ExecutionPolicy Bypass -File `"$probeScript`"").Output -split "`r?`n" | Where-Object { $_ }
"SHGetFolderPath in the isolated environment: APPDATA=$($probe[0]) PERSONAL=$($probe[1])"
if ($probe[0] -ne $roaming -or $probe[1] -ne "$profileDir\Documents") { throw "shell folders do not resolve into $Root; refusing to run the installer" }

$before = Get-Listing
$tag = $Mode.ToLowerInvariant()
if ($Mode -eq 'Install') {
    if (-not $Installer) { throw '-Installer is required for Install' }
    if (Test-Path $uninstallKey) { throw "an Inno registration for SAM already exists ($uninstallKey); refusing to overwrite it" }
    $log = Join-Path $Root 'install.log'
    $r = Start-Isolated $Installer "/VERYSILENT /SUPPRESSMSGBOXES /NORESTART /SP- /DIR=`"$roaming\SAM`" /LOG=`"$log`""
} else {
    $uninstaller = Join-Path $roaming 'SAM\unins000.exe'
    $log = Join-Path $Root 'uninstall.log'
    $r = Start-Isolated $uninstaller "/VERYSILENT /SUPPRESSMSGBOXES /NORESTART /LOG=`"$log`""
    # The uninstaller copies itself to TEMP and returns at once; wait for the copy to finish.
    $deadline = (Get-Date).AddMinutes(10)
    while ((Test-Path $uninstallKey) -and (Get-Date) -lt $deadline) { Start-Sleep -Seconds 2 }
    while ((Get-Process -ErrorAction SilentlyContinue | Where-Object { $_.Path -like "$temp\*" }) -and (Get-Date) -lt $deadline) { Start-Sleep -Seconds 2 }
}
$after = Get-Listing
"$Mode exit code: $($r.ExitCode)"
$diff = Compare-Object $before $after
"owner's real folders: $($before.Count) entries before, $($after.Count) after, $(@($diff).Count) differences"
$diff | ForEach-Object { "  $($_.SideIndicator) $($_.InputObject)" }
if (Test-Path $uninstallKey) {
    $k = Get-ItemProperty $uninstallKey
    "HKCU uninstall key present: DisplayVersion=$($k.DisplayVersion) InstallLocation=$($k.InstallLocation) AppPath=$($k.'Inno Setup: App Path')"
} else { 'HKCU uninstall key absent' }
if ($Mode -eq 'Install') {
    $files = Get-ChildItem "$roaming\SAM" -Recurse -File
    "{0} files, {1:0.0} MB in {{userappdata}}\SAM" -f $files.Count, (($files | Measure-Object Length -Sum).Sum / 1MB)
    $files | ForEach-Object { "{0}`t{1}`t{2}" -f $_.FullName.Substring($roaming.Length + 5), $_.Length, (Get-FileHash $_.FullName -Algorithm SHA256).Hash } |
        Set-Content -Encoding UTF8 (Join-Path $Root 'installed-manifest.tsv')
    Get-ChildItem $roaming -Directory | ForEach-Object { $n = @(Get-ChildItem $_.FullName -Recurse -File).Count; "  {{userappdata}}\{0}: {1} files" -f $_.Name, $n }
} else {
    "{userappdata}\SAM after uninstall: $(if (Test-Path "$roaming\SAM") { @(Get-ChildItem "$roaming\SAM" -Recurse -File).Count.ToString() + ' files left' } else { 'removed' })"
}
if ($r.ExitCode -ne 0 -or @($diff).Count -ne 0) { exit 1 }
