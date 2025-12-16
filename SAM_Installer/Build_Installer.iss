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
; (Output filename is passed from CI with /F)

[Dirs]
; Core app
Name: "{userappdata}\SAM"

; SAM\Revit YYYY targets used by ghlink
Name: "{userappdata}\SAM\Revit 2020"
Name: "{userappdata}\SAM\Revit 2021"
Name: "{userappdata}\SAM\Revit 2022"
Name: "{userappdata}\SAM\Revit 2023"
Name: "{userappdata}\SAM\Revit 2024"
Name: "{userappdata}\SAM\Revit 2025"
Name: "{userappdata}\SAM\Revit 2026"

; Resources + GH folders
Name: "{userappdata}\SAM\resources"
Name: "{userappdata}\Grasshopper\Libraries"
Name: "{userappdata}\Grasshopper\UserObjects\SAM"
Name: "{userappdata}\Grasshopper\Libraries-Inside-Revit-2020"
Name: "{userappdata}\Grasshopper\Libraries-Inside-Revit-2021"
Name: "{userappdata}\Grasshopper\Libraries-Inside-Revit-2022"
Name: "{userappdata}\Grasshopper\Libraries-Inside-Revit-2023"
Name: "{userappdata}\Grasshopper\Libraries-Inside-Revit-2024"
Name: "{userappdata}\Grasshopper\Libraries-Inside-Revit-2025"
Name: "{userappdata}\Grasshopper\Libraries-Inside-Revit-2026"

; Rhino user packages (existing behavior)
Name: "{userappdata}\McNeel\Rhinoceros\packages\7.0\SAM"
Name: "{userappdata}\McNeel\Rhinoceros\packages\8.0\SAM"

; Rhino.Inside → Revit Addins (per year)
Name: "{userappdata}\Autodesk\Revit\Addins\2020\RhinoInside.Revit"
Name: "{userappdata}\Autodesk\Revit\Addins\2021\RhinoInside.Revit"
Name: "{userappdata}\Autodesk\Revit\Addins\2022\RhinoInside.Revit"
Name: "{userappdata}\Autodesk\Revit\Addins\2023\RhinoInside.Revit"
Name: "{userappdata}\Autodesk\Revit\Addins\2024\RhinoInside.Revit"
Name: "{userappdata}\Autodesk\Revit\Addins\2025\RhinoInside.Revit"
Name: "{userappdata}\Autodesk\Revit\Addins\2026\RhinoInside.Revit"

[Files]
; ----- staged content (created by workflow) -----
Source: "build\SAM\*";                 DestDir: "{userappdata}\SAM";                                Flags: ignoreversion recursesubdirs createallsubdirs skipifsourcedoesntexist
Source: "build\SAMdependencies\*";     DestDir: "{userappdata}\SAM\SAMdependencies";                Flags: ignoreversion recursesubdirs createallsubdirs skipifsourcedoesntexist
Source: "build\SAM_Rhino_UI\*";        DestDir: "{userappdata}\McNeel\Rhinoceros\packages\7.0\SAM"; Flags: ignoreversion recursesubdirs createallsubdirs skipifsourcedoesntexist
Source: "build\SAM_Rhino_UI\*";        DestDir: "{userappdata}\McNeel\Rhinoceros\packages\8.0\SAM"; Flags: ignoreversion recursesubdirs createallsubdirs skipifsourcedoesntexist
Source: "build\register.bat";          DestDir: "{userappdata}\SAM";                                Flags: ignoreversion skipifsourcedoesntexist
Source: "build\deregister.bat";        DestDir: "{userappdata}\SAM";                                Flags: ignoreversion skipifsourcedoesntexist

; User documents (already staged)
Source: "build\user\Documents\SAM\*";          DestDir: "{userdocs}\SAM";                 Flags: onlyifdoesntexist recursesubdirs createallsubdirs skipifsourcedoesntexist
; Copy resources also to AppData (PB parity)
Source: "build\user\Documents\SAM\resources\*"; DestDir: "{userappdata}\SAM\resources";   Flags: ignoreversion recursesubdirs createallsubdirs skipifsourcedoesntexist
; Optional UserObjects -> GH
Source: "build\user\Documents\SAM\Grasshopper\UserObjects\*"; DestDir: "{userappdata}\Grasshopper\UserObjects\SAM"; Flags: ignoreversion recursesubdirs createallsubdirs skipifsourcedoesntexist

