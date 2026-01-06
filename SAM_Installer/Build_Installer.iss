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

[Dirs]
Name: "{userappdata}\SAM"
Name: "{userappdata}\SAM\resources"

Name: "{userappdata}\SAM\Revit 2025"
Name: "{userappdata}\SAM\Revit 2026"

Name: "{userappdata}\Grasshopper\Libraries"
Name: "{userappdata}\Grasshopper\UserObjects\SAM"
Name: "{userappdata}\Grasshopper\Libraries-Inside-Revit-2025"
Name: "{userappdata}\Grasshopper\Libraries-Inside-Revit-2026"

Name: "{userappdata}\McNeel\Rhinoceros\packages\7.0\SAM"
Name: "{userappdata}\McNeel\Rhinoceros\packages\8.0\SAM"
Name: "{userappdata}\McNeel\Rhinoceros\packages\9.0\SAM"

Name: "{userappdata}\Autodesk\Revit\Addins\2025\RhinoInside.Revit"
Name: "{userappdata}\Autodesk\Revit\Addins\2026\RhinoInside.Revit"

[Files]
Source: "build\SAM\*";                 DestDir: "{userappdata}\SAM";                                Flags: ignoreversion recursesubdirs createallsubdirs skipifsourcedoesntexist
Source: "build\SAMdependencies\*";     DestDir: "{userappdata}\SAM\SAMdependencies";                Flags: ignoreversion recursesubdirs createallsubdirs skipifsourcedoesntexist

Source: "build\SAM_Rhino_UI\*";        DestDir: "{userappdata}\McNeel\Rhinoceros\packages\7.0\SAM"; Flags: ignoreversion recursesubdirs createallsubdirs skipifsourcedoesntexist
Source: "build\SAM_Rhino_UI\*";        DestDir: "{userappdata}\McNeel\Rhinoceros\packages\8.0\SAM"; Flags: ignoreversion recursesubdirs createallsubdirs skipifsourcedoesntexist
Source: "build\SAM_Rhino_UI\*";        DestDir: "{userappdata}\McNeel\Rhinoceros\packages\9.0\SAM"; Flags: ignoreversion recursesubdirs createallsubdirs skipifsourcedoesntexist

Source: "build\register.bat";          DestDir: "{userappdata}\SAM";                                Flags: ignoreversion skipifsourcedoesntexist
Source: "build\deregister.bat";        DestDir: "{userappdata}\SAM";                                Flags: ignoreversion skipifsourcedoesntexist

Source: "build\user\Documents\SAM\*";               DestDir: "{userdocs}\SAM";               Flags: onlyifdestfileexists recursesubdirs createallsubdirs skipifsourcedoesntexist
Source: "build\user\Documents\SAM\resources\*";     DestDir: "{userappdata}\SAM\resources";  Flags: ignoreversion recursesubdirs createallsubdirs skipifsourcedoesntexist
Source: "build\user\Documents\SAM\Grasshopper\UserObjects\*"; DestDir: "{userappdata}\Grasshopper\UserObjects\SAM"; Flags: ignoreversion recursesubdirs createallsubdirs skipifsourcedoesntexist

Source: "build\SAM\Revit 2025\*"; DestDir: "{userappdata}\SAM\Revit 2025"; Flags: ignoreversion recursesubdirs createallsubdirs skipifsourcedoesntexist
Source: "build\SAM\Revit 2026\*"; DestDir: "{userappdata}\SAM\Revit 2026"; Flags: ignoreversion recursesubdirs createallsubdirs skipifsourcedoesntexist

Source: "build\Rhino.Inside\Revit 2025\*";               Excludes: "RhinoInside.Revit.GH.dll"; DestDir: "{userappdata}\Autodesk\Revit\Addins\2025\RhinoInside.Revit"; Flags: ignoreversion recursesubdirs createallsubdirs skipifsourcedoesntexist
Source: "build\Rhino.Inside\Revit 2025\RhinoInside.Revit.GH.dll"; DestDir: "{userappdata}\Autodesk\Revit\Addins\2025\RhinoInside.Revit"; DestName: "RhinoInside.Revit.GH.gha"; Flags: ignoreversion skipifsourcedoesntexist

