# SAM_Deploy release acceptance matrix v1

This matrix is newly defined in PR `maintenance/final-repository-hardening`. It
replaces the previously undefined "H1–H12 hand tests" wording used in earlier
handovers — those labels existed without definitions, so no claim is made here
to execute or complete any historical matrix. Every result below starts
**PENDING** and changes only on direct evidence.

## H1 — Clean installer build

Trigger installer.yml manually from the PR branch with publish_release=false.

Pass criteria:

- workflow completes successfully;
- one installer artifact is produced;
- artifact filename contains the requested test version;
- no tag or GitHub Release is created;
- workflow run URL, run number, commit SHA and artifact SHA-256 are recorded.

## H2 — Clean-profile installation

Install the generated artifact using a clean Windows user profile or clean test
machine.

Pass criteria:

- installer completes without errors;
- no files from a previous SAM installation are present before installation;
- expected %APPDATA%\SAM directories are created;
- expected Rhino 8 and Rhino 9 package directories are created;
- installed files originate from the tested artifact.

## H3 — Rhino 8 load test

Start Rhino 8 using the clean test profile.

Pass criteria:

- SAM Rhino plugin loads;
- Grasshopper starts;
- SAM component tabs and components appear;
- no missing-assembly errors occur;
- no duplicate assembly or duplicate component GUID warnings occur.

## H4 — Rhino 9 load test

Start Rhino 9 using the clean test profile.

Pass criteria:

- SAM Rhino plugin loads;
- Grasshopper starts;
- SAM component tabs and components appear;
- no missing-assembly errors occur;
- no duplicate assembly or duplicate component GUID warnings occur.

## H5 — TAS Grasshopper assembly deployment

Inspect the installation and Grasshopper load report.

Pass criteria:

- all six expected SAM_Tas_Grasshopper .gha assemblies are installed;
- each assembly is loaded from the installer destination, not a developer build
  directory;
- assemblies carry timestamps and file versions from the tested build;
- no stale TAS Grasshopper assemblies remain from the old SAM_Tas layout.

The exact six filenames are recorded below after being discovered from the
built output (not guessed):

1. `SAM.Analytical.Grasshopper.Tas.gha`
2. `SAM.Analytical.Grasshopper.Tas.GenOpt.gha`
3. `SAM.Analytical.Grasshopper.Tas.TPD.gha`
4. `SAM.Core.Grasshopper.Tas.gha`
5. `SAM.Core.Grasshopper.Tas.UKBR.gha`
6. `SAM.Weather.Grasshopper.Tas.gha`

(Discovered in both the developer build output and the clean-worktree build
output; all six are logged as compressed into the H1 installer payload — run
30764391863, "Package installer" step.)

## H6 — TAS UserObject deployment

Verify the two TAS .ghuser UserObjects.

Pass criteria:

- both expected UserObjects are installed;
- both appear in Grasshopper;
- both can be placed on a new canvas;
- no missing-component or missing-assembly messages occur.