; ----- SAM\Revit YYYY payload copied to AppData (DLLs etc.) -----
Source: "build\SAM\Revit 2020\*"; DestDir: "{userappdata}\SAM\Revit 2020"; Flags: ignoreversion recursesubdirs createallsubdirs skipifsourcedoesntexist
Source: "build\SAM\Revit 2021\*"; DestDir: "{userappdata}\SAM\Revit 2021"; Flags: ignoreversion recursesubdirs createallsubdirs skipifsourcedoesntexist
Source: "build\SAM\Revit 2022\*"; DestDir: "{userappdata}\SAM\Revit 2022"; Flags: ignoreversion recursesubdirs createallsubdirs skipifsourcedoesntexist
Source: "build\SAM\Revit 2023\*"; DestDir: "{userappdata}\SAM\Revit 2023"; Flags: ignoreversion recursesubdirs createallsubdirs skipifsourcedoesntexist
Source: "build\SAM\Revit 2024\*"; DestDir: "{userappdata}\SAM\Revit 2024"; Flags: ignoreversion recursesubdirs createallsubdirs skipifsourcedoesntexist
Source: "build\SAM\Revit 2025\*"; DestDir: "{userappdata}\SAM\Revit 2025"; Flags: ignoreversion recursesubdirs createallsubdirs skipifsourcedoesntexist
Source: "build\SAM\Revit 2026\*"; DestDir: "{userappdata}\SAM\Revit 2026"; Flags: ignoreversion recursesubdirs createallsubdirs skipifsourcedoesntexist

