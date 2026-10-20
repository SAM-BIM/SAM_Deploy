param(
    [string] $Stage = 'C:\TasOut\s06\candidate-build\SAM_Deploy\SAM_Installer',
    [string] $Profile = 'C:\TasOut\s06\candidate'
)
# S06 harness: "install" the staged installer payload into an isolated profile, mirroring the Build_Installer.iss [Files]
# entries the standalone SAM Analytical app uses ({userappdata} -> $Profile\AppData, {userdocs} -> $Profile\Profile\Documents):
#   build\SAM\*                           -> {userappdata}\SAM
#   licenses\OCCT\*                       -> {userappdata}\SAM\licenses\OCCT
#   build\SAMdependencies\*               -> {userappdata}\SAM\SAMdependencies
#   build\user\Documents\SAM\resources\*  -> {userappdata}\SAM\resources
#   build\user\Documents\SAM\*            -> {userdocs}\SAM only if the destination file exists (none in a fresh profile)
# Rhino packages, Grasshopper links, Revit year folders and the [Run] install.bat (Grasshopper library copy) are not
# needed by the standalone app and are not installed. Nothing outside $Profile is written.
$ErrorActionPreference = 'Stop'
if (Test-Path $Profile) { throw "$Profile exists; install into a fresh profile" }
$appData = Join-Path $Profile 'AppData'
foreach ($d in "$appData\SAM", "$Profile\Profile\Desktop", "$Profile\Profile\Documents", "$Profile\Profile\Downloads", "$Profile\LocalAppData") { New-Item -ItemType Directory -Force $d | Out-Null }
function Copy-Tree([string] $from, [string] $to) {
    if (-not (Test-Path $from)) { Write-Host "skip (absent): $from"; return }
    New-Item -ItemType Directory -Force $to | Out-Null
    Copy-Item -Path (Join-Path $from '*') -Destination $to -Recurse -Force
    Write-Host "installed $from -> $to"
}
Copy-Tree "$Stage\build\SAM" "$appData\SAM"
Copy-Tree "$Stage\licenses\OCCT" "$appData\SAM\licenses\OCCT"
Copy-Tree "$Stage\build\SAMdependencies" "$appData\SAM\SAMdependencies"
Copy-Tree "$Stage\build\user\Documents\SAM\resources" "$appData\SAM\resources"
$files = Get-ChildItem "$appData\SAM" -Recurse -File
"{0} files, {1:0.0} MB in {2}" -f $files.Count, (($files | Measure-Object Length -Sum).Sum / 1MB), "$appData\SAM"
$files | ForEach-Object { "{0}`t{1}`t{2}" -f $_.FullName.Substring($appData.Length + 5), $_.Length, (Get-FileHash $_.FullName -Algorithm SHA256).Hash } |
    Set-Content -Encoding UTF8 (Join-Path $Profile 'installed-manifest.tsv')
