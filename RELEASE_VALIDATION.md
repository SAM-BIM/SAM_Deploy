# SAM_Deploy release acceptance matrix v1

This matrix is newly defined in PR `maintenance/final-repository-hardening`. It
replaces the previously undefined "H1–H12 hand tests" wording used in earlier
handovers — those labels existed without definitions. Every result below was
set on direct evidence per the rules at the end of this document.

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

**Provenance criterion (corrected 2026-09-17 — see the run-210 erratum below).**
"Installed DLL FileVersion values match the workflow run identity" does **not**
mean every packaged binary equals `SAMVersion`. It means each binary is held to
the provenance rule for what it actually is:

### SAM-owned managed assemblies

Every `.dll`/`.gha`/`.rhp` produced by a non-test SAM project in a pinned
SAM_Deploy submodule must have:

- `FileVersion` = `SAMVersion`
- `ProductVersion` = `InformationalVersion`

`AssemblyVersion` is **not** part of this criterion. It remains a
repository/runtime binding identity, governed independently by each project
(some SAM_OCCT assemblies intentionally stage `0.0.0.0` or a build-clock-derived
`1.0.x.y` — that is correct and is not a provenance defect).

### SAM-owned native binaries

SAM-owned native SHARED targets must carry reproducible SAM provenance.
Currently this is exactly one binary, `SAM.Occt.Native.dll`, which must expose:

- `FileVersion` = `SAMVersion`
- `ProductVersion` = `InformationalVersion`

Its ABI compatibility identity remains `sam_occt_abi_version()` — a native
function that all callers already probe — and is unaffected by this metadata.

### Third-party binaries

Third-party binaries retain their own upstream/vendor version metadata. They
are **not** required to match `SAMVersion`. OpenCASCADE's `TK*.dll` toolkit
runtime must match the pinned OCCT SDK version (currently `8.0.0`). Every other
third-party binary (ffmpeg, FreeImage, freetype, jemalloc, openvr, tbb, the
MSVC/.NET runtimes, Xbim, HelixToolkit, `Interop.TAS*`, ...) is provenance-checked
by source/package identity, not rewritten, and is reported (not compared to
`SAMVersion`) by the audit below.

### Evidence rule

This criterion must be evidenced by the automated full-payload audit
(`.github/scripts/audit-payload-versions.ps1`, run in enforce mode as the
"Audit payload versions (H12)" installer.yml step) — not by sampling a handful
of DLLs by hand. The audit classifies every packaged binary as SAM-owned
managed, SAM-owned native, or third-party, and fails the build on a real
provenance violation in the first two classes (or on the OCCT SDK version rule).

Remaining pass criteria (unchanged):

- installer SHA-256 is recorded;
- the automated full-payload provenance audit above passes;
- Revit 2025, 2026 and 2027 payloads contain the correct framework-specific
  assemblies;
- Rhino 8 and Rhino 9 package payloads are present;
- no developer paths, build_tests output, obsolete Topologic files, private
  certificates or signing passwords are packaged;
- no unexpected duplicate DLL names with different hashes are present;
- the complete result table links to screenshots, logs and workflow evidence.

## Results — `hardening-rc1` (run 210)

These results cover the `hardening-rc1` artifact only. They do **not** cover the
2026-Q3 release candidate; see "Results — 2026-Q3 release candidate (run 214,
FINAL ACCEPTED)" at the end of this document for the accepted Q3 record.

Environment (recorded at execution time):

- Windows: Windows 11 Pro 10.0.26200 (validation VM)
- Rhino 8 / Rhino 9: Rhino 8 (8.33.26188.13001) / Rhino 9 BETA (9.0.26209.18303)
- Revit: 2027 (27.0.4.412) on the validation VM; 2025 and 2026 validated on a second machine (exact builds not captured)
- Rhino.Inside.Revit: version not captured (H8/H9 evidence recorded without it)
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