Source: "build\Rhino.Inside\Revit 2026\*";               Excludes: "RhinoInside.Revit.GH.dll"; DestDir: "{userappdata}\Autodesk\Revit\Addins\2026\RhinoInside.Revit"; Flags: ignoreversion recursesubdirs createallsubdirs skipifsourcedoesntexist
Source: "build\Rhino.Inside\Revit 2026\RhinoInside.Revit.GH.dll"; DestDir: "{userappdata}\Autodesk\Revit\Addins\2026\RhinoInside.Revit"; DestName: "RhinoInside.Revit.GH.gha"; Flags: ignoreversion skipifsourcedoesntexist

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
  SamDir    := ExpandConstant('{userappdata}\SAM\');
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

procedure TryCopyToGha(const BaseDir, NameNoExt: string);
var
  src, dst: string;
begin
  src := BaseDir + NameNoExt + '.dll';
  dst := BaseDir + NameNoExt + '.gha';
  if FileExists(src) then
    FileCopy(src, dst, False);
end;

procedure CopyIfExists(const SrcFile, DstFile: string);
begin
  if FileExists(SrcFile) then
    FileCopy(SrcFile, DstFile, False);
end;

procedure CreateRevitAddin(const Year: string);
var
  TemplatePath: string;
  TargetDir:    string;
  TargetPath:   string;
  AssemblyPath: string;
  Lines:        TArrayOfString;
  I:            Integer;
begin
  TemplatePath := ExpandConstant('{userappdata}\SAM\SAM.addin');
  if not FileExists(TemplatePath) then
  begin
    Exit;
  end;

  TargetDir := ExpandConstant('{userappdata}\Autodesk\Revit\Addins\') + Year + '\';
  if not DirExists(TargetDir) then
    ForceDirectories(TargetDir);
  TargetPath := TargetDir + 'SAM.addin';

  AssemblyPath :=
    ExpandConstant('{userappdata}\SAM\Revit ') +
    Year +
    '\SAM.Core.Revit.UI.dll';

  if not LoadStringsFromFile(TemplatePath, Lines) then
    Exit;

  for I := 0 to GetArrayLength(Lines) - 1 do
  begin
    StringChange(
      Lines[I],
      '<Assembly></Assembly>',
      '<Assembly>' + AssemblyPath + '</Assembly>'
    );
  end;

  SaveStringsToFile(TargetPath, Lines, False);
end;

procedure EnsureRevitYearPayload(const Year: string);
var
  Base, Target: string;
begin
  Base   := ExpandConstant('{userappdata}\SAM\');
  Target := ExpandConstant('{userappdata}\SAM\Revit ') + Year + '\';
  if not DirExists(Target) then
    ForceDirectories(Target);

  CopyIfExists(Base + 'SAM.Core.Grasshopper.Revit.dll',
               Target + 'SAM.Core.Grasshopper.Revit.dll');
  CopyIfExists(Base + 'SAM.Architectural.Grasshopper.Revit.dll',
               Target + 'SAM.Architectural.Grasshopper.Revit.dll');
  CopyIfExists(Base + 'SAM.Analytical.Grasshopper.Revit.dll',
               Target + 'SAM.Analytical.Grasshopper.Revit.dll');
end;

procedure SetupRevitYear(const Year: string);
var
  Target: string;
begin
  Target := ExpandConstant('{userappdata}\SAM\Revit ') + Year + '\';
  EnsureRevitYearPayload(Year);
  TryCopyToGha(Target, 'SAM.Core.Grasshopper.Revit');
  TryCopyToGha(Target, 'SAM.Architectural.Grasshopper.Revit');
  TryCopyToGha(Target, 'SAM.Analytical.Grasshopper.Revit');
  CreateRevitGhLink(Year);
  CreateRevitAddin(Year);
end;

function DirHasFiles(const Dir, Mask: string): Boolean;
var
  FR: TFindRec;
begin
  Result := False;
  if FindFirst(Dir + Mask, FR) then
  begin
    Result := True;
    FindClose(FR);
  end;
end;

procedure WarnIfRhinoPackageEmpty(const RhinoMajor: string);
var
  V, PkgDir: string;
begin
  V := '1.0.0';  // keep in sync with installer.yml $yakVersion
  PkgDir := ExpandConstant('{userappdata}\McNeel\Rhinoceros\packages\') + RhinoMajor + '\SAM\' + V + '\';

  if DirExists(PkgDir) then
  begin
    if not DirHasFiles(PkgDir, '*.rhp') then
      MsgBox(
        'SAM Rhino UI folder exists but contains no .rhp files:' + #13#10 + PkgDir + #13#10#13#10 +
        'This usually means SAM_Rhino_UI build output was empty or staging removed files.' + #13#10 +
        'Check the GitHub Action log lines: "SAM_Rhino_UI build output breakdown".',
        mbInformation, MB_OK
      );
  end;
end;

procedure CurStepChanged(CurStep: TSetupStep);
begin
  if CurStep = ssPostInstall then
  begin
    CreateSamGhLink();

    SetupRevitYear('2025');
    SetupRevitYear('2026');

    WarnIfRhinoPackageEmpty('8.0');
  end;
end;