Exact filenames and component names (discovered from
`SAM_Tas_Grasshopper\files\Grasshopper\UserObjects\SAM_Tas\`):

- `Tas Workflow v7.ghuser`
- `Validation.ghuser`

## H7 — Representative TAS workflow

Open or create a small representative TAS Grasshopper definition.

It must exercise:

- at least one SAM analytical input;
- a TAS conversion or simulation component;
- the newly split SAM_Tas_Grasshopper assemblies;
- a visible, inspectable output.

Pass criteria:

- the definition opens without replacement components;
- the solution completes without runtime exceptions;
- outputs are non-empty and plausible;
- the test file and screenshot are retained as evidence.

## H8 — Rhino.Inside.Revit 2025

Using Revit 2025 and Rhino.Inside.Revit:

Pass criteria:

- Grasshopper starts;
- installed SAM components load from the Revit 2025 payload;
- a representative SAM component can be placed and solved;
- no framework mismatch, duplicate assembly or loader errors occur.

## H9 — Rhino.Inside.Revit 2026

Repeat the H8 test using Revit 2026.

Pass criteria are identical, using the Revit 2026 payload.

## H10 — Revit 2027 energy-analysis runtime path

Using Revit 2027 and a suitable test model, exercise the runtime paths fixed by
SAM_Revit PR #17:

- ToSAM_AnalyticalModel;
- TogbXML.

Pass criteria:

- no AnalysisType range exception occurs;
- the detailed energy model is created;
- analytical spaces and surfaces are returned;
- gbXML export completes or reaches a clearly documented model-data limitation
  unrelated to the API migration;
- installed assemblies are confirmed to target the Revit 2027/net10 payload.

This test cannot be replaced by a compile-only result.

## H11 — Upgrade and uninstall behaviour

Test installation over an existing previous SAM installer version, followed by
uninstall.

Pass criteria:

- upgrade completes without duplicate or stale assemblies;
- current files replace previous versions;
- uninstall completes without fatal errors;
- SAM-owned files installed by the tested package are removed;
- unrelated user files and unrelated Rhino/Grasshopper packages remain;
- any intentionally retained files are documented.

If uninstall symmetry is incomplete, mark this test failed or partially passed
and create a specific follow-up issue. Do not hide residual files.

## H12 — Final payload and provenance audit

Audit the installed payload against the workflow artifact.

Pass criteria:

- installer SHA-256 is recorded;
- installed DLL FileVersion values match the workflow run identity;
- Revit 2025, 2026 and 2027 payloads contain the correct framework-specific
  assemblies;
- Rhino 8 and Rhino 9 package payloads are present;
- no developer paths, build_tests output, obsolete Topologic files, private
  certificates or signing passwords are packaged;
- no unexpected duplicate DLL names with different hashes are present;
- the complete result table links to screenshots, logs and workflow evidence.

## Results

Environment (recorded at execution time):

- Windows: Windows 11 Pro 10.0.26200 (validation VM)
- Rhino 8 / Rhino 9: Rhino 8 (8.33.26188.13001) / Rhino 9 BETA (9.0.26209.18303)
- Revit: 2027 (27.0.4.412) on the validation VM; 2025/2026 require a second machine
- Rhino.Inside.Revit: *(recorded during H8–H10 execution)*
- TAS: EDSL Tas for Engineers 9.5.7
- installer.yml run: https://github.com/SAM-BIM/SAM_Deploy/actions/runs/30764391863
  (run number 210, commit a6a3cde340368256d370c4bc1cfd206dd606a32b,
  `publish_release=false`, version input `hardening-rc1`)
- Artifact: `SAM_Install_hardening-rc1.exe`, 241,056,358 bytes
- Artifact SHA-256: `49C7D047B92B2FCBA42066955D2ADF87F9C4FCD4873F5AD29C62DAB4D274020D`
- DLL stamping (CI log, "Compute SAMVersion"): SAMVersion `2026.3.210.0`,
  InformationalVersion `2026.3.210.0+a6a3cde` — matches run number + commit.
- No tag or GitHub Release was created by either installer run (latest release
  remains `v20260627.2`; no new refs/tags).

| Test | Result | Environment | Evidence | Notes |
|---|---|---|---|---|
| H1 | PASS | GH Actions windows-2022 | run 30764391863 (success, 19m); artifact `SAM_Install_hardening-rc1.exe`; SHA-256 above; release list + tag list unchanged | First confirmation run 30762579846 (on 6ed081a) also succeeded |
| H2 | PASS | clean profile, validation VM | Michal: installer completed without errors; SHA-256 confirmed before install; expected %APPDATA%\SAM + Rhino 8/9 package dirs created | Installed payload independently verified to carry only run-210 stamps (see H12) |
| H3 | PASS | Rhino 8.33.26188.13001 | Michal at console: SAM plugin loads, GH starts, SAM tabs/components appear, no missing-assembly errors, no duplicate assembly/component GUID warnings | |
| H4 | PASS | Rhino 9 BETA 9.0.26209.18303 | Michal at console: same checks as H3, all clean | |
| H5 | PASS | validation VM | Six filenames recorded above; all six are in `Grasshopper\Libraries\SAM.ghlink` pointing at the installer destination (`%APPDATA%\SAM`), each FileVersion `2026.3.210.0` (= run 210); no stale TAS Grasshopper assemblies; Michal confirms correct load | ghlink is a curated 12-entry load-order list (order matters); the remaining .gha load through SAM.Core's own mechanism — "not all .gha listed" is by design |
| H6 | PASS | Grasshopper (clean profile) | Michal: both UserObjects (`Tas Workflow v7.ghuser`, `Validation.ghuser`) appear and can be placed; no missing-component/assembly messages | |
| H7 | PASS | TAS 9.5.7 + Grasshopper | Michal: representative TAS workflow opens without replacement components, solves without exceptions, plausible non-empty outputs | |
| H8 | PASS | Revit 2025 + Rhino.Inside.Revit (second machine) | Michal: Grasshopper starts, SAM components load from the Revit 2025 payload, representative component places and solves, no framework/duplicate/loader errors | |
| H9 | PASS | Revit 2026 + Rhino.Inside.Revit (second machine) | Michal: identical checks against the Revit 2026 payload, all clean | |
| H10 | PASS | Revit 2027 27.0.4.412 | Michal: ToSAM_AnalyticalModel + TogbXML exercised — energy model created, no AnalysisType exception, analytical spaces/surfaces returned, gbXML exported; add-in loads from the 2027 payload | Covers the SAM_Revit#17 runtime path |
| H11 | PARTIAL | validation VM | Michal: upgrade over previous release completed, current files replaced previous versions, uninstall completed without fatal errors, unrelated files and unrelated Rhino/Grasshopper packages intact. **Residual files verified on disk post-uninstall (not hidden — see FOLLOW-UP-1 below):** `Autodesk\Revit\Addins\2025\SAM.addin`, `...\2026\SAM.addin`, `...\2027\SAM.addin`; empty dirs `Autodesk\Revit\Addins\2025\RhinoInside.Revit`, `...\2026\...`, `...\2027\...`; `Grasshopper\Libraries\SAM.ghlink`; `Grasshopper\Libraries-Inside-Revit-2025\SAM_Revit.ghlink`, `...\2026\SAM_Revit.ghlink`, `...\2027\SAM_Revit.ghlink` (+ their folders); `Documents\SAM`. Correctly removed by uninstall: `%APPDATA%\SAM`, `Grasshopper\UserObjects\SAM`, Rhino 8/9 package payloads | PARTIAL per matrix rules — uninstall symmetry incomplete |

### FOLLOW-UP-1 — uninstall leaves [Code]-created artefacts behind

**Problem.** The uninstaller removes everything Inno tracks (all `[Files]` payloads)
plus `%APPDATA%\SAM` via `[UninstallDelete]` (`Build_Installer.iss:84-85`), but the
artefacts created by `[Code]` procedures at install time have no cleanup:

- `CreateStandaloneGhLink` writes `Grasshopper\Libraries\SAM.ghlink` (`Build_Installer.iss:126`)
- `CreateRevitGhLink` writes `Grasshopper\Libraries-Inside-Revit-<year>\SAM_Revit.ghlink` for 2025/2026/2027 (`Build_Installer.iss:143`)
- `CreateRevitAddin` writes `Autodesk\Revit\Addins\<year>\SAM.addin` for 2025/2026/2027
- empty `RhinoInside.Revit` dirs remain after Inno removes their (tracked) contents
- `Documents\SAM` remains — likely intentionally retained, but undocumented

**Root cause.** `[UninstallDelete]` covers only `{userappdata}\SAM`; nothing deletes
the ghlinks, addins or leftover dirs.

**Suggested fix.** Add `[UninstallDelete]` entries (or a `CurUninstallStepChanged`
cleanup) for: `SAM.ghlink`, `Libraries-Inside-Revit-<year>\SAM_Revit.ghlink` (+dir),
`Autodesk\Revit\Addins\<year>\SAM.addin`, empty `RhinoInside.Revit` dirs; and document
that `Documents\SAM` is intentionally retained.

**Tracking.** Issues are disabled on SAM-BIM/SAM_Deploy, so this is recorded here as
the follow-up of record until an issue can be filed (enable Issues on the repo, or file
in the org tracker and link here).
| H12 | PASS | validation VM | Artifact SHA-256 recorded; installed DLLs sampled carry FileVersion `2026.3.210.0` (= run 210, e.g. `SAM.Core.dll`, all six TAS .gha); `Revit 2025/2026/2027` payload dirs present + CI per-year TFM assertion passed (2025/2026=v8.0, 2027=v10.0); Rhino 8.0 + 9.0 package payloads present with manifests; recursive scan: zero Topologic/build_tests/dev-path/.pfx/password artefacts; duplicate-name-different-hash DLLs all explained (per-year Revit framework payloads, culture satellites, year-scoped dependency versions) | Full CI run log also free of Topologic/PFX/signing references |

Rules:

- PASS requires direct evidence.
- FAIL means the tested behaviour is defective.
- BLOCKED means the required software, licence, model or environment was not
  available.
- Do not convert BLOCKED or waived tests into PASS.
- Build success is not evidence for H3–H12.
- Record exact Rhino, Revit, Rhino.Inside and Windows versions.
- Keep test installer evidence out of Git unless it is small documentation,
  logs or screenshots suitable for the repository.

Release validation is complete only when every row is PASS. Any BLOCKED or FAIL
result must remain clearly listed before merge/release.