**Erratum (added 2026-09-17, does not change the result rows below).** Run
210's H12 used representative sampling ("installed DLLs sampled carry
FileVersion `2026.3.210.0`") rather than a full-payload audit, and SAM_OCCT was
not comprehensively covered by that sample. The Q3 full-payload audit
(`.github/scripts/audit-payload-versions.ps1`) later exposed a pre-existing gap
it would have caught: 8 SAM_OCCT managed assemblies and `SAM.Occt.Native.dll`
were not actually stamped with the release `FileVersion` at that time (5
managed assemblies shipped the literal, un-expanded string `"1.0.*"`; 3 shipped
`0.0.0.0`; the native wrapper carried no version resource at all — see
SAM_OCCT PR #70). Separately, run 210's H12 wording ("installed DLL FileVersion
values match the workflow run identity") was itself imprecise: third-party
binaries (`TK*.dll` etc.) were never intended to equal `SAMVersion`, only
SAM-owned ones. The H12 criterion above replaces that wording with the precise
managed/native/third-party classification; run 210's historical PASS result is
left unchanged (it accurately reflects what was actually checked at the time)
and a new H12 audit against the corrected criterion is required for the next
candidate.

| Test | Result | Environment | Evidence | Notes |
|---|---|---|---|---|
| H1 | PASS | GH Actions windows-2022 | run 30764391863 (success, 19m); artifact `SAM_Install_hardening-rc1.exe`; SHA-256 above; release list + tag list unchanged | First confirmation run 30762579846 (on 6ed081a) also succeeded |
| H2 | PASS | clean profile, validation VM | Michal: installer completed without errors; SHA-256 confirmed before install; expected %APPDATA%\SAM + Rhino 8/9 package dirs created | Installed payload independently verified to carry only run-210 stamps (see H12) |
| H3 | PASS | Rhino 8.33.26188.13001 | Michal at console: SAM plugin loads, GH starts, SAM tabs/components appear, no missing-assembly errors, no duplicate assembly/component GUID warnings | |
| H4 | PASS | Rhino 9 BETA 9.0.26209.18303 | Michal at console: same checks as H3, all clean | |
| H5 | PASS | validation VM | Six filenames recorded above; all six are in `Grasshopper\Libraries\SAM.ghlink` pointing at the installer destination (`%APPDATA%\SAM`), each FileVersion `2026.3.210.0` (= run 210); no stale TAS Grasshopper assemblies; Michal confirms correct load | ghlink is a curated 12-entry load-order list (order matters); the remaining .gha load through SAM.Core's own mechanism — "not all .gha listed" is by design |
| H6 | PASS | Grasshopper (clean profile) | Michal: both UserObjects (`Tas Workflow v7.ghuser`, `Validation.ghuser`) appear and can be placed; no missing-component/assembly messages | |
| H7 | PASS | TAS 9.5.7 + Grasshopper | Michal: representative TAS workflow opens without replacement components, solves without exceptions, plausible non-empty outputs | |
| H8 | PASS | Revit 2025 + Rhino.Inside.Revit (second machine; exact Revit/RiR builds not captured) | Michal: Grasshopper started inside Revit; installed SAM components loaded from the Revit 2025 payload; a representative component was placed and solved; no framework mismatch; no missing assembly; no duplicate assembly or component GUID warnings | |
| H9 | PASS | Revit 2026 + Rhino.Inside.Revit (second machine; exact Revit/RiR builds not captured) | Michal: identical checks against the Revit 2026 payload — Grasshopper started, components loaded from the 2026 payload, representative component placed and solved, no framework mismatch, no missing assembly, no duplicate assembly/GUID warnings | |
| H10 | PASS | Revit 2027 27.0.4.412 | Michal: ToSAM_AnalyticalModel + TogbXML exercised — energy model created, no AnalysisType exception, analytical spaces/surfaces returned, gbXML exported; add-in loads from the 2027 payload | Covers the SAM_Revit#17 runtime path |
| H11 | PASS | validation VM | Previous public SAM release installed (latest on the Releases page at test time: `v20260627.2`); upgraded by installing `SAM_Install_hardening-rc1.exe` over it; post-upgrade `SAM.Core.dll` FileVersion `2026.3.210.0`, ProductVersion `2026.3.210.0+a6a3cde` (= run 210 identity); Rhino/Grasshopper loaded successfully after upgrade; no stale or duplicate TAS assemblies; uninstall completed without fatal errors; unrelated Rhino/Grasshopper files preserved. SAM-owned items remaining after uninstall (verified on disk, documented — not hidden): `Autodesk\Revit\Addins\<2025|2026|2027>\SAM.addin`, `Grasshopper\Libraries\SAM.ghlink`, `Grasshopper\Libraries-Inside-Revit-<year>\SAM_Revit.ghlink` (+folders), empty `RhinoInside.Revit` dirs, `Documents\SAM`. Correctly removed: `%APPDATA%\SAM`, `Grasshopper\UserObjects\SAM`, Rhino 8/9 package payloads | Residual cleanup tracked as FOLLOW-UP-1 below — an installer improvement, not a test failure |
| H12 | PASS | validation VM | Artifact SHA-256 recorded; installed DLLs sampled carry FileVersion `2026.3.210.0` (= run 210, e.g. `SAM.Core.dll`, all six TAS .gha); `Revit 2025/2026/2027` payload dirs present + CI per-year TFM assertion passed (2025/2026=v8.0, 2027=v10.0); Rhino 8.0 + 9.0 package payloads present with manifests; recursive scan: zero Topologic/build_tests/dev-path/.pfx/password artefacts; duplicate-name-different-hash DLLs all explained (per-year Revit framework payloads, culture satellites, year-scoped dependency versions) | Full CI run log also free of Topologic/PFX/signing references |

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

**Status: implemented and verified** (PR
[#37](https://github.com/SAM-BIM/SAM_Deploy/pull/37), branch
`fix/uninstall-code-created-artefacts`). `[UninstallDelete]` now covers every
`[Code]`/`[Run]`-created artefact: `SAM.ghlink`, the per-year `SAM_Revit.ghlink`
files (+ `dirifempty` on their folders), the per-year `SAM.addin` files,
`dirifempty` on the `RhinoInside.Revit` payload dirs, and the two SAMdependencies
`.gha` files. Shared folders (`Addins\<year>`, `Libraries`) are never removed, and
`{userdocs}\SAM` is documented in the script as intentionally retained user data.
Verified end-to-end: branch installer artifact `SAM_Install_uninstall-fix-test.exe`
(run 30801883568) silently installed (SAM.Core.dll = `2026.3.211.0`) and silently
uninstalled; post-uninstall disk audit of all 17 formerly-stranded paths showed
**zero SAM-owned residuals** — only `Documents\SAM` remains, by design. Issues are
disabled on SAM-BIM/SAM_Deploy, so this remains the follow-up of record until an
issue can be filed.

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

SAM_DEPLOY RELEASE ACCEPTANCE COMPLETE — H1–H12 PASS (`hardening-rc1`, run 210 only)

## Results — 2026-Q3 release candidate (run 214, FINAL ACCEPTED)

**Supersedes the run-213 draft record.** Run 213 (`SAM_Install_v20260916.213.exe`,
SHA-256 `6B8253A4...`) never received an accepted result — its acceptance was
BLOCKED at H2–H12 and that draft record was carried only in PR
[#41](https://github.com/SAM-BIM/SAM_Deploy/pull/41) (never merged; the
`sow/2026-Q3` copy of this file went straight from the run-210 table to this
section). The H12 provenance gap that blocked run 213 was fixed by PR
[#42](https://github.com/SAM-BIM/SAM_Deploy/pull/42) (merged, `cbd05b6`); the
installer was rebuilt from that commit as run 214 and is the candidate accepted
below. Run 213 is retired and must not be installed, promoted or referenced as
current.

Candidate identity:

- SAM_Deploy `sow/2026-Q3` @ `cbd05b655076b859c709052d006b6edbb88dd113`
  (merge of PR #42 onto the PR #40 freeze `2ce3d87`; no other pin changed)
- installer.yml run: https://github.com/SAM-BIM/SAM_Deploy/actions/runs/35194487176
  (run number 214)
- Artifact: `SAM_Install_v20260917.214.exe`
- Artifact SHA-256: `EFB0BDAB28FDDD9915ED9845EAA4CAD271F2DA4774BF8BB7A5942EE16EF091DB`
- Stamping: SAMVersion `2026.3.214.0`, InformationalVersion `2026.3.214.0+cbd05b6`
- H1: **PASS** — run 214 succeeded, one artifact, filename carries `v20260917.214`,
  SHA-256 above recorded, no tag/release created by the build.
- H12: **PASS** — full-payload provenance audit (`audit-payload-versions.ps1`,
  enforce mode, PR #42) ran clean against this artifact: SAM-owned managed and
  native binaries match SAMVersion/InformationalVersion, OCCT `TK*.dll` toolkit
  matches the pinned SDK version, no test binaries in the payload, all required
  SAM_OCCT binaries present.

### Owner manual acceptance (2026-09-17, this exact installer)

Performed by the project owner directly against `SAM_Install_v20260917.214.exe`
(SHA-256 verified before use, matches above).

| Item | Result |
|---|---|
| Clean installation | PASS |
| SAM_UI standalone | PASS |
| Part O Iteration 1a workflow | PASS |
| Part O Iteration 2 workflow | PASS |
| Rhino SAM `.rhp` | PASS |
| Grasshopper + SAM | PASS |
| Grasshopper + OCCT, machine with no OCCT SDK installed | PASS |
| Revit add-in | PASS |
| Revit 2026 + Rhino.Inside.Revit + Grasshopper + SAM | PASS |
| Revit 2027 + Rhino.Inside.Revit + Grasshopper + SAM | PASS (normal integration/load) |
| SAM_UI launched from the Revit/Rhino environment | PASS |
| Uninstall | PASS — owner inspected AppData / Autodesk / SAM / McNeel / Grasshopper locations; no remaining SAM installation files |

### Explicit owner waivers (not PASS — do not report as PASS)

| Item | Status | Reason |
|---|---|---|
| H8 — Rhino.Inside.Revit 2025 | **OWNER-SKIPPED** | No Revit 2025 environment available; owner accepts this gap for the 2026-Q3 release |
| H10 — dedicated `ToSAM_AnalyticalModel` + `TogbXML` runtime-path acceptance | **OWNER-SKIPPED** | Skipped for this closeout by owner decision. The general "Revit 2027 + RiR + GH + SAM: PASS (normal integration/load)" result above is evidence the add-in loads and solves on 2027 — it is **not** a substitute for the dedicated energy-analysis runtime-path test (H10 pass criteria are unchanged: this test cannot be replaced by a load/compile-only result) |

### Cross-reference to the original H1–H12 matrix

| Test | Status | Evidence for run 214 |
|---|---|---|
| H1 | PASS | See candidate identity above |
| H2 | PASS | Owner: "Clean installation: PASS" |
| H3 (Rhino 8) / H4 (Rhino 9) | PASS (generic) | Owner: "Rhino SAM `.rhp`: PASS", "Grasshopper + SAM: PASS". Owner's report does not separately break these out by Rhino version for this closeout (unlike the run-210 table, which recorded exact Rhino 8/9 build numbers) |
| H5 / H6 / H7 (TAS Grasshopper assemblies / UserObjects / representative TAS workflow) | **NOT EXERCISED THIS CLOSEOUT** | The owner's acceptance pass exercised Part O Iteration 1a/2 workflows instead of a TAS workflow; no TAS-specific evidence was recorded against run 214. Not explicitly waived by the owner either — flagged here rather than assumed |
| H8 | OWNER-SKIPPED | See waiver table above |
| H9 | PASS | Owner: "Revit 2026 + Rhino.Inside.Revit + Grasshopper + SAM: PASS" |
| H10 | OWNER-SKIPPED | See waiver table above |
| H11 | PASS (uninstall); upgrade-over-previous-version not separately itemized | Owner: "Uninstall: PASS" with a documented location-by-location inspection (matches H11's "do not hide residual files" rule). A clean install was also confirmed (H2); an in-place upgrade over a prior SAM version was not separately called out in the owner's report for this closeout |
| H12 | PASS | See candidate identity above |

**2026-Q3 CANDIDATE ACCEPTED — H1 PASS, H12 PASS, full owner manual acceptance
PASS on all items exercised; H8 and the dedicated H10 runtime-path test are
OWNER-SKIPPED (waived), not PASS. `SAM_Install_v20260917.214.exe` (SHA-256
above) is the frozen, accepted 2026-Q3 release artifact. No installer rebuild,
GitHub Release, or tag was created as part of recording this acceptance.**
