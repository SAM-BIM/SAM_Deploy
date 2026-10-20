# Deploy: S06 early installed smoke candidate (PR record)

Roadmap S06 (`SAM/documentation/SIMULATION_ROADMAP_Q4_2026.md`). Branch `feature/s06-installed-smoke-candidate` ->
`sow/2026-Q4` (base `30624abd`). PR: SAM-BIM/SAM_Deploy#66. Supporting PR: SAM-BIM/SAM_OpenStudio#32 (unmerged).
Validated content SHA: `717533c` (`717533c` is the full build, staging, gates and licensed smoke below). Record-only commits
follow; the final PR head and its hosted checks are in the PR description.
Candidate build only. No tag, release, installer publication or deployment is authorised by this PR. Merge needs owner
review. `PROJECT_PROGRESS.md` is not touched (post-merge closeout only).

## Status
Ready for review. On a licensed laptop, an installed candidate built from this SAM_Deploy commit ran Tas, OpenStudio and Both
on the S05 box model from the real ribbon, with no manual `SAM_COMMIT` and no developer folder used. Hosted Validate passed at
`717533c`. The hosted installer run #227 (`publish_release=false`) is in the PR description. S06 is **not** marked Done and
Phase A is not declared complete; both need owner acceptance.

## What BuildAlls_v5 already provided (no change)
`BuildAlls_v5.bat` (+ `BuildAlls_v5.csproj`, local, outside Git) is the developer build. It does the following:
- Builds 26 allowlisted repositories in Debug: Restore/Clean/Rebuild, or Restore/Build with `fast`. The list includes SAM_Validation, SAM_Tas and SAM_OpenStudio, in dependency order.
- Builds from the current checkouts. It never pulls unless given `pull`, never resets, and refuses dirty trees when pulling.
- Checks fetch and push URLs against SAM-BIM.
- Verifies or repairs the native OCCT runtime in `%APPDATA%\SAM`.
- Snapshots the Revit years.
- Writes only through the projects' own post-builds into `%APPDATA%\SAM` (and `Documents\SAM`).

It does not stamp builds, package anything, or copy the producer executables anywhere.

