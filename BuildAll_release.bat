@echo off
::set msbuildexe=C:\Program Files\Microsoft Visual Studio\2022\Enterprise\MSBuild\Current\Bin\msbuild
set msbuildexe=C:\Program Files\Microsoft Visual Studio\2022\Community\MSBuild\Current\Bin\MSBuild.exe

echo Building all SAM Solutions
::"%msbuildexe%" -t:Restore;Rebuild BuildAll_Release.csproj

"%msbuildexe%" -t:Restore;Rebuild BuildAll_Release_net.csproj
