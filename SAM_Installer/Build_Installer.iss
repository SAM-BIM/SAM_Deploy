#ifndef Version
  #define Version "v_local"
#endif
#ifndef AppVersion
  #define AppVersion Version
#endif

[Setup]
AppId={{6770DD83-5694-4607-8703-B3D3AC3CFD3C}}
AppName=SAM
AppPublisher=SAM-BIM
AppVersion={#AppVersion}
DefaultDirName={userappdata}\SAM
DisableDirPage=yes
DefaultGroupName=SAM
DisableProgramGroupPage=yes
Compression=lzma
SolidCompression=yes
PrivilegesRequired=lowest
SetupIconFile={#SourcePath}SAM20new.ico
; IMPORTANT: no OutputBaseFileName here (CI passes /F)

[Dirs]
; main app
Name: "{userappdata}\SAM"

; Grasshopper user libraries + per-year (Inside-Revit) library folders
Name: "{userappdata}\Grasshopper\Libraries"
Name: "{userappdata}\Grasshopper\Libraries-Inside-Revit-2020"
Name: "{userappdata}\Grasshopper\Libraries-Inside-Revit-2021"
Name: "{userappdata}\Grasshopper\Libraries-Inside-Revit-2022"
Name: "{userappdata}\Grasshopper\Libraries-Inside-Revit-2023"
Name: "{userappdata}\Grasshopper\Libraries-Inside-Revit-2024"
Name: "{userappdata}\Grasshopper\Libraries-Inside-Revit-2025"
Name: "{userappdata}\Grasshopper\Libraries-Inside-Revit-2026"

; Revit addins: RhinoInside.Revit destination folders
Name: "{userappdata}\Autodesk\Revit\Addins\2020\RhinoInside.Revit"
Name: "{userappdata}\Autodesk\Revit\Addins\2021\RhinoInside.Revit"
Name: "{userappdata}\Autodesk\Revit\Addins\2022\RhinoInside.Revit"
Name: "{userappdata}\Autodesk\Revit\Addins\2023\RhinoInside.Revit"
Name: "{userappdata}\Autodesk\Revit\Addins\2024\RhinoInside.Revit"
Name: "{userappdata}\Autodesk\Revit\Addins\2025\RhinoInside.Revit"
Name: "{userappdata}\Autodesk\Revit\Addins\2026\RhinoInside.Revit"

[Files]
; staged under SAM_Installer\build by the workflow
Source: "build\SAM\*";                 DestDir: "{userappdata}\SAM";                                Flags: ignoreversion recursesubdirs createallsubdirs skipifsourcedoesntexist
Source: "build\SAMdependencies\*";     DestDir: "{userappdata}\SAM\SAMdependencies";                Flags: ignoreversion recursesubdirs createallsubdirs skipifsourcedoesntexist
Source: "build\Rhino.Inside\*";        DestDir: "{userappdata}\SAM\Rhino.Inside";                   Flags: ignoreversion recursesubdirs createallsubdirs skipifsourcedoesntexist
Source: "build\SAM_Rhino_UI\*";        DestDir: "{userappdata}\McNeel\Rhinoceros\packages\7.0\SAM"; Flags: ignoreversion recursesubdirs createallsubdirs skipifsourcedoesntexist
Source: "build\SAM_Rhino_UI\*";        DestDir: "{userappdata}\McNeel\Rhinoceros\packages\8.0\SAM"; Flags: ignoreversion recursesubdirs createallsubdirs skipifsourcedoesntexist
Source: "build\register.bat";          DestDir: "{userappdata}\SAM";                                Flags: ignoreversion skipifsourcedoesntexist
Source: "build\deregister.bat";        DestDir: "{userappdata}\SAM";                                Flags: ignoreversion skipifsourcedoesntexist
Source: "build\user\Documents\SAM\*";  DestDir: "{userdocs}\SAM";                                   Flags: onlyifdoesntexist recursesubdirs createallsubdirs skipifsourcedoesntexist

; --- Deploy Rhino.Inside into each Revit Addins folder and rename GH dll to .gha ---
; 2020
Source: "build\Rhino.Inside\Revit 2020\*"; Excludes: "RhinoInside.Revit.GH.dll"; \
  DestDir: "{userappdata}\Autodesk\Revit\Addins\2020\RhinoInside.Revit"; \
  Flags: ignoreversion recursesubdirs createallsubdirs skipifsourcedoesntexist
Source: "build\Rhino.Inside\Revit 2020\RhinoInside.Revit.GH.dll"; \
  DestDir: "{userappdata}\Autodesk\Revit\Addins\2020\RhinoInside.Revit"; DestName: "RhinoInside.Revit.GH.gha"; \
  Flags: ignoreversion skipifsourcedoesntexist
; 2021
Source: "build\Rhino.Inside\Revit 2021\*"; Excludes: "RhinoInside.Revit.GH.dll"; \
  DestDir: "{userappdata}\Autodesk\Revit\Addins\2021\RhinoInside.Revit"; \
  Flags: ignoreversion recursesubdirs createallsubdirs skipifsourcedoesntexist
Source: "build\Rhino.Inside\Revit 2021\RhinoInside.Revit.GH.dll"; \
  DestDir: "{userappdata}\Autodesk\Revit\Addins\2021\RhinoInside.Revit"; DestName: "RhinoInside.Revit.GH.gha"; \
  Flags: ignoreversion skipifsourcedoesntexist
; 2022
Source: "build\Rhino.Inside\Revit 2022\*"; Excludes: "RhinoInside.Revit.GH.dll"; \
  DestDir: "{userappdata}\Autodesk\Revit\Addins\2022\RhinoInside.Revit"; \
  Flags: ignoreversion recursesubdirs createallsubdirs skipifsourcedoesntexist
Source: "build\Rhino.Inside\Revit 2022\RhinoInside.Revit.GH.dll"; \
  DestDir: "{userappdata}\Autodesk\Revit\Addins\2022\RhinoInside.Revit"; DestName: "RhinoInside.Revit.GH.gha"; \
  Flags: ignoreversion skipifsourcedoesntexist
; 2023
Source: "build\Rhino.Inside\Revit 2023\*"; Excludes: "RhinoInside.Revit.GH.dll"; \
  DestDir: "{userappdata}\Autodesk\Revit\Addins\2023\RhinoInside.Revit"; \
  Flags: ignoreversion recursesubdirs createallsubdirs skipifsourcedoesntexist
Source: "build\Rhino.Inside\Revit 2023\RhinoInside.Revit.GH.dll"; \
  DestDir: "{userappdata}\Autodesk\Revit\Addins\2023\RhinoInside.Revit"; DestName: "RhinoInside.Revit.GH.gha"; \
  Flags: ignoreversion skipifsourcedoesntexist
; 2024
Source: "build\Rhino.Inside\Revit 2024\*"; Excludes: "RhinoInside.Revit.GH.dll"; \
  DestDir: "{userappdata}\Autodesk\Revit\Addins\2024\RhinoInside.Revit"; \
  Flags: ignoreversion recursesubdirs createallsubdirs skipifsourcedoesntexist
Source: "build\Rhino.Inside\Revit 2024\RhinoInside.Revit.GH.dll"; \
  DestDir: "{userappdata}\Autodesk\Revit\Addins\2024\RhinoInside.Revit"; DestName: "RhinoInside.Revit.GH.gha"; \
  Flags: ignoreversion skipifsourcedoesntexist
; 2025
Source: "build\Rhino.Inside\Revit 2025\*"; Excludes: "RhinoInside.Revit.GH.dll"; \
  DestDir: "{userappdata}\Autodesk\Revit\Addins\2025\RhinoInside.Revit"; \
  Flags: ignoreversion recursesubdirs createallsubdirs skipifsourcedoesntexist
Source: "build\Rhino.Inside\Revit 2025\RhinoInside.Revit.GH.dll"; \
  DestDir: "{userappdata}\Autodesk\Revit\Addins\2025\RhinoInside.Revit"; DestName: "RhinoInside.Revit.GH.gha"; \
  Flags: ignoreversion skipifsourcedoesntexist
; 2026
Source: "build\Rhino.Inside\Revit 2026\*"; Excludes: "RhinoInside.Revit.GH.dll"; \
  DestDir: "{userappdata}\Autodesk\Revit\Addins\2026\RhinoInside.Revit"; \
  Flags: ignoreversion recursesubdirs createallsubdirs skipifsourcedoesntexist
Source: "build\Rhino.Inside\Revit 2026\RhinoInside.Revit.GH.dll"; \
  DestDir: "{userappdata}\Autodesk\Revit\Addins\2026\RhinoInside.Revit"; DestName: "RhinoInside.Revit.GH.gha"; \
  Flags: ignoreversion skipifsourcedoesntexist

[Run]
Filename: "{userappdata}\SAM\SAMdependencies\install.bat"; \
  WorkingDir: "{userappdata}\SAM\SAMdependencies"; Flags: runascurrentuser runhidden; \
  Check: FileExists(ExpandConstant('{userappdata}\SAM\SAMdependencies\install.bat'))
Filename: "{userappdata}\SAM\register.bat"; \
  WorkingDir: "{userappdata}\SAM"; Flags: runascurrentuser runhidden; \
  Check: FileExists(ExpandConstant('{userappdata}\SAM\register.bat'))

[UninstallRun]
Filename: "{userappdata}\SAM\deregister.bat"; \
  WorkingDir: "{userappdata}\SAM"; Flags: runascurrentuser runhidden; \
  Check: FileExists(ExpandConstant('{userappdata}\SAM\deregister.bat'))

[UninstallDelete]
Type: filesandordirs; Name: "{userappdata}\SAM"

[Code]
procedure CreateSamGhLink;
var
  GhDir, SamDir, Content: string;
begin
  GhDir := ExpandConstant('{userappdata}\Grasshopper\Libraries\');
  SamDir := ExpandConstant('{userappdata}\SAM\');
  if not DirExists(GhDir) then
    ForceDirectories(GhDir);
  Content :=
    '#Order of files is important or just folder' + #13#10 +
    SamDir + #13#10;
  SaveStringToFile(GhDir + 'SAM.ghlink', Content, False);
end;

procedure CreateRevitGhLink(const Year: string);
var
  GhYearDir, SamDir, Content: string;
begin
  SamDir   := ExpandConstant('{userappdata}\SAM\');
  GhYearDir := ExpandConstant('{userappdata}\Grasshopper\Libraries-Inside-Revit-') + Year + '\';
  if not DirExists(GhYearDir) then
    ForceDirectories(GhYearDir);

  Content :=
    '#Order of files is important' + #13#10 +
    SamDir + 'Revit ' + Year + '\SAM.Core.Grasshopper.Revit.gha' + #13#10 +
    SamDir + 'Revit ' + Year + '\SAM.Architectural.Grasshopper.Revit.gha' + #13#10 +
    SamDir + 'Revit ' + Year + '\SAM.Analytical.Grasshopper.Revit.gha' + #13#10;

  SaveStringToFile(GhYearDir + 'SAM_Revit.ghlink', Content, False);
end;

procedure CurStepChanged(CurStep: TSetupStep);
begin
  if CurStep = ssPostInstall then
  begin
    CreateSamGhLink();
    CreateRevitGhLink('2020');
    CreateRevitGhLink('2021');
    CreateRevitGhLink('2022');
    CreateRevitGhLink('2023');
    CreateRevitGhLink('2024');
    CreateRevitGhLink('2025');
    CreateRevitGhLink('2026');
  end;
end;
