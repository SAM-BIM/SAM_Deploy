; ================================
; SAM — Inno Setup installer
; ================================

#ifndef Version
  #define Version "0.0.0"
#endif
#ifndef AppVersion
  #define AppVersion Version
#endif

[Setup]
AppId={{6770DD83-5694-4607-8703-B3D3AC3CFD3C}}
AppName=SAM
AppPublisher=SAM-BIM
AppPublisherURL=https://github.com/SAM-BIM/SAM
AppSupportURL=https://github.com/SAM-BIM/SAM
AppUpdatesURL=https://github.com/SAM-BIM/SAM
AppVersion={#AppVersion}
VersionInfoVersion=1.0.0.0
DefaultDirName={userappdata}\SAM
DisableDirPage=yes
DefaultGroupName=SAM
DisableProgramGroupPage=yes
OutputBaseFilename=setup
Compression=lzma
SolidCompression=yes
PrivilegesRequired=lowest
SetupIconFile={#SourcePath}SAM20new.ico

[Dirs]
Name: "{userappdata}\SAM"

[Files]
; all paths relative to this .iss
Source: "build\SAM\*";                    DestDir: "{userappdata}\SAM";                                Flags: ignoreversion recursesubdirs createallsubdirs skipifsourcedoesntexist
Source: "build\SAMdependencies\*";        DestDir: "{userappdata}\SAM\SAMdependencies";                Flags: ignoreversion recursesubdirs createallsubdirs skipifsourcedoesntexist
Source: "build\Rhino.Inside\*";           DestDir: "{userappdata}\SAM\Rhino.Inside";                   Flags: ignoreversion recursesubdirs createallsubdirs skipifsourcedoesntexist
Source: "build\register.bat";             DestDir: "{userappdata}\SAM";                                Flags: ignoreversion skipifsourcedoesntexist
Source: "build\deregister.bat";           DestDir: "{userappdata}\SAM";                                Flags: ignoreversion skipifsourcedoesntexist
Source: "build\SAM_Rhino_UI\*";           DestDir: "{userappdata}\McNeel\Rhinoceros\packages\7.0\SAM"; Flags: ignoreversion recursesubdirs createallsubdirs skipifsourcedoesntexist
Source: "build\SAM_Rhino_UI\*";           DestDir: "{userappdata}\McNeel\Rhinoceros\packages\8.0\SAM"; Flags: ignoreversion recursesubdirs createallsubdirs skipifsourcedoesntexist
Source: "build\user\Documents\SAM\*";     DestDir: "{userdocs}\SAM";                                   Flags: onlyifdoesntexist recursesubdirs createallsubdirs skipifsourcedoesntexist

[Run]
Filename: "{userappdata}\SAM\register.bat";                WorkingDir: "{userappdata}\SAM";                 Flags: runascurrentuser runhidden; Check: FileExists(ExpandConstant('{userappdata}\SAM\register.bat'))
Filename: "{userappdata}\SAM\SAMdependencies\install.bat"; WorkingDir: "{userappdata}\SAM\SAMdependencies"; Flags: runascurrentuser runhidden; Check: FileExists(ExpandConstant('{userappdata}\SAM\SAMdependencies\install.bat'))

[UninstallRun]
Filename: "{userappdata}\SAM\deregister.bat";              WorkingDir: "{userappdata}\SAM";                 Flags: runascurrentuser runhidden; Check: FileExists(ExpandConstant('{userappdata}\SAM\deregister.bat'))

[UninstallDelete]
Type: filesandordirs; Name: "{userappdata}\SAM"