; ----- Rhino.Inside to each Revit Addins + rename GH dll to .gha -----
#define RIT(Year) "build\Rhino.Inside\Revit " + Year + "\"
Source: {#RIT("2020")}*; Excludes: "RhinoInside.Revit.GH.dll"; DestDir: "{userappdata}\Autodesk\Revit\Addins\2020\RhinoInside.Revit"; Flags: ignoreversion recursesubdirs createallsubdirs skipifsourcedoesntexist
Source: {#RIT("2020")}RhinoInside.Revit.GH.dll; DestDir: "{userappdata}\Autodesk\Revit\Addins\2020\RhinoInside.Revit"; DestName: "RhinoInside.Revit.GH.gha"; Flags: ignoreversion skipifsourcedoesntexist
Source: {#RIT("2021")}*; Excludes: "RhinoInside.Revit.GH.dll"; DestDir: "{userappdata}\Autodesk\Revit\Addins\2021\RhinoInside.Revit"; Flags: ignoreversion recursesubdirs createallsubdirs skipifsourcedoesntexist
Source: {#RIT("2021")}RhinoInside.Revit.GH.dll; DestDir: "{userappdata}\Autodesk\Revit\Addins\2021\RhinoInside.Revit"; DestName: "RhinoInside.Revit.GH.gha"; Flags: ignoreversion skipifsourcedoesntexist
Source: {#RIT("2022")}*; Excludes: "RhinoInside.Revit.GH.dll"; DestDir: "{userappdata}\Autodesk\Revit\Addins\2022\RhinoInside.Revit"; Flags: ignoreversion recursesubdirs createallsubdirs skipifsourcedoesntexist
Source: {#RIT("2022")}RhinoInside.Revit.GH.dll; DestDir: "{userappdata}\Autodesk\Revit\Addins\2022\RhinoInside.Revit"; DestName: "RhinoInside.Revit.GH.gha"; Flags: ignoreversion skipifsourcedoesntexist
Source: {#RIT("2023")}*; Excludes: "RhinoInside.Revit.GH.dll"; DestDir: "{userappdata}\Autodesk\Revit\Addins\2023\RhinoInside.Revit"; Flags: ignoreversion recursesubdirs createallsubdirs skipifsourcedoesntexist
Source: {#RIT("2023")}RhinoInside.Revit.GH.dll; DestDir: "{userappdata}\Autodesk\Revit\Addins\2023\RhinoInside.Revit"; DestName: "RhinoInside.Revit.GH.gha"; Flags: ignoreversion skipifsourcedoesntexist
Source: {#RIT("2024")}*; Excludes: "RhinoInside.Revit.GH.dll"; DestDir: "{userappdata}\Autodesk\Revit\Addins\2024\RhinoInside.Revit"; Flags: ignoreversion recursesubdirs createallsubdirs skipifsourcedoesntexist
Source: {#RIT("2024")}RhinoInside.Revit.GH.dll; DestDir: "{userappdata}\Autodesk\Revit\Addins\2024\RhinoInside.Revit"; DestName: "RhinoInside.Revit.GH.gha"; Flags: ignoreversion skipifsourcedoesntexist
Source: {#RIT("2025")}*; Excludes: "RhinoInside.Revit.GH.dll"; DestDir: "{userappdata}\Autodesk\Revit\Addins\2025\RhinoInside.Revit"; Flags: ignoreversion recursesubdirs createallsubdirs skipifsourcedoesntexist
Source: {#RIT("2025")}RhinoInside.Revit.GH.dll; DestDir: "{userappdata}\Autodesk\Revit\Addins\2025\RhinoInside.Revit"; DestName: "RhinoInside.Revit.GH.gha"; Flags: ignoreversion skipifsourcedoesntexist
Source: {#RIT("2026")}*; Excludes: "RhinoInside.Revit.GH.dll"; DestDir: "{userappdata}\Autodesk\Revit\Addins\2026\RhinoInside.Revit"; Flags: ignoreversion recursesubdirs createallsubdirs skipifsourcedoesntexist
Source: {#RIT("2026")}RhinoInside.Revit.GH.dll; DestDir: "{userappdata}\Autodesk\Revit\Addins\2026\RhinoInside.Revit"; DestName: "RhinoInside.Revit.GH.gha"; Flags: ignoreversion skipifsourcedoesntexist

[Run]
Filename: "{userappdata}\SAM\SAMdependencies\install.bat"; WorkingDir: "{userappdata}\SAM\SAMdependencies"; Flags: runascurrentuser runhidden; Check: FileExists(ExpandConstant('{userappdata}\SAM\SAMdependencies\install.bat'))
Filename: "{userappdata}\SAM\register.bat";                WorkingDir: "{userappdata}\SAM";                 Flags: runascurrentuser runhidden; Check: FileExists(ExpandConstant('{userappdata}\SAM\register.bat'))

[UninstallRun]
Filename: "{userappdata}\SAM\deregister.bat";              WorkingDir: "{userappdata}\SAM";                 Flags: runascurrentuser runhidden; Check: FileExists(ExpandConstant('{userappdata}\SAM\deregister.bat'))

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

procedure MakeRevitGhasForYear(const Year: string);
var
  Base, F: string;
begin
  Base := ExpandConstant('{userappdata}\SAM\Revit ') + Year + '\';
  // replicate: copy $(TargetDir)\$(ProjectName).dll => $(ProjectName).gha for the 3 known GH plugins
  for F in ['SAM.Core.Grasshopper.Revit', 'SAM.Architectural.Grasshopper.Revit', 'SAM.Analytical.Grasshopper.Revit'] do
  begin
    if FileExists(Base + F + '.dll') then
      FileCopy(Base + F + '.dll', Base + F + '.gha', True);
  end;
end;

procedure CurStepChanged(CurStep: TSetupStep);
begin
  if CurStep = ssPostInstall then
  begin
    // Global GH link to %APPDATA%\SAM
    CreateSamGhLink();

    // Per-Revit-year links and GHA creation in %APPDATA%\SAM\Revit YYYY
    CreateRevitGhLink('2020'); MakeRevitGhasForYear('2020');
    CreateRevitGhLink('2021'); MakeRevitGhasForYear('2021');
    CreateRevitGhLink('2022'); MakeRevitGhasForYear('2022');
    CreateRevitGhLink('2023'); MakeRevitGhasForYear('2023');
    CreateRevitGhLink('2024'); MakeRevitGhasForYear('2024');
    CreateRevitGhLink('2025'); MakeRevitGhasForYear('2025');
    CreateRevitGhLink('2026'); MakeRevitGhasForYear('2026');
  end;
end;
