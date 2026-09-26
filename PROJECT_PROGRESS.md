# Project Progress

## Branch
`sow/2026-Q3`

## Last updated
2026-09-26 (latest) — pointer bump SAM_UI `7e7de033` -> `4b773f3e`, the merged Part O UX Pass 6 (SAM_UI#122: final
consistency fixes and end-to-end acceptance - presentation only; Part O UX ready for closeout/freeze). A fast-forward;
SAM (`22f9c743`) and SAM_Tas (`b32c0808`) are already what it builds against, and no other gitlink moves. Branch
`chore/bump-sam-ui-parto-pass6-2026-09-26`.
Previously: 2026-09-26 (closeout) — **SAM Documentation Framework Phase 1: COMPLETE.** SAM_Deploy#51 merged as `8e6740af`:
- `sow/2026-Q3` pins SAM `22f9c743` and SAM_UI `7e7de033`;
- installer and payload validation passed;
- the installed-product smoke test passed.

The deployment gate is complete. See the section below.
Previously: 2026-09-26 (latest) — ship the Space Assumptions PDF (reporting Phase 1): SAM `78a57466` -> `22f9c743`,
SAM_UI `5a0b9bf6` -> `7e7de033`, plus a new installer gate for the reporting/PDF payload. Branch
`chore/deploy-space-assumptions-pdf-2026-09-26`.
Previously: 2026-09-26 (later) — pointer bump for the Part O 2B per-round `.sam` growth fix: SAM `7dbeb2e4` -> `78a57466`
(SAM#142, deep clone no longer doubles Guid-less cluster objects; also brings the reporting PRs #136/#139/#140, which
sit below it on `sow/2026-Q3` and which SAM_UI CI already builds against), SAM_Tas `39828c6` -> `b32c0808` (SAM_Tas#67,
design days and zone results replaced per run instead of appended), SAM_UI `3b29e41f` -> `5a0b9bf6` (SAM_UI#118 Pass 5
2B journey + #119 growth regression/evidence). All three fast-forwards to their merged tips; no other gitlink moves.
No engineering change beyond removing accumulated stale records (live TAS: 12/12 TM59 reports identical, `.sam` flat).
Branch `chore/bump-parto-sam-growth-2026-09-26`.
Previously: 2026-09-26 — pointer bump SAM_UI `90b42e0e` -> `3b29e41f` (SAM_UI#113-#117: Part O Review iteration, TM59 result
window, Hub outcome line, reopened-run naming, shared progress window - all presentation/orchestration) and SAM
`80b01052` -> `7dbeb2e4`, the SAM#137 merge that SAM_UI#114 consumes (per-space TM59 status). Both fast-forwards.
SAM is deliberately NOT moved to its tip: the later reporting PRs (#136/#139/#140) are not needed by SAM_UI and
are left for a separate bump. Branch `chore/bump-sam-ui-parto-pass4-2026-09-26`; no other gitlink moves.
Previously: 2026-09-25 (later) — SAM_UI pointer bump `6230d7d1` -> `90b42e0e`, the merged Part O Prepare & Run Hub
presentation pass SAM_UI#111 (branch `chore/bump-sam-ui-hub-presentation-2026-09-25`). A fast-forward; the pass is
presentation-only in SAM_UI, with no engineering change. SAM, SAM_Systems and SAM_Tas are already at their
`sow/2026-Q3` tips (PR #47), and no other gitlink moves.
2026-09-25 — pointer bump of SAM, SAM_Systems, SAM_Tas and SAM_UI to the merged Nuaire-reply and Part O
workflow-simplification commits (branch `chore/bump-parto-workflow-merged-pointers`, PR #47).
2026-09-24 — minimal pointer bump to the merged Nuaire / Part O manufacturer-guidance commits
(branch `chore/bump-parto-nuaire-merged-pointers`, PR #46).
2026-09-23 — post-acceptance submodule bump to every `sow/2026-Q3` tip (branch
`chore/bump-submodules-2026-09-23`), followed by a non-publishing test installer build.
2026-09-17 — 2026-Q3 release candidate ACCEPTED (run 214).

## 2026-09-26 Space Assumptions PDF deployment (SAM_UI#121) - MERGED as SAM_Deploy#51 (`8e6740af`)

```text
SAM Documentation Framework — Phase 1
Status: COMPLETE        deployment gate: COMPLETE (SAM_Deploy#51 merged as 8e6740af)
```

Pins on `sow/2026-Q3`: SAM `22f9c743`, SAM_UI `7e7de033`. Validate CI was green on the merged head `45568a3e`. The
Phase 1 completion record is in SAM `documentation/Reporting-PDF.md` › *Phase 1 status*.

Unrelated housekeeping, left untouched: `SAM_Tas-113`, `SAM_Tas-ord` and `SAM_Tas-table` are local scratch worktrees
beside the repos. Their upstream branches are gone or missing, so `BuildAlls_v4.bat pull` stops on them. They are not
part of the deployment.

Proves the installed product ships and runs Edit › Reports › **Space Assumptions PDF**:
`SAM Analytical.exe` -> `SAM.Analytical.Reporting` / `SAM.Core.Reporting` -> `SAM.Core.Reporting.Pdf` -> MigraDoc/PDFsharp.
The renderer design is documented in SAM (`documentation/Reporting-PDF.md`) and is not repeated here.

| Submodule | Old pin | New pin | Includes |
|---|---|---|---|
| SAM | `78a57466` | `22f9c743` | SAM#141 PDF renderer (`ba343bfb`); SAM#143 airflow symbol `l/s` -> `L/s` (`22f9c743`) |
| SAM_UI | `5a0b9bf6` | `7e7de033` | SAM_UI#121 Space Assumptions PDF (`7e7de033`); #120 docs |

Both are fast-forwards to the merged `sow/2026-Q3` tips. No other gitlink moves: SAM_Tas `aa00ff91` only adds docs
above its pin and is left alone.

**Where the payload comes from.** SAM.Core.Reporting.Pdf is a netstandard library, so `SAM\build` never carries its
NuGet dependencies. SAM_UI's `PackageReference PDFsharp-MigraDoc 6.2.0` puts PdfSharp*/MigraDoc* 6.2.0 and
Microsoft.Extensions.* 8.0 into `SAM_UI\build`; its post-build copies them to `%APPDATA%\SAM`, which *Stage payload*
packages. The licences also come from SAM_UI: `licenses\NotoSans\OFL.txt` (linked from SAM) and
`licenses\PDFsharp-MigraDoc\LICENSE.txt`. No installer-side copy was added, so the DLLs have one source.

**New gate.** The `installer.yml` step *Assert reporting/PDF payload* (before H12) runs
`.github/scripts/assert-reporting-payload.ps1` on `SAM_Installer\build\SAM`. It fails the build unless:
- the 3 reporting DLLs, PdfSharp, PdfSharp.System/.Shared/.Charting, MigraDoc.DocumentObjectModel/.Rendering,
  Microsoft.Extensions.Logging.Abstractions and both licence files exist and are non-empty;
- every assembly the reporting DLLs reference, transitively, resolves to the payload root or to the .NET 8 shared
  runtime (pwsh uses System.Reflection.Metadata; Windows PowerShell uses a reflection-only load);
- `SAM.Core.Reporting.Pdf.dll` embeds NotoSans-Regular and NotoSans-Bold;
- every PdfSharp*/MigraDoc* in the root is 6.2.0, and no second copy exists outside `Revit 20xx\` (those are
  reported only).

**Installer build.** installer.yml run 36241348967 on `49bc441` (dispatch, `publish_release=false`): success.
Artifact `SAM_Install_v20260926.216.exe`, 249,796,983 bytes, SHA-256
`719805203948da5623b854f75ef66efaa2cd7676d5f3a50203cbd08665b4c989`. Nothing was published.
- New gate: passed (85 assemblies resolved from the payload, 1 from the runtime; fonts embedded).
- H12: "No H12 violations found". The reporting DLLs carry `2026.3.216.0`.
- Drift diagnostics: only the 3 existing warnings (System.Text.Json, System.Text.Encodings.Web,
  System.Threading.Tasks.Extensions), identical in the 23 Sep run 35823794153. None for PdfSharp, MigraDoc or
  Microsoft.Extensions.

**PDFsharp/MigraDoc in the installed payload** (all product version 6.2.0, file version 6.2.0.7443):
- `%APPDATA%\SAM`: PdfSharp, .BarCodes, .Charting, .Cryptography, .Quality, .Shared, .Snippets, .System, .WPFonts;
  MigraDoc.DocumentObjectModel, .Rendering, .RtfRendering. One copy of each.
- Separate paths with the same 6.2.0: `SAM\Revit 2025|2026|2027` (SAM_Revit) and the Rhino 8/9 packages
  (`McNeel\Rhinoceros\packages\<v>\SAM\1.0.0`, which also carry the reporting DLLs). No other version exists.
- Microsoft.Extensions.Logging.Abstractions 8.0.1024.46610, the only Extensions assembly the renderer references.

**Installed smoke test (26 Sep, this VM).**
- Install: silent (`/VERYSILENT /SUPPRESSMSGBOXES`), exit 0; the log lists 2,825 files.
- Fixture: the real 9-Space Part O model `SAM_zoningAM-CIBSEfutureZ1.sam` (SHA-256 `a7e09a25…`), unchanged afterwards.
- Click path, driven with UI Automation:
  1. Launch `%APPDATA%\SAM\SAM Analytical.exe` (2026.3.216.0+49bc441) with `/Path=<model>`.
  2. Model tree › Spaces › right-click **Studio 1_0** › Select.
  3. Edit › Reports › **Space Assumptions PDF** (enabled; the legacy Print RDS is still present).
  4. In the "Save Space Assumptions PDF" dialog, enter the path › Save.
- Result: "Space Assumptions PDF saved: … Open it now?". The file `Studio 1_0 - Space Assumptions.pdf` is 56,308
  bytes.
- PDF:
  - 1 page, A4 (210 × 297 mm);
  - fonts Noto Sans Regular and Bold (embedded subsets); producer PDFsharp 6.2.0;
  - SAM mark; footer "SAM 2026.3.216.0+49bc441 … Page 1 / 1";
  - air flow printed as **L/s** (3 times; no `l/s`, no cfm);
  - missing values shown as `—`; humidity set points `not set`;
  - opened in the default viewer with the layout intact.
- Loaded modules: all 11 reporting/PDF assemblies came from `%APPDATA%\SAM`, at the installer versions. There was
  no missing-DLL, resource or font-resolver error.
- Caveat, and the extra proof for it: `%APPDATA%\SAM` could not be emptied first. The agent runs inside the Claude
  desktop MSIX container, so its rename was virtualized, and the install overlaid 467 older dev files. The 1,036
  files the installer wrote there (taken from its log) were copied to a clean folder. That copy passes the gate.
  Launched from there, it produced the same PDF (56,306 bytes, same checks), with every reporting/PDF module loaded
  from the clean folder.

**Negative check.** A disposable copy of that installer-only folder, with `PdfSharp.dll` removed:
- gate: FAILED (missing PdfSharp.dll; unresolved reference PdfSharp), exit 1;
- app, same click path: an error box "The PDF could not be rendered: Could not load file or assembly 'PdfSharp,
  Version=6.2.0.0 …'", no file written, and the app keeps running.

The positive artefacts were not modified. The evidence is outside git, in `C:\TasOut\deploy-pdf-smoke-2026-09-26`
(`install.log`; `installed-run3\` screenshots, PDF and `loaded-modules.txt`; `clean-run\`; `negative-run\`).

**Limitations.**
- A smoke test on one VM and one Space, not the H1–H12 matrix.
- No upgrade or uninstall test.
- The "Open it now? › Yes" path was not driven again here (PR3 acceptance step H covers it); the PDF was opened
  directly.

**Outcome.** Merged as `8e6740af` on green validate. Future installer runs apply the gate automatically. Next step:
Phase 2 planning (not started).

## 2026-09-25 pointer bump: Nuaire reply + Part O workflow simplification

Only the four repos that carry the merged Part O work move. Every other submodule was already at its
`sow/2026-Q3` tip. Each move is a fast-forward to that tip.

| Submodule | Old pin | New pin | Includes |
|---|---|---|---|
| SAM | `875655fa` | `80b01052` | Nuaire reply SAM#133, docs SAM#134 |
| SAM_Systems | `df5dd332` | `22133736` | Nuaire reply SAM_Systems#29, docs SAM_Systems#30 |
| SAM_Tas | `f7d39351` | `39828c69` | Nuaire reply SAM_Tas#65, docs SAM_Tas#66 |
| SAM_UI | `4460dc3a` | `6230d7d1` | Nuaire reply SAM_UI#107/#108; workflow simplification SAM_UI#109, docs SAM_UI#110 |

**What moves.**
- Nuaire reply (A. Nash, 24 Sep): the guidance cooling supply is the exchanger (bypass, or recovery), then the
  DX drop, never below 13 C; bypass decided by the MVHR independently of the cooling-stat; 80 l/s default
  cooling airflow. Details in SAM's `PROJECT_PROGRESS.md`.
- Part O workflow simplification (SAM_UI only, no engineering change): the Part O Simulate dialog folded into
  a Hub "Simulation case"; one persistent progress window with honest stage-level progress; no success
  "Time elapsed ... OK" box; an Iteration 3 panel with a pre-flight of units/products before any TAS;
  Iteration 3 results stored per method (legacy records still read); the "Iteration 3 comparison" window,
  virtualised for large projects.

**Checks on these commits.**
- Each code PR (SAM#133, SAM_Systems#29, SAM_Tas#65, SAM_UI#107 and #109) had green CI and a completed Codex
  review before merge; the docs PRs had green CI.
- 2026-09-24: all four solutions rebuilt from the merged `sow/2026-Q3` heads (VS 18 MSBuild Release,
  0 errors).
- SAM_UI at the final tip: `SAM_UI.sln` 0 errors; `SAM.Analytical.UI.WPF.Tests` 1056/1056.
- Live smoke tests on the real `SAM Analytical.exe` with TAS (25 Sep): Prepare & Run (Iteration 1a) and an
  Iteration 3 manufacturer-guidance run, reopened in-session and in a fresh process without TAS. Record in
  SAM_UI `documentation/evidence/parto-workflow-simplification/LIVE-SMOKE-2026-09-25.md`.
- Not rerun here: the SAM, SAM_Systems and SAM_Tas test suites on the merged tips (their own PR records
  hold those results).

Manufacturer-guidance values stay PROVISIONAL until Nuaire confirms them; this is not a certification.
Run 214 remains the accepted 2026-Q3 candidate. No installer was built for this bump.

## 2026-09-24 pointer bump: Nuaire / Part O manufacturer guidance (SAM#123)

Only the four repos that carry the merged guidance work move (SAM#125/#131, SAM_Systems#25/#28,
SAM_Tas#63/#64, SAM_UI#105/#106). Every other submodule was already at its `sow/2026-Q3` tip. Each move
is a fast-forward.

| Submodule | Old pin | New pin |
|---|---|---|
| SAM | `86213eb3` | `875655fa` |
| SAM_Systems | `0e891145` | `df5dd332` |
| SAM_Tas | `c267f52f` | `f7d39351` |
| SAM_UI | `5606a82d` | `4460dc3a` |

**Merged-build acceptance on exactly these commits (2026-09-24).**
- Build: 0 errors in all four solutions (Framework MSBuild, Debug).
- Tests: SAM.Tests 2218/2218, SAM.Analytical.Systems.Tests 251/251, SAM.Analytical.Tas.TM59.Tests
  938/938, SAM.Analytical.UI.WPF.Tests 1031/1031.
- Native `SAM Analytical.exe`: the MG review-only reopen, the 1a reopen with Iteration 3 ready, and a
  fresh B0 whose TM59 reports equal the baseline apart from the `Source:` line. Details are in SAM's
  `PROJECT_PROGRESS.md`.

The product values stay PROVISIONAL manufacturer guidance until Nuaire confirms them; this is not a
certification. Run 214 remains the accepted 2026-Q3 candidate. No installer was built for this bump.

## 2026-09-23 submodule bump (post-acceptance, owner-requested)

`git submodule update --remote` (each submodule follows `branch = sow/2026-Q3`). The
bump picks up the 2026-09-22/23 cleanup across the family: dead .NET Framework `app.config` files
(SAM#126 + siblings), redundant bare framework references that caused MSB3243 (SAM_UI#104,
SAM_Solver#13), the missed SAM_OpenStudio leftover (#21), stray legacy gbXML project folders
(SAM_gbXML#9), and `PROJECT_PROGRESS.md` updates. No engineering or runtime behaviour change.

| Submodule | Old pin | New pin |
|---|---|---|
| SAM | `63dd763c` | `86213eb3` |
| SAM_BHoM | `a0823b4f` | `9f0af877` |
| SAM_Excel | `92cdcad7` | `28a26b26` |
| SAM_GEM | `fbd34ba1` | `5af5d69e` |
| SAM_IFC | `d9fa8593` | `50c128d8` |
| SAM_LadybugTools | `d52d7b0c` | `17775e3a` |
| SAM_Multitasker | `e8d09c14` | `55337969` |
| SAM_OpenStudio | `269359eb` | `6972b3e7` |
| SAM_Revit | `1f0a0324` | `c82287af` |
| SAM_SolarCalculator | `3a36b73c` | `9b833996` |
| SAM_Solver | `3c6f5d53` | `de79a826` |
| SAM_Systems | `05ca0c18` | `0e891145` |
| SAM_Tas_Grasshopper | `01508b8e` | `a4d4f731` |
| SAM_UI | `9f515c4c` | `5606a82d` |
| SAM_gbXML | `3b96001f` | `26111c9b` |

Unchanged (already at tip): SAM_Tas, SAM_SQLite, SAM_Psychrometrics, SAM_Windows, SAM_Rhino_UI,
SAM_Revit_UI, SAM_Mollier, SAM_OCCT, SAM_Validation.

**Status of run 214.** This bump moves `sow/2026-Q3` off the exact submodule set that run 214 was
accepted on. Run 214 stays the formally **accepted** 2026-Q3 candidate (record below). The test installer
built after this bump (`gh workflow run installer.yml --ref sow/2026-Q3`, `publish_release=false`) is a
build-health check, **not** a new accepted candidate. Re-running the release matrix on it is a separate owner decision.

**Test installer result - run 215: SUCCESS.** [installer.yml run 215](https://github.com/SAM-BIM/SAM_Deploy/actions/runs/35823794153), dispatched on `sow/2026-Q3` at SAM_Deploy `039def99` (merge of #44), `publish_release=false` (release job skipped, no tag, no GitHub Release). SAMVersion `2026.3.215.0` (from branch `sow/2026-Q3`); 15 min. Produced `SAM_Install_v20260923.215.exe`, artifact `SAM_Install` (233 MB, zip SHA-256 `6c783450c92b7b6779002576d69f29b5e811fc3b0121dbe17ffd75c954de2c77`, expires 2026-12-22). H12 payload audit (enforce mode): **no violations**. Not installed or smoke-tested on a workstation; not an accepted release candidate.

**Local-clone note.** Before the bump, the local `SAM_Deploy` clone showed 24 submodules "modified". Their
working trees were clean but detached at assorted older/unrelated commits (e.g. SAM at `173ababc`), not at
their pins. That was local state only and nothing committed; `git submodule update --remote` resolved it.

## Current status (as of 2026-09-17; see the 2026-09-23 bump above)
2026-Q3 release candidate **ACCEPTED**. Installer `SAM_Install_v20260917.214.exe`
(installer.yml [run 214](https://github.com/SAM-BIM/SAM_Deploy/actions/runs/35194487176),
SAM_Deploy `cbd05b655076b859c709052d006b6edbb88dd113`, SAMVersion `2026.3.214.0`,
SHA-256 `EFB0BDAB28FDDD9915ED9845EAA4CAD271F2DA4774BF8BB7A5942EE16EF091DB`) has
the formal matrix only partially re-evidenced: **formal PASS** on H1, H2, H9,
H12; **formal PARTIAL** on H11 (uninstall PASS, upgrade-over-previous-version
not exercised); H3/H4 and H5–H7 **not separately recorded / not exercised**
this closeout (owner ran Part O + Rhino/Grasshopper smoke acceptance, not the
version-split Rhino gates or a TAS workflow); H8 and the dedicated H10
runtime-path test are **OWNER-SKIPPED** (waived), not PASS; plus a full
**additional owner smoke-test PASS** on every non-matrix item exercised
(SAM_UI, Part O ×2, Rhino `.rhp`, Grasshopper+SAM, Grasshopper+OCCT with no
OCCT SDK installed, Revit add-in, Revit 2026/2027+RiR, SAM_UI from host,
uninstall). Do not read this as "H1–H12 all PASS". Full table:
`RELEASE_VALIDATION.md` → "Results — 2026-Q3 release candidate (run 214, FINAL
ACCEPTED)". This supersedes the run-213 draft record that was carried only in
the never-merged PR #41 (run 213 itself is retired — see H12 provenance
follow-up below, which is what produced run 214).
Nothing in this closeout rebuilds the installer, dispatches a new workflow run,
publishes a GitHub Release, tags a commit, or promotes `sow/2026-Q3` to master
— quarter-close promotion (per-repo `sow/2026-Q3 → master` PRs, then publish,
then `sam-bim.github.io#3`) remains a separate, not-yet-started next step.

## H12 provenance follow-up (2026-09-17, branch `feat/h12-payload-audit`)

Implements the approved H12 fix/erratum after SAM_OCCT PR #70 (merged into its
own `sow/2026-Q3`, head `e9b453b`) fixed the underlying defect: 8 SAM_OCCT
managed assemblies + `SAM.Occt.Native.dll` were shipping without real release
FileVersion/InformationalVersion provenance, and the old H12 wording
("every DLL = SAMVersion") was itself wrong for third-party binaries.

- Bumped the `SAM_OCCT` gitlink: `2afaf029` → `e9b453bd` (only pinned repo
  changed — no other submodule touched).
- New `.github/scripts/audit-payload-versions.ps1`: classifies every
  `.dll`/`.gha`/`.rhp` in a staged payload as SAM-owned managed, SAM-owned
  native (`SAM.Occt.Native.dll`), or third-party. Enforces
  `FileVersion == SAMVersion` / `ProductVersion == InformationalVersion` on
  the first two classes only; reports third-party metadata without comparing
  it to `SAMVersion`; enforces OpenCASCADE's `TK*.dll` runtime against the
  pinned OCCT SDK version; flags any test-only binary found in the payload as
  a hard violation; **fails if any of the 9 approved SAM_OCCT release
  binaries is absent from the payload**, regardless of what else is present.
  `-Enforce` exits 1 on a real violation; without it, the script only reports.
- `.github/workflows/installer.yml`: added an "Audit payload versions (H12)"
  step (enforce mode) immediately after "Stage payload for installer" and
  before "Install Inno Setup", plus an "Upload H12 audit report" artifact step.
  No other installer behaviour changed.
- `RELEASE_VALIDATION.md`: replaced the H12 pass-criteria wording with the
  managed/native/third-party classification above, and added a dated erratum
  explaining why run 210's H12 (representative sampling) did not catch the
  SAM_OCCT gap and why third-party binaries were never meant to equal
  `SAMVersion`. Run 210's historical result row is **unchanged** (it accurately
  reflects what was actually checked at the time).

### v2 fixes (2026-09-17, same day, same branch) — independent review found 4 gaps

An independent review of the first version of this PR found 4 correctness gaps
in the audit script (not in the SAM_OCCT fix itself). All 4 fixed in place,
plus one bug found while testing fix #1:

1. **Required-presence gate (most important).** The original script only
   checked files it found — an absent file (failed native build, or the known
   `SAM.Core.Grasshopper.OCCT` `OutputPath` quirk combined with that project's
   live-deployment copy being `IgnoreExitCode="true"`, i.e. best-effort) would
   never be scanned and so could never fail. Inspected the real staging
   pipeline rather than guessing: each SAM_OCCT Grasshopper project's own
   PostBuild target ("Local packaging: must succeed") copies its
   `$(TargetPath)` to a sibling `.gha`, and `installer.yml`'s own
   "Root Grasshopper DLLs -> GHA" step independently ensures the same for
   anything matching `^SAM\..*Grasshopper.*\.dll$` at the payload root — so
   both `.dll` and `.gha` are genuinely expected for the 3 Grasshopper OCCT
   projects. Added an explicit 12-name required list (5 single-file + 3
   dll/gha pairs + the native DLL) checked for presence after the scan,
   independent of whether anything was actually found.
2. **OCCT toolkit classification.** The old case-sensitive `^TK[A-Z]` match
   missed `TKernel.dll` (OCCT's own historical naming: lowercase after `TK`).
   Replaced the regex entirely: the toolkit set and its expected version are
   now resolved from the real OCCT SDK at `C:\OCCT` (same path
   `installer.yml`'s own native-engine step uses) — every `TK*.dll` actually
   present next to `TKernel.dll` there is the toolkit allowlist, and
   `TKernel.dll`'s own embedded `FileVersion` is the expected version. A
   static 74-name fallback list (enumerated from the same SDK) covers a local
   dry run without the SDK downloaded.
3. **SAM-owned classification vs. H12 wording.** H12 says "produced by a
   non-test project in a pinned submodule", not "filename starts with
   `SAM.`". The ownership map is now built by reading each pinned repo's own
   non-test `*.csproj` files' `<AssemblyName>` (falling back to the csproj's
   base name), registering a `.gha` sibling for anything under a
   `Grasshopper\` folder and a `<TargetExt>` sibling (e.g. `.rhp`) when a
   project overrides it — the project's own declared output identity, not a
   naming guess. A payload file matching the `SAM.*` convention is still
   always treated as SAM-owned even if the map missed it (fail-safe net,
   flagged `UNATTRIBUTED`). Confirmed against a real, previously-undetected
   case: `SAM_Tas/benchmark/SAM.Analytical.Tas.Benchmark.Cli` sets
   `<AssemblyName>benchmark-tas</AssemblyName>` — its output `benchmark-tas.dll`
   does not match `^SAM\.` at all, and is now correctly classified SAM-owned
   managed (owner: `SAM_Tas`) instead of silently falling to third-party.
   Side benefit: because ownership is now per-project rather than "any repo
   whose build folder happens to contain a copy", the previous known
   limitation (widely-shared files like `SAM.Core.dll` listing 22 "owner"
   repos) is resolved — `SAM.Core.dll` now attributes to exactly `SAM`.
4. **OCCT SDK version drift.** The script no longer hard-codes `8.0.0`
   independently of `installer.yml`'s own `OCCT_SDK_TAG` resolution. It reads
   `TKernel.dll`'s own embedded `FileVersion` from `-OcctSdkRoot` (default
   `C:\OCCT`, the same path `installer.yml` downloads/caches the SDK to) — the
   literal same physical files the native build links against. `-OcctSdkVersion`
   (default `8.0.0`) is now only a fallback for when that path has no SDK to
   read (e.g. an offline dry run).
5. **Bug found while testing fix #1** (not one of the 4 requested, found
   while writing the negative test for it): `$violations = $rows |
   Where-Object {...}` — in Windows PowerShell 5.1, a `Where-Object` match of
   **exactly one** item unwraps to a bare object instead of a one-element
   array, so `.Count` silently returns `$null`, and `$null -gt 0` is `$false`
   — a single real violation (e.g. exactly one missing required binary) would
   have passed enforcement silently. First reproduced live: removing only
   `SAM.Occt.Native.dll` from an otherwise-clean payload reported "No H12
   violations found" / exit 0 despite the violation correctly appearing in the
   written report. Fixed by forcing array semantics: `$violations = @($rows |
   Where-Object {...})`. Applied the same defensive fix to `$submoduleNames`.

### Validation performed (before opening the PR, and re-run for v2)

Assembled a complete synthetic payload from real local build output: all 12
required SAM_OCCT binaries (`SAMVersion=2026.3.214.0`, per SAM_OCCT PR #70's
own validation, including real `.gha` copies this time), 3 real `TK*.dll`
(`TKernel.dll`, `TKBRep.dll`, `TKMath.dll`) + `tk86.dll` + `freetype.dll` from
the real local OCCT SDK / build output.

- **(e) clean payload passes**: `-Enforce` → exit 0, zero violations. 11
  SAM-owned managed / 1 SAM-owned native / 3 third-party (OCCT SDK) / 2
  third-party.
- **(b) TKernel 8.0.0 passes**: report shows
  `TKernel.dll | 8.0.0 | 8.0.0 | 8.0.0 | OK` (and `TKBRep.dll`, `TKMath.dll`
  likewise) — OCCT SDK identity resolved as `version=8.0.0 (resolved from
  C:\OCCT\...\win64\vc14\bin (74 TK*.dll, TKernel.dll FileVersion))`.
- **(c) wrong TKernel version fails**: forced the fallback path
  (`-OcctSdkRoot` pointed at a nonexistent folder, `-OcctSdkVersion 9.9.9`)
  against the same real `TKernel.dll` (embedded `8.0.0`) → exit 1,
  `TKernel.dll`/`TKBRep.dll`/`TKMath.dll` all `MISMATCH`, expected `9.9.9`.
- **(d) tk86 stays generic third-party**: `tk86.dll | 8.6.15 | ... |
  <not enforced - third-party> | REPORTED` — never compared to the OCCT SDK
  version.
- **(a) removing a required binary fails H12**: tested twice — removing
  `SAM.Occt.Native.dll` alone (exit 1, `MISSING_REQUIRED_BINARY`, and the
  exact case that first caught the PowerShell array-unwrapping bug above), and
  separately removing only `SAM.Core.Grasshopper.OCCT.gha` (the real-world
  OutputPath-quirk scenario) — exit 1, `MISSING_REQUIRED_BINARY`, class
  `SAM-owned managed`, owner `SAM_OCCT`.
- Regression: re-ran the original synthetic payload (unstamped `SAM.Core.dll`,
  a planted `SAM.OCCT.UnitTests.dll`) — both still correctly flagged
  (`MISMATCH`, `TEST_BINARY_IN_PAYLOAD`), plus now also correctly flags the 3
  missing `.gha` files that payload never had (required-presence gate working
  as intended, catching a gap the first version's own dry run had missed).

No new SAM-owned provenance violation outside the 9 already approved (the 8
SAM_OCCT managed assemblies + `SAM.Occt.Native.dll`) was found in this local
validation. **A full real installer.yml run has NOT been executed yet** — that
happens after this branch merges, per the approved plan (section 20).

**PR #42 has NOT been merged** — holding for explicit human review per
instruction.

## Completed
- Reconciled master-only `dbf2b14` (#28, OCCT cache warmer) into sow via a merge
  commit: kept master's `occt-cache-warm.yml`; kept sow's `installer.yml`
  (supersedes #28's key-only stopgap; cache key already identical).
- Bumped all 24 stale gitlinks to live `sow/2026-Q3` tips (resolved 2026-09-17).
  No pinned repo has nested submodules. All 24 tips CI-green (build; SAM also test).
  No open PRs in any pinned repo.

## Freeze manifest (sow/2026-Q3 tips pinned here)
| Repo | SHA |
|---|---|
| SAM | `63dd763cb039ee32dde9f041354a676f9d304171` |
| SAM_BHoM | `a0823b4f56bb5b8a3ae5de09fa0887e81b8ed9c5` |
| SAM_Excel | `92cdcad70494dfe7656744d35ad0176eded75254` |
| SAM_GEM | `fbd34ba1e4d0455d056c281c3799f8bd8f0e0f9b` |
| SAM_IFC | `d9fa859306b7affbdc445d999faab24d10a06811` |
| SAM_LadybugTools | `d52d7b0cda8b951c8df2074409c802ede60ab3e1` |
| SAM_Mollier | `5c336cdc924f619cdded1a0fd5d6d70466017ff8` |
| SAM_Multitasker | `e8d09c1415f031b7b26e821dea057fc354f09716` |
| SAM_OCCT | `e9b453bd127490913eda0d5f1f8e47373f511db0` (was `2afaf029b4708c0a1988effcfb32fa41c60ff479` — H12 provenance fix, PR #70) |
| SAM_OpenStudio | `269359eb7dd64549748b5250dac7bb47011501f8` |
| SAM_Psychrometrics | `5addfa77eaaaa3dacc647784ae8f1314dc03a01b` |
| SAM_Revit | `1f0a0324fef497294b5e1dfc5995a0d53b6012b8` |
| SAM_Revit_UI | `05fa2e7f31686a4f28a6ec95877e4505c498ffd3` |
| SAM_Rhino_UI | `296875ef9da6eaecaf1baecf75ad0b016a4d6686` |
| SAM_SQLite | `7bc76f286a91358312b16145e063a3a078f83a7f` |
| SAM_SolarCalculator | `3a36b73cde257d7fcfdd3d866177b419f29af998` |
| SAM_Solver | `3c6f5d53c994a0f158410d8e2e5ef98909ea7c65` |
| SAM_Systems | `05ca0c187bd8647b4ea105dd8c0e230000ccfeab` |
| SAM_Tas | `c267f52f1460551d36d1801bb6b420cff90626da` |
| SAM_Tas_Grasshopper | `01508b8e602eff4504e0b601e6bb832b005ef44f` |
| SAM_UI | `9f515c4c7204b6833c8bd4cd4eb23717426b8d70` |
| SAM_Validation | `002ff0ee4a3df5dbf2dd28667a68bc780b2c41d2` |
| SAM_Windows | `b5bb64e4f1be03b649d12f037a9d53e48deb7da4` |
| SAM_gbXML | `3b96001f6075f1eb6aea341eafab6762528aeaed` |

## Decisions / assumptions
- Quarter-close convention (from Q2): per-repo PR `sow/2026-Qx → master` titled
  "Sync master with sow/2026-Qx (Qx promotion)", merge commit (no squash).
- master is protected ("Protect Master v1": PR + 1 approving review, no bypass)
  in every repo — promotion PRs need a human approver; the bot cannot self-approve.
- Release publication must use the validated artifact (dispatch with
  `publish_release=false`, then release those exact bytes), not a rebuild.
- SAM #123 (manufacturer ventilation) is post-Q3 and not a release item.

## Files changed
- 24 submodule gitlinks; `.github/workflows/occt-cache-warm.yml` (from master); this file.

## Validation
- installer.yml run 214 on `cbd05b6`: H1 PASS, H12 PASS (full-payload provenance
  audit, PR #42, ran clean).
- Owner manual acceptance (2026-09-17) against `SAM_Install_v20260917.214.exe`:
  PASS on every item the owner's own checklist exercised (clean install,
  SAM_UI, Part O x2, Rhino `.rhp`, Grasshopper+SAM, Grasshopper+OCCT with no
  OCCT SDK installed, Revit add-in, Revit 2026/2027+RiR, SAM_UI from host,
  uninstall). That checklist does not 1:1 map onto the formal H1–H12 matrix:
  H9 formally PASS; H11 formally PARTIAL (uninstall PASS, upgrade-over-previous
  not exercised); H3/H4 and H5–H7 formally not separately recorded/not
  exercised (owner smoke acceptance is not a substitute for the version-split
  Rhino gates or a TAS workflow). H8 (Revit 2025) and the dedicated H10
  (`ToSAM_AnalyticalModel`/`TogbXML`) runtime-path test are OWNER-SKIPPED
  (waived), not PASS. Full detail and per-gate evidence in
  `RELEASE_VALIDATION.md` → "Results — 2026-Q3 release candidate (run 214,
  FINAL ACCEPTED)".

## Issues / blockers
- H8 (Revit 2025) and the dedicated H10 runtime-path test remain
  OWNER-SKIPPED for Q3 — no Revit 2025 environment was available and the
  owner waived the dedicated H10 acceptance for this closeout.
- H5–H7 (TAS-specific Grasshopper assembly/UserObject/workflow tests) were not
  separately re-exercised against run 214; the owner's acceptance pass used
  Part O workflows instead. Not explicitly waived — flagged for awareness only.

## Next step
- Quarter-close promotion (per-repo `sow/2026-Q3 → master` PRs, merge commit,
  human-approved per "Protect Master v1"; then publish the run-214 bytes as
  `v20260917.214`; then `sam-bim.github.io#3`) is the natural next step but is
  **out of scope for this closeout** and was not started here.
