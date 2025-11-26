; ================================
; SAM — Inno Setup installer
; ================================

; ---- Safe defaults for CI defines ----
#ifndef Version
  #define Version "0.0.0"
#endif
#ifndef AppVersion
  #define AppVersion Version
#endif
#ifndef SourceRoot
  #define SourceRoot "."
#endif

; ----------------
; Setup metadata
; ----------------
[Setup]
; NOTE: Use double braces around the GUID to emit literal braces
AppId={{6770DD83-5694-4607-8703-B3D3AC3CFD3C}}

AppName=SAM
AppPublisher=SAM-BIM
AppPublisherURL=https://github.com/SAM-BIM/SAM
AppSupportURL=https://github.com/SAM-BIM/SAM
AppUpdatesURL=https://github.com/SAM-BIM/SAM

; CI injects these via /DVersion=... /DAppVersion=...
AppVersion={#AppVersion}
VersionInfoVersion={#Version}

DefaultDirName={userappdata}\SAM
DisableDirPage=yes
DefaultGroupName=SAM
DisableProgramGroupPage=yes

; GitHub Actions step overrides the output filename using /F=
OutputBaseFilename=SAM_Install

Compression=lzma
SolidCompression=yes
PrivilegesRequired=lowest
SetupIconFile=SAM20new.ico

; ----------------
; Directories
; ----------------
[Dirs]
Name: "{userappdata}\SAM"

; ----------------
; Files to install
; ----------------
; We copy from the CI staging area that the workflow creates:
;   SAM_Installer\build\
; If running locally, either pre-create this folder (via your GenBuild.bat)
; or set /DSourceRoot="C:\path\to\repo" when compiling.

[Files]
; Core SAM payload
Source: "{#SourceRoot}\SAM_Installer\build\SAM\*";               DestDir: "{userappdata}\SAM"; Flags: ignoreversion createallsubdirs recursesubdirs

; Dependencies
Source: "{#SourceRoot}\SAM_Installer\build\SAMdependencies\*";   DestDir: "{userappdata}\SAM\SAMdependencies"; Flags: ignoreversion createallsubdirs recursesubdirs
Source: "{#SourceRoot}\SAM_Installer\build\Rhino.Inside\*";      DestDir: "{userappdata}\SAM\Rhino.Inside";    Flags: ignoreversion createallsubdirs recursesubdirs

; Helper scripts
Source: "{#SourceRoot}\SAM_Installer\build\register.bat";        DestDir: "{userappdata}\SAM"
Source: "{#SourceRoot}\SAM_Installer\build\deregister.bat";      DestDir: "{userappdata}\SAM"

; Rhino packages (7 & 8)
Source: "{#SourceRoot}\SAM_Installer\build\SAM_Rhino_UI\*";      DestDir: "{userappdata}\McNeel\Rhinoceros\packages\7.0\SAM"; Flags: ignoreversion createallsubdirs recursesubdirs
Source: "{#SourceRoot}\SAM_Installer\build\SAM_Rhino_UI\*";      DestDir: "{userappdata}\McNeel\Rhinoceros\packages\8.0\SAM"; Flags: ignoreversion createallsubdirs recursesubdirs

; Optional user documents (first install only)
Source: "{#SourceRoot}\SAM_Installer\build\user\Documents\*";    DestDir: "{userdocs}"; Flags: onlyifdoesntexist createallsubdirs recursesubdirs

; ----------------
; Post-install actions
; ----------------
[Run]
; Register add-ins, environment etc. (quiet)
Filename: "register.bat"; WorkingDir: "{userappdata}\SAM";                Flags: runascurrentuser runhidden
Filename: "install.bat";  WorkingDir: "{userappdata}\SAM\SAMdependencies"; Flags: runascurrentuser runhidden; Check: FileExists(ExpandConstant('{userappdata}\SAM\SAMdependencies\install.bat'))

; ----------------
; Uninstall actions
; ----------------
[UninstallRun]
Filename: "deregister.bat"; WorkingDir: "{userappdata}\SAM"; Flags: runascurrentuser runhidden; Check: FileExists(ExpandConstant('{userappdata}\SAM\deregister.bat'))

[UninstallDelete]
Type: filesandordirs; Name: "{userappdata}\SAM"
