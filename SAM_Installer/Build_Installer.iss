; ================================
; SAM — Inno Setup installer
; ================================

#ifndef Version
  #define Version "0.0.0"
#endif
#ifndef AppVersion
  #define AppVersion Version
#endif
#ifndef samversion
  #define samversion AppVersion
#endif
#ifndef SourceRoot
  #define SourceRoot "."
#endif
#ifndef FileVersion
  #define FileVersion "1.0.0.0"
#endif

[Setup]
AppId={{6770DD83-5694-4607-8703-B3D3AC3CFD3C}}           ; NOTE: double closing braces }}
AppName=SAM
AppPublisher=SAM-BIM
AppPublisherURL=https://github.com/SAM-BIM/SAM
AppSupportURL=https://github.com/SAM-BIM/SAM
AppUpdatesURL=https://github.com/SAM-BIM/SAM

; Use the tag as visible version and in file metadata as text
AppVersion={#AppVersion}
VersionInfoTextVersion={#AppVersion}

DefaultDirName={userappdata}\SAM
DisableDirPage=yes
DefaultGroupName=SAM
DisableProgramGroupPage=yes
OutputBaseFilename=SAM_Install
Compression=lzma
SolidCompression=yes
PrivilegesRequired=lowest
SetupIconFile={#SourceRoot}\SAM_Installer\SAM20new.ico

[Dirs]
Name: "{userappdata}\SAM"

[Files]
; Copy from staging created at SAM_Installer\build by the workflow
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
