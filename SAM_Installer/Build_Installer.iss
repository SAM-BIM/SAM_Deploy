; ================================
; SAM — Inno Setup installer
; ================================

#ifndef Version
  #define Version "0.0.0"
#endif
#ifndef AppVersion
  #define AppVersion Version
#endif
#ifndef SourceRoot
  #define SourceRoot "."
#endif

[Setup]
; NOTE: double closing braces on AppId
AppId={{6770DD83-5694-4607-8703-B3D3AC3CFD3C}}

AppName=SAM
AppPublisher=SAM-BIM
AppPublisherURL=https://github.com/SAM-BIM/SAM
AppSupportURL=https://github.com/SAM-BIM/SAM
AppUpdatesURL=https://github.com/SAM-BIM/SAM

; Visible version (your tag, e.g., v20251126.1)
AppVersion={#AppVersion}
; Keep file versioning out of the way to avoid validation problems
; (We can reintroduce VersionInfoVersion later once the build is green)
; VersionInfoTextVersion shows the tag in EXE metadata
; VersionInfoTextVersion={#AppVersion}
VersionInfoVersion=1.0.0.0


DefaultDirName={userappdata}\SAM
DisableDirPage=yes
DefaultGroupName=SAM
DisableProgramGroupPage=yes
OutputBaseFilename=SAM_Install
Compression=lzma
SolidCompression=yes
PrivilegesRequired=lowest

; IMPORTANT: relative to THIS .iss file
SetupIconFile=SAM20new.ico

[Dirs]
Name: "{userappdata}\SAM"

; ----------------
; Files copied from CI staging created at: SAM_Installer\build\...
; ----------------
[Files]
Source: "{#SourceRoot}\SAM_Installer\build\SAM\*";               DestDir: "{userappdata}\SAM"; Flags: ignoreversion recursesubdirs createallsubdirs
Source: "{#SourceRoot}\SAM_Installer\build\SAMdependencies\*";   DestDir: "{userappdata}\SAM\SAMdependencies"; Flags: ignoreversion recursesubdirs createallsubdirs
Source: "{#SourceRoot}\SAM_Installer\build\Rhino.Inside\*";      DestDir: "{userappdata}\SAM\Rhino.Inside";    Flags: ignoreversion recursesubdirs createallsubdirs
Source: "{#SourceRoot}\SAM_Installer\build\register.bat";        DestDir: "{userappdata}\SAM"
Source: "{#SourceRoot}\SAM_Installer\build\deregister.bat";      DestDir: "{userappdata}\SAM"
Source: "{#SourceRoot}\SAM_Installer\build\SAM_Rhino_UI\*";      DestDir: "{userappdata}\McNeel\Rhinoceros\packages\7.0\SAM"; Flags: ignoreversion recursesubdirs createallsubdirs
Source: "{#SourceRoot}\SAM_Installer\build\SAM_Rhino_UI\*";      DestDir: "{userappdata}\McNeel\Rhinoceros\packages\8.0\SAM"; Flags: ignoreversion recursesubdirs createallsubdirs
Source: "{#SourceRoot}\SAM_Installer\build\user\Documents\*";    DestDir: "{userdocs}"; Flags: onlyifdoesntexist recursesubdirs createallsubdirs

[Run]
Filename: "register.bat"; WorkingDir: "{userappdata}\SAM";                 Flags: runascurrentuser runhidden
Filename: "install.bat";  WorkingDir: "{userappdata}\SAM\SAMdependencies"; Flags: runascurrentuser runhidden; Check: FileExists(ExpandConstant('{userappdata}\SAM\SAMdependencies\install.bat'))

[UninstallRun]
Filename: "deregister.bat"; WorkingDir: "{userappdata}\SAM"; Flags: runascurrentuser runhidden; Check: FileExists(ExpandConstant('{userappdata}\SAM\deregister.bat'))

[UninstallDelete]
Type: filesandordirs; Name: "{userappdata}\SAM"
