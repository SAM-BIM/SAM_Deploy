@echo off
setlocal EnableExtensions

rem Usage:
rem   BuildAlls_v4.bat                 -> full Debug RestoreCleanRebuild (start-of-day / cold build)
rem   BuildAlls_v4.bat fast            -> incremental Restore;Build (rebuild only what changed)
rem   BuildAlls_v4.bat pull            -> parallel fast-forward pull, then full RestoreCleanRebuild
rem   BuildAlls_v4.bat pull fast       -> parallel pull, then incremental build
rem   BuildAlls_v4.bat nopause         -> skip final pause (combine with any of the above)
rem   BuildAlls_v4.bat skip2027        -> build Revit 2025/2026 only (see .NET 10 note below)
rem
rem When to use which:
rem   - Start of the day, after big pulls, or "something feels off"  -> no args (full clean rebuild)
rem   - Edited one or a few repos and want to iterate                -> "fast"
rem   - Pulled latest and want to iterate from there                 -> "pull fast"
rem
rem Revit 2027 targets net10.0-windows, so it needs the .NET 10 SDK - not just the
rem .NET 10 runtime. Without it MSBuild fails NETSDK1045 on the first 2027 project.
rem This script checks up front and stops with that message rather than letting the
rem whole build die halfway through. Use "skip2027" to knowingly build 2025/2026 only.

set "SCRIPT_DIR=%~dp0"
set "PROJECT=%SCRIPT_DIR%BuildAlls_v4.csproj"
set "STARTTIME=%TIME%"

rem SAM_OCCT native layer requires a configured vcpkg + OpenCASCADE environment,
rem which a normal managed developer build does not need. Native compilation is
rem therefore skipped by default so the managed assemblies still build. To build the
rem native layer, set up vcpkg/OCCT and run with SAM_OCCT_SKIP_NATIVE_BUILD already
rem set to false in your environment.
if not defined SAM_OCCT_SKIP_NATIVE_BUILD set "SAM_OCCT_SKIP_NATIVE_BUILD=true"

set "DO_PULL=0"
set "DO_PAUSE=1"
set "DO_FAST=0"
set "SKIP_2027=0"

:parse_args
if "%~1"=="" goto after_args
if /I "%~1"=="pull"     set "DO_PULL=1"
if /I "%~1"=="nopause"  set "DO_PAUSE=0"
if /I "%~1"=="fast"     set "DO_FAST=1"
if /I "%~1"=="skip2027" set "SKIP_2027=1"
shift
goto parse_args

:after_args
if not exist "%PROJECT%" (
  echo ERROR: BuildAlls_v4.csproj not found at "%PROJECT%"
  exit /b 1
)

if not exist "%SCRIPT_DIR%scripts\Snapshot-RevitBuild.ps1" (
  echo ERROR: scripts\Snapshot-RevitBuild.ps1 not found under "%SCRIPT_DIR%"
  echo        Every Revit year calls it, so the build would fail after compiling 2025.
  exit /b 1
)

if "%SKIP_2027%"=="1" (
  echo.
  echo WARNING: skip2027 requested - Revit 2027 will NOT be built.
  echo          _revitsnap\Revit 2027 will keep whatever an earlier run left there.
) else (
  powershell -NoProfile -Command "if ((dotnet --list-sdks 2>$null) -match '^10\.') { exit 0 } else { exit 1 }"
  if errorlevel 1 (
    echo.
    echo ERROR: Revit 2027 targets net10.0-windows but no .NET 10 SDK is installed.
    echo        The .NET 10 *runtime* alone is not enough - MSBuild needs the SDK
    echo        and its targeting pack, and fails NETSDK1045 without them.
    echo.
    echo        Install the .NET 10 SDK:  https://aka.ms/dotnet/download
    echo        Then re-run this script.
    echo.
    echo        To build Revit 2025/2026 only in the meantime:
    echo            BuildAlls_v4.bat skip2027
    exit /b 1
  )
)

rem Prefer VSWhere to locate the latest MSBuild
set "VSWHERE=%ProgramFiles(x86)%\Microsoft Visual Studio\Installer\vswhere.exe"
set "MSBUILD_EXE="

if exist "%VSWHERE%" (
  for /f "usebackq delims=" %%i in (`"%VSWHERE%" -latest -requires Microsoft.Component.MSBuild -find MSBuild\**\Bin\MSBuild.exe`) do (
    if not defined MSBUILD_EXE set "MSBUILD_EXE=%%i"
  )
)