The 2026-10-20 fresh run used the S05 sandbox (`APPDATA`/`USERPROFILE` redirected, real NuGet cache). It finished in 3 min 22 s, exit 0, with 0 errors. It confirmed the following:
- SAM.Core, SAM.Analytical, SAM.Weather and SAM.Analytical.Benchmark are byte-identical in SAM, SAM_Validation, SAM_Tas, the OpenStudio producer folder, SAM_UI and the deployed sandbox.
- The F1 EPW code is present.
- Its side effects: untracked `NuGet\` folders in the 26 repository roots. These were removed after checking that every file in them was newer than the build start.

**It does not give an installed candidate.** Its deployment contains no producers, so Both needs `SAM_BENCHMARK_*` and `SAM_COMMIT`. The OpenStudio route depends on `PATH`.

Dev baseline (BuildAll's own deployed app, developer producers, the S05 setup with 3.10 first on `PATH` and `SAM_COMMIT` for Both):

| Case | Result |
|---|---|
| Tas | PASS: `Succeeded`. 602/602 persisted values equal S05 case 1. |
| OpenStudio | PASS: `Succeeded`, EnergyPlus 25.1.0. 45/45 values equal S05 case 2; the only differences are the 12 run-generated subsurface names. |
| Both | PASS: `Compared`. Snapshot, post-F1 embedded EPW `5afbeb32`, canonical hash, producer exe hashes and `comparison.csv` (`454e42dc`) all equal S05 case 4. |

## Why the installed payload could not run Both, and what changed
1. **The producers were never staged.** `BuildAll_Release` builds `benchmark-tas` and `benchmark-openstudio`, but the payload is `%APPDATA%\SAM`, and no post-build copies an exe there. SAM_UI looks for the producers beside `SAM Analytical.exe` (`AppContext.BaseDirectory`).
2. **A framework-dependent producer cannot start in the app folder.** `SAM Analytical.exe` is self-contained (`SelfContained=true`), so the payload root holds its private .NET 8.0.31 runtime (`hostfxr.dll`, `coreclr.dll`, ...). The installer installs no .NET. A framework-dependent apphost placed beside the app finds that `hostfxr.dll`, runs as self-contained and fails: "You must install or update .NET", exit `0x80008096`. The new gate found this on a staged copy.
3. **`BuildAll_Release` built SAM_UI before SAM_OpenStudio.** Its targets batched the MSBuild task on `%(Solution.Properties)`, which groups solutions by that value. Every `Release|Any CPU` solution therefore ran before the only `Release|x64` one. Since SAM_UI#229 SAM_UI's build requires `SAM_OpenStudio\build\openstudiolib.dll`, so any SAM_UI pin past #229 fails the Release build.
4. **`BuildAll_Release` built SAM_OCCT before SAM_Solver.** The Q4 SAM_OCCT panel solver references `SAM_Solver\build\SAM.Geometry.Solver*`, which fails with CS0234.
5. **Developer-built producers need `SAM_COMMIT`.** Both producers take `samCommit` from the `+<hex>` of `SAM.Analytical.dll`'s InformationalVersion and never fall back to git. Only a SAM_Deploy CI build stamps it.
6. **The OpenStudio CLI was taken from `PATH`.** On this laptop that means ladybug_tools' OpenStudio 3.11 / EnergyPlus 25.2 runs models written by the in-process 3.10 SDK.

Changes (all minimal; no parallel deployment architecture, TAS COM untouched, no third-party binary added):
- `.github/scripts/benchmark-producers-payload.ps1` (new).
  - **`-Mode Stage`** publishes each producer self-contained for `win-x64` over the SAM assemblies BuildAll already built (`BuildProjectReferences=false`). It then copies the producer's own four files beside the app, plus any dependency the payload lacks; here that was one each: `SAM.Analytical.Tas.Benchmark.dll` and `SQLite.Interop.dll`. Existing payload files are never overwritten.
  - **`-Mode Assert`** checks, for each producer:
    - its own files equal the publish output;
    - its runtimeconfig is self-contained, with no `additionalProbingPaths` and no `.runtimeconfig.dev.json`;
    - every `deps.json` asset is present (plus the OpenStudio native DLLs);
    - SAM assemblies and the runtime host (hostfxr/hostpolicy/coreclr/clrjit/System.Private.CoreLib) are byte-identical, and other differing copies are not older;
    - the producer is stamped with the build's InformationalVersion, and `SAM.Analytical.dll` carries `+<hex>`;
    - `--help` exits 0 from the payload.
- `.github/workflows/installer.yml`: two steps, "Stage Benchmark producers" and "Assert Benchmark producers payload", after "Stage payload for installer" and before the existing gates. The existing H12 audit then also enforces the producers' FileVersion and ProductVersion, which their projects already register as SAM-owned.
- `BuildAll_Release.csproj`:
  - `Condition="'%(Solution.Identity)' != ''"` on the four MSBuild calls. This batches per solution entry, so the solutions run in the listed order.
  - The SAM_OCCT entry moves to just after SAM_Solver.
  - A check confirms every cross-repo `..\SAM*\` reference of every non-test project in the 24 pins points to an earlier entry.
  - Each call is otherwise unchanged (see the finding on `CommonCIProps` below).
- Gitlinks: the 23 `sow/2026-Q4` tips that S05 and the dev baseline were built from, all fast-forwards. SAM_OpenStudio points at SAM-BIM/SAM_OpenStudio#32's content `1f4bf60c` (base `d4216f35` + the CLI-selection fix).

  | Repo | was | now |
  |---|---|---|
  | SAM | `69f999cf` | `df27563b` |
  | SAM_BHoM | `c734297b` | `995caace` |
  | SAM_Excel | `befb1acd` | `6669977d` |
  | SAM_GEM | `96719c99` | `1bf41916` |
  | SAM_IFC | `14ae71ab` | `77046bef` |
  | SAM_LadybugTools | `abf0d215` | `0ffbaecf` |
  | SAM_Mollier | `fc73fd69` | `7f61916a` |
  | SAM_Multitasker | `45f6854d` | `1fe5598f` |
  | SAM_OCCT | `25801568` | `dc871f7e` |
  | SAM_OpenStudio | `fb21e03f` | `1f4bf60c` (PR #32, unmerged) |
  | SAM_Psychrometrics | `e8b20498` | `83d53326` |
  | SAM_Revit | `192efab4` | `431d34ef` |
  | SAM_Revit_UI | `64d6d9fc` | `06cf245a` |
  | SAM_Rhino_UI | `6e4f0643` | `24fafda0` |
  | SAM_SQLite | `80ab3b68` | `ec2eb86d` |
  | SAM_SolarCalculator | `9f50c91f` | `277a3a48` |
  | SAM_Solver | `d5e59f52` | `fd63b467` |
  | SAM_Systems | `d5f239e4` | `f0838ca3` |
  | SAM_Tas | `4cb3094c` | `e84aeff6` |
  | SAM_Tas_Grasshopper | `d827409a` | `e94880e6` |
  | SAM_UI | `ebe5e09b` | `df24dffe` |
  | SAM_Validation | `662d7255` | `68eded00` |
  | SAM_Windows | `b6e251d9` | `11bbecfa` |
  | SAM_gbXML | `4228e6ef` | `43b5d018` |

  This includes the pending Q4 icon migrations and every S01-S05 change. A partial bump would ship an untested combination.

## Provenance and runtime decisions
- **`SAM_COMMIT`:** not needed for the installed candidate. Both producers report `samCommit` and `runnerCommit` = `717533c`, the existing CI stamp (`Directory.Build.props`: InformationalVersion = SAMVersion + the **SAM_Deploy** commit, which pins every repository). So in an installed build `samCommit` names the SAM_Deploy commit, not the SAM repository commit. That is the established stamping design, not fabricated. Mapping it to per-repository commits is a provenance-schema question for the owner. The S03 developer-build rule is unchanged: a developer-built producer still needs `SAM_COMMIT`.
- **OpenStudio CLI:** SAM_OpenStudio#32 prefers, among the CLIs found (`PATH`, direct installs, ladybug_tools), the first whose `--version` equals the in-process SDK. With none matching, the first found is kept, as before. This is prefer, not refuse; refusing would be an owner decision. A remaining mismatch stays visible in the S03 manifest (`engine.openStudioSdkVersion`, `energyPlusVersion`, `cli`). No OpenStudio or EnergyPlus binary is packaged: the CLI stays a user installation, and the SDK native DLLs ship through the existing NuGet route.

## Candidate build (local replay of installer.yml at `717533c`)
`evidence/s06-20261020/tools/build-candidate.ps1 -Commit 717533c` works as follows:
- local clone of SAM_Deploy;
- the 24 submodules cloned from the sibling checkouts at their gitlinks, all clean (`submodule-status.txt`);
- `APPDATA`/`USERPROFILE`/`LOCALAPPDATA` sandboxed;
- `SAMVersion=2026.4.0.0` (run number 0 is never a CI run) and `InformationalVersion=2026.4.0.0+717533c`;
- every step body run verbatim from this `installer.yml`. 20/20 steps ran:
  - BuildAll_Release Restore 18 s and Rebuild 426 s;
  - SAM_UI 79 s, SAM_Rhino_UI 18 s, SAM_Revit_UI 2025/2026/2027 with their snapshots;
  - "Stage payload for installer" 100 s, then the two new steps;
  - reporting and native-optimisation gates PASS.

H12: 453 SAM-owned managed files, the producers included, all stamped `2026.4.0.0` / `+717533c`. There is **1 violation, `SAM.Occt.Native.dll` unstamped**, a local-only deviation; see the limits. The producer gate output is `candidate-build/assert-benchmark-producers.log`:
- `benchmark-tas` runs on NETCore + WindowsDesktop 8.0.31. 268 of its 271 dependencies are byte-identical; the other three (`System.Drawing.Common`, `Microsoft.Win32.SystemEvents` pinned by staging, `NetTopologySuite`) are the same version.
- `benchmark-openstudio` runs on NETCore 8.0.31. 199 of 204 are byte-identical; the others are framework facades of the same or newer version.
- Both producers start from the payload.

The isolated install mirrors the `.iss` `[Files]` the app uses into `C:\TasOut\s06\candidate\AppData\SAM`: 1922 files, 921.5 MB. Key files:

| File | FileVersion / ProductVersion | sha256 (12) |
|---|---|---|
| `SAM Analytical.exe` | 2026.4.0.0 / 2026.4.0.0+717533c | `2A0A035E5ABB` |
| `benchmark-tas.exe` | 2026.4.0.0 / 2026.4.0.0+717533c | `3381339CD02E` |
| `benchmark-openstudio.exe` | 2026.4.0.0 / 2026.4.0.0+717533c | `EAD210E7F6D8` |
| `SAM.Analytical.dll` | 2026.4.0.0 / 2026.4.0.0+717533c | `E552BCEB2BE1` |
| `SAM.Weather.dll` (contains F1) | 2026.4.0.0 / 2026.4.0.0+717533c | `0AB850DDC1A6` |
| `SAM.Core.OpenStudio.dll` (PR #32) | 2026.4.0.0 / 2026.4.0.0+717533c | `83DD6CDA11BE` |
| `hostfxr.dll` | .NET 8.0.31 | `4F5A0500CD2A` |

## Installed smoke (licensed laptop, real ribbon, 2026-10-20)
Environment:
- `APPDATA`/`USERPROFILE` set to the isolated candidate profile.
- `PATH` has no developer folder; ladybug's OpenStudio 3.11 `bin` comes **first**, the 3.10 runtime second.
- No `SAM_BENCHMARK_*`, no `SAM_COMMIT`.
- .NET host tracing on.

Engines: TAS 9.5.7.0 (`TBD.exe` `aa658fcd`); OpenStudio 3.10.0 CLI (`46a80a3d`); EnergyPlus 25.1.0-1c11a3d85f.

| Case | Expected | Result |
|---|---|---|
| Tas (Run Simulation > Tas) | Succeeded, valid outputs | **PASS**: `Succeeded`; TBD, TSD and `box.tas-run.json` written. `application.sourceRevision` = `717533c` (unknown on developer builds); every component path is in the candidate folder. Persisted results equal the dev baseline: 602/602 values. |
| OpenStudio (explicit `Budapest.epw` `472ffb4e`) | Succeeded, valid outputs | **PASS**: `Succeeded`. The CLI that ran was **3.10.0** (`openStudioSdkVersion` 3.10.0, `energyPlusVersion` 25.1.0-1c11a3d85f) although 3.11 was first on `PATH`. 45/45 values equal the dev baseline (the 24 listed differences are the 12 renamed subsurface keys on each side). |
| Both (embedded weather) | Both producers succeed, valid comparison | **PASS**: `Compared`. Producers taken from beside the app (`<candidate>\benchmark-*.exe`, the staged hashes); Tas 21.2 s and OpenStudio 7.1 s, both exit 0. `environment.SAM_COMMIT` not set; both report `samCommit` = `runnerCommit` = `717533c`. Weather: embedded, exported EPW `5afbeb32` (post-F1). Snapshot `0c30db14`, canonical hash `05c1e334`, `comparison.csv` `454e42dc`: identical to the dev baseline and S05 case 4. |

.NET host trace for the installed Both run: 3 apphost starts (the app and two producers), dotnet root = the candidate folder, 0 references
to a developer folder (also 0 for Tas and OpenStudio). The user's real `%APPDATA%\SAM`: 2101 files before and after, 0
differences. Installed SAM, Rhino, Grasshopper and Revit folders were not touched.

## Tests and checks
- SAM_OpenStudio#32:
  - local: 51/51 benchmark tests pass, including 9 new selection tests; a mutation check fails 4 of them;
  - hosted: build and spdx pass.
- The producer gate's negative cases were exercised on a copy of the developer payload:
  - before staging: 9 failures;
  - with framework-dependent producers: both fail to start (the defect in 2 above).
- `BuildAll_Release` ordering probes (scratch MSBuild projects), comparing old and new:
  - old: SAM_UI batched with SAM, ahead of SAM_OpenStudio;
  - new: the exact listed order, with both SAM_Revit years kept.
- Hosted: Validate PR passed at `717533c` (run 39386787081; full Release BuildAll). Installer run #227: see the PR description.
- The S05 nine-case matrix was not repeated; there was no regression to chase.

## Findings not fixed here (owner decisions)
- **`CommonCIProps` never reaches the solutions.** When the MSBuild task's items carry `Properties` metadata, the task ignores its own `Properties` parameter (probe). So `TreatWarningsAsErrors=true` and the other `CommonCIProps` were never applied; CI stamping works through the `SAMVersion` / `InformationalVersion` / `SAMSourceRevision` environment variables. Making it effective turns NuGet NU1504 (a duplicate `System.Text.Json` PackageReference in 7 SAM_Revit projects) and probably many compiler warnings into errors. That needs a separate PR.
- **`BuildAll_Debug.csproj`** was not changed. `BuildAlls_v5` is the local Debug path.
- **`samCommit` in installed builds is the SAM_Deploy commit** (see above).
- **SAM_UI's "locate producer" hint** (`SimulateBothEngines`) still names developer folders. It is not reached when the producers are installed.

## Limits of this evidence
- **The Inno Setup EXE was not installed:** `Build_Installer.iss` installs only into the real `{userappdata}\SAM` (no `{app}`) and uninstalls it whole. The smoke used a local replay of the same workflow steps and an isolated mirror of the `[Files]` entries the app uses. Rhino packages, Grasshopper links, Revit years and `install.bat` were not installed or tested.
- **Local replay deviations:**
  - Windows PowerShell 5.1 instead of `pwsh`;
  - .NET SDK 10.0.401;
  - run number 0;
  - native OCCT not built from the SDK: the prebuilt `SAM_OCCT\build` native runtime was seeded, hence the single local H12 violation.

  The hosted installer run is the authoritative staging and gate run.
- **The 3.10 CLI used is a portable copy** under the workspace's `.icon-migration\runtime`, not a standard install. A machine with only ladybug's 3.11 would still run 3.11 (prefer, not refuse), visibly in the manifest.
- **The final SAM_Deploy merge will not be the tested commit:** before merge the SAM_OpenStudio gitlink must move to SAM_OpenStudio#32's merge commit. The tree is identical if `sow/2026-Q4` has not moved; the stamp will change.
- **In CI, the self-contained publish of `benchmark-tas` also writes into `SAM_Tas\build`** (its project fixes `OutputPath` and disables RID subfolders). That happens after the payload is staged and is harmless there; in a developer checkout it would mix runtime files into `SAM_Tas\build`. The script is meant for CI and the clean replay only.

## Files changed
- `.github/scripts/benchmark-producers-payload.ps1` (new)
- `.github/workflows/installer.yml` (+2 steps)
- `BuildAll_Release.csproj` (order: per-entry batching, SAM_OCCT after SAM_Solver)
- 24 gitlinks
- `DEPLOY_S06_SMOKE_CANDIDATE.md` (this record), `evidence/s06-20261020/` (redacted evidence and harness)

## Reproduce
On a licensed laptop with the sibling SAM-BIM checkouts at the pinned commits:
1. `build-candidate.ps1 -Commit <sha>`
2. `install-candidate.ps1`
3. `run-s06-case.ps1` three times:
   - `-Name i1 -Kind TasRunSimulation -Candidate installed`
   - `-Name i2 -Kind OpenStudio -Candidate installed -EpwPath <Budapest.epw>`
   - `-Name i3 -Kind Both -Candidate installed`

Prerequisites, machine-local and not committed:
- TAS licence;
- OpenStudio 3.10 runtime;
- the S05 inputs (`box-aperture.json` `99ba2ab9`, `Budapest.epw` `472ffb4e`);
- the S05/S01b drivers from SAM_UI.

## Next step
1. Owner (GPT-6) review of SAM_OpenStudio#32 and this PR.
2. Merge SAM_OpenStudio#32.
3. Repoint this PR's SAM_OpenStudio gitlink to that merge commit, and rerun Validate and the non-publishing installer.
4. Owner acceptance of S06. Phase A needs owner acceptance of S06 too, and any release remains a separate owner decision.
