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

procedure TryCopyToGha(const BaseDir, NameNoExt: string);
var
  src, dst: string;
begin
  src := BaseDir + NameNoExt + '.dll';
  dst := BaseDir + NameNoExt + '.gha';
  if FileExists(src) then
    FileCopy(src, dst, False);  // overwrite if exists
end;

procedure MakeRevitGhasForYear(const Year: string);
var
  Base: string;
begin
  Base := ExpandConstant('{userappdata}\SAM\Revit ') + Year + '\';
  TryCopyToGha(Base, 'SAM.Core.Grasshopper.Revit');
  TryCopyToGha(Base, 'SAM.Architectural.Grasshopper.Revit');
  TryCopyToGha(Base, 'SAM.Analytical.Grasshopper.Revit');
end;

procedure CurStepChanged(CurStep: TSetupStep);
begin
  if CurStep = ssPostInstall then
  begin
    CreateSamGhLink();

    CreateRevitGhLink('2020'); MakeRevitGhasForYear('2020');
    CreateRevitGhLink('2021'); MakeRevitGhasForYear('2021');
    CreateRevitGhLink('2022'); MakeRevitGhasForYear('2022');
    CreateRevitGhLink('2023'); MakeRevitGhasForYear('2023');
    CreateRevitGhLink('2024'); MakeRevitGhasForYear('2024');
    CreateRevitGhLink('2025'); MakeRevitGhasForYear('2025');
    CreateRevitGhLink('2026'); MakeRevitGhasForYear('2026');
  end;
end;