if not defined MSBUILD_EXE if exist "C:\Program Files\Microsoft Visual Studio\2022\Enterprise\MSBuild\Current\Bin\MSBuild.exe" set "MSBUILD_EXE=C:\Program Files\Microsoft Visual Studio\2022\Enterprise\MSBuild\Current\Bin\MSBuild.exe"
if not defined MSBUILD_EXE if exist "C:\Program Files\Microsoft Visual Studio\2022\Professional\MSBuild\Current\Bin\MSBuild.exe" set "MSBUILD_EXE=C:\Program Files\Microsoft Visual Studio\2022\Professional\MSBuild\Current\Bin\MSBuild.exe"
if not defined MSBUILD_EXE if exist "C:\Program Files\Microsoft Visual Studio\2022\Community\MSBuild\Current\Bin\MSBuild.exe" set "MSBUILD_EXE=C:\Program Files\Microsoft Visual Studio\2022\Community\MSBuild\Current\Bin\MSBuild.exe"

if not defined MSBUILD_EXE (
  echo ERROR: Could not find MSBuild.exe
  exit /b 1
)

echo Using MSBuild:
echo   %MSBUILD_EXE%

if not "%DO_PULL%"=="1" goto after_pull

echo.
echo 1. Fast-forward pulling all SAM repos in parallel
powershell -NoProfile -ExecutionPolicy Bypass -Command ^
  "$ErrorActionPreference='Stop';" ^
  "$repos = Get-ChildItem -Path '%SCRIPT_DIR%' -Directory -Filter 'SAM*';" ^
  "$jobs = $repos | ForEach-Object { Start-Job -ArgumentList $_.FullName, $_.Name -ScriptBlock { param($path,$name); Set-Location $path; git rev-parse --git-dir 2>&1 | Out-Null; if ($LASTEXITCODE -ne 0) { return [pscustomobject]@{ Name=$name; Exit=0; Out='skipped - not a git repo' } }; $branch = (git symbolic-ref --short -q HEAD 2>$null); if ([string]::IsNullOrWhiteSpace($branch)) { return [pscustomobject]@{ Name=$name; Exit=0; Out='skipped - detached HEAD (worktree?), nothing to fast-forward' } }; $out = git pull --ff-only 2>&1; [pscustomobject]@{ Name=$name; Exit=$LASTEXITCODE; Out=($out -join [Environment]::NewLine) } } };" ^
  "$results = $jobs | Wait-Job | Receive-Job;" ^
  "$jobs | Remove-Job;" ^
  "$results | ForEach-Object { Write-Host ('--- ' + $_.Name + ' ---'); Write-Host $_.Out };" ^
  "$failed = $results | Where-Object { $_.Exit -ne 0 };" ^
  "if ($failed) { Write-Host ('ERROR: git pull failed in: ' + (($failed | ForEach-Object Name) -join ', ')); exit 1 }"
if errorlevel 1 (
  echo ERROR: parallel git pull failed
  exit /b 1
)

:after_pull

if "%DO_FAST%"=="1" (
  set "BUILD_TARGET=RestoreBuild"
  set "BUILD_LABEL=incremental Restore;Build"
) else (
  set "BUILD_TARGET=RestoreCleanRebuild"
  set "BUILD_LABEL=full Restore;Clean;Rebuild"
)

echo.
echo 2. Running local Debug %BUILD_LABEL%
"%MSBUILD_EXE%" "%PROJECT%" ^
  /t:%BUILD_TARGET% ^
  /m /nr:false /v:m ^
  /p:RunPostBuildEvent=OnOutputUpdated ^
  /p:SkipRevit2027=%SKIP_2027% ^
  /p:MSBuildExePath="%MSBUILD_EXE%"

if errorlevel 1 (
  echo.
  echo ERROR: BuildAlls_v4 failed.
  set "EXITCODE=1"
) else (
  echo.
  echo BuildAlls_v4 finished successfully.
  set "EXITCODE=0"
)

set "ENDTIME=%TIME%"
echo Start Time: %STARTTIME%
echo End Time:   %ENDTIME%
powershell -NoProfile -Command "$s='%STARTTIME%'; $e='%ENDTIME%'; $st=[datetime]::Parse($s); $et=[datetime]::Parse($e); if($et -lt $st){$et=$et.AddDays(1)}; $dur=$et-$st; Write-Host ('Duration: ' + $dur)"

if "%DO_PAUSE%"=="1" pause
exit /b %EXITCODE%
