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
; Final EXE name and output directory (relative to this .iss file)
; OutputBaseFilename=SAM_Install
; OutputDir=..\dist
DefaultDirName={userappdata}\SAM
DisableDirPage=yes
DefaultGroupName=SAM
DisableProgramGroupPage=yes
Compression=lzma
SolidCompression=yes
PrivilegesRequired=lowest
SetupIconFile={#SourcePath}SAM20new.ico

[Dirs]
; Core app
Name: "{userappdata}\SAM"
Name: "{userappdata}\SAM\resources"

; Per-Revit-year targets used by ghlink and payload
Name: "{userappdata}\SAM\Revit 2025"
Name: "{userappdata}\SAM\Revit 2026"
Name: "{userappdata}\SAM\Revit 2027"

; Grasshopper locations
Name: "{userappdata}\Grasshopper\Libraries"
Name: "{userappdata}\Grasshopper\UserObjects\SAM"
Name: "{userappdata}\Grasshopper\Libraries-Inside-Revit-2025"
Name: "{userappdata}\Grasshopper\Libraries-Inside-Revit-2026"
Name: "{userappdata}\Grasshopper\Libraries-Inside-Revit-2027"

; Rhino package caches
Name: "{userappdata}\McNeel\Rhinoceros\packages\8.0\SAM"
Name: "{userappdata}\McNeel\Rhinoceros\packages\9.0\SAM"

; Rhino.Inside to Revit Addins
Name: "{userappdata}\Autodesk\Revit\Addins\2025\RhinoInside.Revit"
Name: "{userappdata}\Autodesk\Revit\Addins\2026\RhinoInside.Revit"
Name: "{userappdata}\Autodesk\Revit\Addins\2027\RhinoInside.Revit"

[Files]
; ---------- Core staged payload ----------
Source: "build\SAM\*";                 DestDir: "{userappdata}\SAM";                                Flags: ignoreversion recursesubdirs createallsubdirs skipifsourcedoesntexist
; ---------- Third-party licences (OCCT LGPL-2.1 + exception; required because the OCCT TK*.dll runtime is bundled) ----------
Source: "licenses\OCCT\*";             DestDir: "{userappdata}\SAM\licenses\OCCT";                  Flags: ignoreversion recursesubdirs createallsubdirs
Source: "build\SAMdependencies\*";     DestDir: "{userappdata}\SAM\SAMdependencies";                Flags: ignoreversion recursesubdirs createallsubdirs skipifsourcedoesntexist
Source: "build\SAM_Rhino_UI\*";        DestDir: "{userappdata}\McNeel\Rhinoceros\packages\8.0\SAM"; Flags: ignoreversion recursesubdirs createallsubdirs skipifsourcedoesntexist
Source: "build\SAM_Rhino_UI\*";        DestDir: "{userappdata}\McNeel\Rhinoceros\packages\9.0\SAM"; Flags: ignoreversion recursesubdirs createallsubdirs skipifsourcedoesntexist

; User documents (and mirror of resources in AppData)
Source: "build\user\Documents\SAM\*";               DestDir: "{userdocs}\SAM";               Flags: onlyifdestfileexists recursesubdirs createallsubdirs skipifsourcedoesntexist
Source: "build\user\Documents\SAM\resources\*";     DestDir: "{userappdata}\SAM\resources";  Flags: ignoreversion recursesubdirs createallsubdirs skipifsourcedoesntexist
Source: "build\user\Documents\SAM\Grasshopper\UserObjects\*"; DestDir: "{userappdata}\Grasshopper\UserObjects\SAM"; Flags: ignoreversion recursesubdirs createallsubdirs skipifsourcedoesntexist

; ---------- Per-Revit-year: SAM payload copied into %APPDATA%\SAM\Revit YYYY ----------
Source: "build\SAM\Revit 2025\*"; DestDir: "{userappdata}\SAM\Revit 2025"; Flags: ignoreversion recursesubdirs createallsubdirs skipifsourcedoesntexist
Source: "build\SAM\Revit 2026\*"; DestDir: "{userappdata}\SAM\Revit 2026"; Flags: ignoreversion recursesubdirs createallsubdirs skipifsourcedoesntexist
Source: "build\SAM\Revit 2027\*"; DestDir: "{userappdata}\SAM\Revit 2027"; Flags: ignoreversion recursesubdirs createallsubdirs skipifsourcedoesntexist

; ---------- Rhino.Inside to Revit Addins with .dll->.gha rename ----------
; 2025
Source: "build\Rhino.Inside\Revit 2025\*";               Excludes: "RhinoInside.Revit.GH.dll"; DestDir: "{userappdata}\Autodesk\Revit\Addins\2025\RhinoInside.Revit"; Flags: ignoreversion recursesubdirs createallsubdirs skipifsourcedoesntexist
Source: "build\Rhino.Inside\Revit 2025\RhinoInside.Revit.GH.dll"; DestDir: "{userappdata}\Autodesk\Revit\Addins\2025\RhinoInside.Revit"; DestName: "RhinoInside.Revit.GH.gha"; Flags: ignoreversion skipifsourcedoesntexist
; 2026
Source: "build\Rhino.Inside\Revit 2026\*";               Excludes: "RhinoInside.Revit.GH.dll"; DestDir: "{userappdata}\Autodesk\Revit\Addins\2026\RhinoInside.Revit"; Flags: ignoreversion recursesubdirs createallsubdirs skipifsourcedoesntexist
Source: "build\Rhino.Inside\Revit 2026\RhinoInside.Revit.GH.dll"; DestDir: "{userappdata}\Autodesk\Revit\Addins\2026\RhinoInside.Revit"; DestName: "RhinoInside.Revit.GH.gha"; Flags: ignoreversion skipifsourcedoesntexist
; 2027
Source: "build\Rhino.Inside\Revit 2027\*";               Excludes: "RhinoInside.Revit.GH.dll"; DestDir: "{userappdata}\Autodesk\Revit\Addins\2027\RhinoInside.Revit"; Flags: ignoreversion recursesubdirs createallsubdirs skipifsourcedoesntexist
Source: "build\Rhino.Inside\Revit 2027\RhinoInside.Revit.GH.dll"; DestDir: "{userappdata}\Autodesk\Revit\Addins\2027\RhinoInside.Revit"; DestName: "RhinoInside.Revit.GH.gha"; Flags: ignoreversion skipifsourcedoesntexist

[Run]
Filename: "{userappdata}\SAM\SAMdependencies\install.bat"; WorkingDir: "{userappdata}\SAM\SAMdependencies"; Flags: runascurrentuser runhidden; Check: FileExists(ExpandConstant('{userappdata}\SAM\SAMdependencies\install.bat'))

[UninstallDelete]
; Core payload tree (also covers the per-Revit-year folders and the .gha copies
; TryCopyToGha makes inside them).
Type: filesandordirs; Name: "{userappdata}\SAM"
; ----------------------------------------------------------------------
; Artefacts created by [Code]/[Run] at install time - Inno does NOT track
; these, so they need explicit entries:
; CreateStandaloneGhLink:
Type: files; Name: "{userappdata}\Grasshopper\Libraries\SAM.ghlink"
; CreateRevitGhLink (per Revit year). The Libraries-Inside-Revit folder is a
; shared Grasshopper location - remove it only if nothing else uses it.
Type: files; Name: "{userappdata}\Grasshopper\Libraries-Inside-Revit-2025\SAM_Revit.ghlink"
Type: files; Name: "{userappdata}\Grasshopper\Libraries-Inside-Revit-2026\SAM_Revit.ghlink"
Type: files; Name: "{userappdata}\Grasshopper\Libraries-Inside-Revit-2027\SAM_Revit.ghlink"
Type: dirifempty; Name: "{userappdata}\Grasshopper\Libraries-Inside-Revit-2025"
Type: dirifempty; Name: "{userappdata}\Grasshopper\Libraries-Inside-Revit-2026"
Type: dirifempty; Name: "{userappdata}\Grasshopper\Libraries-Inside-Revit-2027"
; CreateRevitAddin (per Revit year). Addins\<year> itself is shared with other
; vendors' add-ins - never remove the folder, only our file.
Type: files; Name: "{userappdata}\Autodesk\Revit\Addins\2025\SAM.addin"
Type: files; Name: "{userappdata}\Autodesk\Revit\Addins\2026\SAM.addin"
Type: files; Name: "{userappdata}\Autodesk\Revit\Addins\2027\SAM.addin"
; RhinoInside.Revit payload dir: its contents are [Files]-tracked and removed
; automatically; drop the dir only if empty (Rhino.Inside may have dropped its
; own runtime files there - those are not ours and stay).
Type: dirifempty; Name: "{userappdata}\Autodesk\Revit\Addins\2025\RhinoInside.Revit"
Type: dirifempty; Name: "{userappdata}\Autodesk\Revit\Addins\2026\RhinoInside.Revit"
Type: dirifempty; Name: "{userappdata}\Autodesk\Revit\Addins\2027\RhinoInside.Revit"
; SAMdependencies\install.bat ([Run]) xcopies these into Grasshopper\Libraries:
Type: files; Name: "{userappdata}\Grasshopper\Libraries\Sunglasses.gha"
Type: files; Name: "{userappdata}\Grasshopper\Libraries\FalseStartToggle.gha"
; Intentionally retained: {userdocs}\SAM - user documents (settings, libraries,
; projects). An uninstaller must not delete user data.

[Code]
procedure CreateStandaloneGhLink;
var
  GhDir, SamDir, Content: string;
begin
  SamDir := ExpandConstant('{userappdata}\SAM\');
  GhDir := ExpandConstant('{userappdata}\Grasshopper\Libraries\');
  if not DirExists(GhDir) then
    ForceDirectories(GhDir);

  Content := '#Order of files is important' + #13#10;
  if FileExists(SamDir + 'SAM.Core.Grasshopper.gha') then
    Content := Content + SamDir + 'SAM.Core.Grasshopper.gha' + #13#10;
  if FileExists(SamDir + 'SAM.Architectural.Grasshopper.gha') then
    Content := Content + SamDir + 'SAM.Architectural.Grasshopper.gha' + #13#10;
  if FileExists(SamDir + 'SAM.Analytical.Grasshopper.gha') then
    Content := Content + SamDir + 'SAM.Analytical.Grasshopper.gha' + #13#10;
  // TAS Grasshopper components (registered after the core SAM GHAs they build on).
  if FileExists(SamDir + 'SAM.Core.Grasshopper.Tas.gha') then
    Content := Content + SamDir + 'SAM.Core.Grasshopper.Tas.gha' + #13#10;
  if FileExists(SamDir + 'SAM.Analytical.Grasshopper.Tas.gha') then
    Content := Content + SamDir + 'SAM.Analytical.Grasshopper.Tas.gha' + #13#10;
  if FileExists(SamDir + 'SAM.Weather.Grasshopper.Tas.gha') then
    Content := Content + SamDir + 'SAM.Weather.Grasshopper.Tas.gha' + #13#10;
  if FileExists(SamDir + 'SAM.Core.Grasshopper.Tas.UKBR.gha') then
    Content := Content + SamDir + 'SAM.Core.Grasshopper.Tas.UKBR.gha' + #13#10;
  if FileExists(SamDir + 'SAM.Analytical.Grasshopper.Tas.GenOpt.gha') then
    Content := Content + SamDir + 'SAM.Analytical.Grasshopper.Tas.GenOpt.gha' + #13#10;
  if FileExists(SamDir + 'SAM.Analytical.Grasshopper.Tas.TPD.gha') then
    Content := Content + SamDir + 'SAM.Analytical.Grasshopper.Tas.TPD.gha' + #13#10;
  // OCCT Grasshopper components (registered after the core SAM GHAs they build on).
  if FileExists(SamDir + 'SAM.Core.Grasshopper.OCCT.gha') then
    Content := Content + SamDir + 'SAM.Core.Grasshopper.OCCT.gha' + #13#10;
  if FileExists(SamDir + 'SAM.Geometry.Grasshopper.OCCT.gha') then
    Content := Content + SamDir + 'SAM.Geometry.Grasshopper.OCCT.gha' + #13#10;
  if FileExists(SamDir + 'SAM.Analytical.Grasshopper.OCCT.gha') then
    Content := Content + SamDir + 'SAM.Analytical.Grasshopper.OCCT.gha' + #13#10;

  if Content <> '#Order of files is important' + #13#10 then
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
  TargetDir:    string;
  TargetPath:   string;
  AssemblyPath: string;
  Content:      string;
begin
  TargetDir := ExpandConstant('{userappdata}\Autodesk\Revit\Addins\') + Year + '\';
  if not DirExists(TargetDir) then
    ForceDirectories(TargetDir);
  TargetPath := TargetDir + 'SAM.addin';

  AssemblyPath := ExpandConstant('{userappdata}\SAM\Revit ') + Year + '\SAM.Revit.UI.dll';

  Content :=
    '<?xml version="1.0" encoding="utf-8"?>' + #13#10 +
    '<RevitAddIns>' + #13#10 +
    '  <AddIn Type="Application">' + #13#10 +
    '    <Name>SAM Addin</Name>' + #13#10 +
    '    <Assembly>' + AssemblyPath + '</Assembly>' + #13#10 +
    '    <AddInId>53112961-8521-4d4e-be81-aa1cabf3232b</AddInId>' + #13#10 +
    '    <FullClassName>SAM.Revit.UI.Classes.ExternalApplication</FullClassName>' + #13#10 +
    '    <VendorId>SAM</VendorId>' + #13#10 +
    '    <VendorDescription>SAM</VendorDescription>' + #13#10 +
    '  </AddIn>' + #13#10 +
    '</RevitAddIns>' + #13#10;

  SaveStringToFile(TargetPath, Content, False);
end;

procedure EnsureRevitYearPayload(const Year: string);
var
  Base, Target: string;
begin
  Base   := ExpandConstant('{userappdata}\SAM\');
  Target := ExpandConstant('{userappdata}\SAM\Revit ') + Year + '\';
  if not DirExists(Target) then
    ForceDirectories(Target);

  // copy GH-Revit dlls from SAM root into the per-year folder (if present)
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


function RevitYearPayloadExists(const Year: string): Boolean;
var
  Target: string;
begin
  Target := ExpandConstant('{userappdata}\SAM\Revit ') + Year + '\SAM.Revit.UI.dll';
  Result := FileExists(Target);
end;

procedure CurStepChanged(CurStep: TSetupStep);
begin
  if CurStep = ssPostInstall then
  begin
    // Create standalone Grasshopper link, but only for explicit standalone GHAs.
    // Do not point Grasshopper at the whole SAM root.
    CreateStandaloneGhLink;

    if RevitYearPayloadExists('2025') then
      SetupRevitYear('2025');
    if RevitYearPayloadExists('2026') then
      SetupRevitYear('2026');
    if RevitYearPayloadExists('2027') then
      SetupRevitYear('2027');
  end;
end;