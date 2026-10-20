# Deploy: S06 early installed smoke candidate (PR record)

Roadmap S06 (`SAM/documentation/SIMULATION_ROADMAP_Q4_2026.md`). Branch `feature/s06-installed-smoke-candidate` ->
`sow/2026-Q4` (base `30624abd`). PR: SAM-BIM/SAM_Deploy#66. Supporting PRs: SAM-BIM/SAM_OpenStudio#32, merged `a9429f7c`, and SAM-BIM/SAM_Validation#16, merged `e9a83df0`.
Validated content SHA: `717533c` (the full build, staging, gates and licensed smoke below). Repinned content: `b3b8e9e`
(SAM_OpenStudio -> #32's merge `a9429f7c`; installer run #228; payload equivalent to #227, see the Repin section). Record-only
commits follow; the final PR head and its hosted checks are in the PR description.
Candidate build only. No tag, release, installer publication or deployment is authorised by this PR. Merge needs owner
review. `PROJECT_PROGRESS.md` is not touched (post-merge closeout only).

## Status
**Ready to merge (owner approved merging on 2026-10-20). The repin gates passed and the licensed evidence carries forward.** Every check passes except check 9 (provenance labelling). On 2026-10-20 the owner
accepted check 9 as an explicitly documented S06 limitation; it is recorded as that, not as PASS. The hosted installer EXE built from this
commit (run #227, `publish_release=false`) was genuinely installed with Inno Setup into an isolated profile. From it, Tas,
OpenStudio and Both ran on the S05 box model from the real ribbon on a licensed laptop: all three PASS, numerically identical
to S05, with no `SAM_COMMIT`/`SAM_BENCHMARK_*`, no developer folder, OpenStudio 3.11 first on `PATH` and the SDK-matching
3.10 CLI selected. The uninstaller then removed everything. Hosted Validate passed at `717533c` and at the record heads.
The accepted limitation: in an installed build both producers report `samCommit` = `runnerCommit` = the **SAM_Deploy**
commit (`717533c`), and `comparison.md` prints it as "SAM commit" (check 9 below). SAM-BIM/SAM_Validation#16 documents this
in `SCHEMA.md`. S06 is marked Done only in the roadmap closeout after the approved merges.

## Acceptance matrix (2026-10-20)
| # | Check | Result | Evidence |
|---|---|---|---|
| 1 | Isolated Release build of `installer.yml` | **PASS**: hosted run #227 at `717533c`, every step green; local replay 20/20 steps | `installer-exe/hosted-run-227.txt`, `candidate-build/steps.txt` |
| 2 | Staging and payload gates (producer dependencies, self-contained runtime, identical SAM assemblies, versions, producer start) | **PASS** (hosted): both producers start from the payload; 268/271 and 199/204 dependencies byte-identical (the rest same version, or newer framework facades); H12 0 violations; stamp `2026.4.227.0+717533c`. Local replay: PASS except its known unstamped `SAM.Occt.Native.dll` (local seed) | `installer-exe/hosted-run-227.txt`, `candidate-build/` |
| 3 | Gitlinks = approved Q4/S05 baseline, apart from the reviewed OpenStudio fix | **PASS**: this PR changes 24 gitlinks: 23 move to today's `sow/2026-Q4` tips, and the 24th is the supporting SAM_OpenStudio content pin. Of the 23, 21 equal the S05 build (`SAM_UI/documentation/evidence/s05-20261020/build-revisions.txt`) exactly, and SAM `62b54156`→`df27563b` and SAM_UI `ade096d0`→`df24dffe` are docs-only; SAM_OpenStudio `1f4bf60c` = Q4 tip `d4216f35` + #32 | this section |
| 4 | Installed candidate, owner's installation untouched | **PASS (genuine installer)**: the hosted EXE installed silently into an isolated profile (exit 0; 1760 files in `{userappdata}\SAM`, plus the Grasshopper, Rhino-package and Revit-add-in files and `install.bat`) and uninstalled cleanly (exit 0, "Removed all? Yes"). The owner's real `%APPDATA%\SAM`, Grasshopper, Rhino packages, Revit add-ins and `Documents\SAM`: 2518 entries, 0 differences across both | `installer-exe/` |
| 5a | Tas only, real ribbon | **PASS**: `Succeeded` | `runs/x1-installer-tas/` |
| 5b | OpenStudio only, real ribbon, explicit EPW | **PASS**: `Succeeded`, EnergyPlus exit 0 | `runs/x2-installer-openstudio/` |
| 5c | Both, real ribbon, embedded weather | **PASS**: `Compared`, both producers exit 0 (one harness intervention, see below) | `runs/x3-installer-both-embedded/` |
| 6 | No `SAM_COMMIT` / `SAM_BENCHMARK_*`; executable resolution captured | **PASS**: all unset (`environment.txt`, manifest `environment`). The app and both producers ran from `{userappdata}\SAM`; .NET dotnet root = that folder; 0 developer-folder references in the host traces | `corehost-trace-summary.txt` per case |
| 7 | OpenStudio 3.11 first on `PATH` → SDK-matching 3.10 CLI | **PASS**: `PATH` = ladybug 3.11.0 first, 3.10.0 second; manifest `engine.cli` = 3.10.0 (`46a80a3d`), SDK 3.10.0, EnergyPlus 25.1.0. Explicit CLI path: code path unchanged, unit test `ExplicitPath_IsUnchanged_AndNeverVersionChecked`. Neither the ribbon nor the producer takes a CLI path, so it was not exercised end to end | `runs/x2-installer-openstudio/openstudio-run.json` |
| 8 | Numerical comparison with S05 | **PASS**: Tas 602/602 values equal S05 case 1. OpenStudio: the raw comparison against S05 case 2 reports `exactMatch: false` (45/45 numbers, 24 differences), kept as measured. Numeric equality was shown separately (`runs/os-subsurface-mapping.txt`, `tools/map-subsurface-refs.ps1`). Every difference is one of 4 run-generated subsurface names (3 fields each). The result's `Reference` is the GUID of the Panel hosting the window: SAM_OpenStudio `Modify/AddResults.cs` (`LookupPanel`, `Referenced`) attaches each subsurface result to its host panel. The check confirms structurally that each of the 4 references is exactly one `Panel` object of the input model (`box-aperture.json` `99ba2ab9`), a `WallExternal` hosting exactly one aperture, so the fixture maps panel to window unambiguously. Through that reference each generated name maps 1:1 to one name on the other side, and the mapped values are exactly equal. The check fails on a missing or ambiguous mapping. The claim is scoped to these four comparisons; it is not a general result-identity rule. Both: snapshot, embedded EPW, canonical hash and `comparison.csv` `454e42dc` equal S05 case 4 | `runs/cmp-*-x*.json`, `runs/os-subsurface-mapping.txt`, `runs/both-summary-installer.txt` |
| 9 | Provenance: SAM_Deploy commit not described as the SAM commit | **Not PASS: accepted limitation** (owner decision 2026-10-20: documented S06 exception, no new stamping; documented by SAM-BIM/SAM_Validation#16). As measured, the check fails: SAM_UI's manifest is right. Under `provenance.application`, `sourceRevision` = `717533c` (the extracted SHA), and `entryAssembly.informationalVersion` and every `components[].informationalVersion` = `2026.4.227.0+717533c` (the full stamp). `sourceRevisionOf` is explanatory text saying the revision is the SAM_Deploy installer stamp. The producers' B1a documents report `samCommit` = `runnerCommit` = `717533c`, the SAM_Deploy commit. SAM_Validation `docs/benchmark/SCHEMA.md` defines `samCommit` as "SAM source revision used for the run", and roadmap decision 6 as the SAM commit the producers were built from. `comparison.md` shows "SAM commit \| 717533c \| 717533c". S05 reported SAM `62b54156`, SAM_Tas `e84aeff6` and SAM_OpenStudio `d4216f3` in the same fields. The value is traceable (SAM_Deploy `717533c` pins SAM `df27563b`, SAM_Tas `e84aeff6`, SAM_OpenStudio `1f4bf60c`) but mislabelled | `runs/x3-installer-both-embedded/benchmark-*.json`, `comparison.md` |
| 10 | Final-head CI and tests | **PASS**: see [Tests and checks](#tests-and-checks) | |

Gitlink check (2026-10-20): `git ls-tree` of this branch against `origin/sow/2026-Q4` of each sibling checkout, every
remote `github.com/SAM-BIM/*`. All pins equal the Q4 tip except SAM_OpenStudio (`1f4bf60c`, whose parent is the Q4 tip
`d4216f35`).

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
| OpenStudio | PASS: `Succeeded`, EnergyPlus 25.1.0. Raw comparison against S05 case 2: `exactMatch: false`, 45/45 numbers, 24 differences. All 24 are the 4 run-generated subsurface names, mapped 1:1 through their host-panel reference (one aperture per panel in this fixture), with equal values (`runs/os-subsurface-mapping.txt`). |
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
- Gitlinks: 24 change. 23 move to the `sow/2026-Q4` tips that S05 and the dev baseline were built from, all fast-forwards. The 24th, SAM_OpenStudio, is the supporting content pin: it points at SAM-BIM/SAM_OpenStudio#32's content `1f4bf60c` (base `d4216f35` + the CLI-selection fix).

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
  | SAM_OpenStudio | `fb21e03f` | `1f4bf60c` (PR #32 content, tested), repinned to `a9429f7c` (#32's merge commit) in `b3b8e9e` |
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
- **`SAM_COMMIT`:** not needed to run the installed candidate. Both producers fall back to the `+<hex>` of
  `SAM.Analytical.dll`'s (`samCommit`) and their own assembly's (`runnerCommit`) InformationalVersion. A SAM_Deploy build
  stamps every assembly with SAMVersion + the **SAM_Deploy** commit (`installer.yml` "Compute SAMVersion";
  `Directory.Build.props`), so both report `717533c`. The value is real and traceable through this commit's gitlinks, but
  the B1a fields and `comparison.md` call it the SAM / runner commit (check 9). This predates S06: the stamping and the
  producers' fallback come from earlier work, and S03 flagged it.
  **Owner decision (2026-10-20): accepted as an explicitly documented S06 limitation; no new stamping in S06.**
  - The documentation is SAM-BIM/SAM_Validation#16 (`docs/benchmark/SCHEMA.md`, "Revision fields in installer builds").
    In a SAM_Deploy installer build without overrides, both fields hold the SAM_Deploy build revision. The build's stamp
    `<year>.<quarter>.<run>.0+<revision>` identifies such a build. SAM_UI's run manifest records it under
    `provenance.application`: the full stamp in `entryAssembly.informationalVersion` and `components[].informationalVersion`,
    and the extracted SHA in `sourceRevision`. `sourceRevisionOf` is explanatory text only.
  - **To obtain the actual source revisions**, read the gitlinks the stamped SAM_Deploy revision pins:
    `git ls-tree <revision> SAM SAM_Tas SAM_OpenStudio` in SAM-BIM/SAM_Deploy. For this candidate, `717533c` gives SAM
    `df27563b`, SAM_Tas `e84aeff6` and SAM_OpenStudio `1f4bf60c`. The merged commit's stamp resolves the same way.
  - **Existing records keep their meaning; no historical value is redefined.** S05 and earlier developer runs with
    `SAM_COMMIT` hold repository revisions.
  - Per-repository stamping, or a field naming the revision kind, remains possible future work and is not part of S06.
    That work would mean: `BuildAll_Release` passes each solution `InformationalVersion=$(SAMVersion)+<gitlink>`, and the
    H12 and producer stamp checks and SAM_UI's wording change with it.

  The S03 developer-build rule is unchanged: a developer-built producer still needs `SAM_COMMIT`.
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

## Genuine installer acceptance (hosted EXE, licensed laptop, real ribbon, 2026-10-20)
This is the S06 acceptance run. The earlier mirrored-payload smoke (next section) is kept as supporting evidence.

**Installer.** `SAM_Install_s06-smoke-candidate.exe` is the `SAM_Install` artifact of hosted run #227 at `717533c`
(264,441,155 bytes, sha256 `50ddbc61…`, Inno Setup 6.7.1, stamp `2026.4.227.0+717533c`). The script
`tools/install-hosted-exe.ps1` installs it as follows:
- It runs the unmodified EXE with `/VERYSILENT /SUPPRESSMSGBOXES /NORESTART /SP- /DIR=… /LOG=…`.
- `USERPROFILE`, `APPDATA`, `LOCALAPPDATA` and `TEMP` point into `C:\TasOut\s06\installer-exe\Profile`. Inno resolves
  `{userappdata}`/`{userdocs}` with `SHGetFolderPath`, which expands the registry's `%USERPROFILE%`-based shell folders
  from the process environment. The script first checks this with a native `SHGetFolderPath` probe in the same environment,
  and refuses to run if the probe does not resolve into the profile.
- It lists the owner's real folders that the `.iss` writes to (path, size, write time), before and after.

Results:
- **Install**: exit 0. The log shows every directory under the isolated profile. 2920 files were installed: `SAM` 1760
  (908 MB), Grasshopper 32, Rhino packages 252 and Revit add-ins 29, plus `install.bat`, which exited 0. Inno's HKCU
  uninstall key (`…B3D3AC3CFD3C}}_is1`, a literal `}}` from the `.iss` AppId) was created and pointed only into the profile.
  No SAM Inno registration existed before: the owner's real `%APPDATA%\SAM` has no `unins000.*`.
- **Uninstall**: exit 0, "Removed all? Yes". Every installed folder was deleted and the HKCU key was removed.
- **Owner's real folders** (`%APPDATA%\SAM`, `Grasshopper`, `McNeel\Rhinoceros\packages`, `Autodesk\Revit\Addins`,
  `Documents\SAM`): 2518 entries, 0 differences across the install and the uninstall.
- **Installed tree against the mirrored candidate**: 1629 common paths. The only other differences are the native OCCT
  runtime: the local replay seeded a prebuilt OCCT/VTK/Qt runtime (293 files), while the hosted build ships its own,
  including per-Revit-year copies (131 files). `unins000.*` is also new. Every app, producer, SAM and OpenStudio file is
  present. SAM-owned files differ only in their stamp (`.227` against `.0`).
- **Hash chain**: the producers staged in run #227 (`benchmark-tas.exe` `D1D2B4A4B3EF`, `benchmark-openstudio.exe`
  `78AAD32FA86F`) are the installed files, and they are the executables the Both manifest records.

**Licensed runs** (`tools/run-s06-case.ps1 -Candidate installer`). The environment:
- `APPDATA` = the isolated profile;
- ladybug's OpenStudio 3.11.0 first on `PATH`, the 3.10.0 runtime second, and no developer folder;
- no `SAM_COMMIT`, `RUNNER_COMMIT` or `SAM_BENCHMARK_*`;
- .NET host tracing on.

Engines: TAS 9.5.7.0, OpenStudio 3.10.0 CLI, EnergyPlus 25.1.0-1c11a3d85f.

| Case | Result | Executable resolution | Against S05 |
|---|---|---|---|
| x1 Tas (Run Simulation > Tas) | **PASS**: `Succeeded`, app exit 0; TBD, TSD and `box.tas-run.json` written | 1 apphost start, `{userappdata}\SAM\SAM Analytical.dll`; dotnet root = that folder; all 4 manifest components in the install; `sourceRevision` `717533c` | 602/602 values equal S05 case 1 (and the mirrored run i1) |
| x2 OpenStudio (explicit `Budapest.epw` `472ffb4e`) | **PASS**: `Succeeded`, EnergyPlus exit 0, 10 warnings, 0 severe, 0 fatal; 13 results | CLI = 3.10.0 (`46a80a3d`) although 3.11.0 was first on `PATH`; SDK 3.10.0; `samOpenStudioVersion` `2026.4.227.0+717533c` | raw `exactMatch: false` against S05 case 2 (45/45 numbers, 24 differences). After uniquely mapping the 4 run-generated subsurface names through their host-panel reference (one aperture per panel in this fixture), all values are equal (`runs/os-subsurface-mapping.txt`) |
| x3 Both (embedded weather) | **PASS**: `Compared`; Tas 21.9 s and OpenStudio 6.0 s producers, both exit 0 | 3 apphost starts: the app, `benchmark-tas.dll` and `benchmark-openstudio.dll`, all from `{userappdata}\SAM`; 0 developer-folder references | snapshot `0c30db14`, embedded EPW `5afbeb32` (post-F1), canonical hash `05c1e334` and `comparison.csv` `454e42dc` equal S05 case 4 |

The Both comparison gate reads "Fail (numerical Fail, coverage Warn, provenance Pass, reconciliation Pass)", identical to
S05 case 4 (engine disagreement, recorded and not investigated here).

**Harness intervention (x3).** The driver's "Yes" to "Use the model's weather data for both engines?" was ignored: the
Win32 MessageBox was inactive (the S05 BM_CLICK trap; `drive-both.ps1` uses `Invoke-El` without `WM_ACTIVATE`). The driver
nevertheless logged "Run started". After 10 min the dialog was still open, and the same "Yes" was sent with
`WM_ACTIVATE` + `BM_CLICK` (logged at `driver.log` line 9). The run then completed normally. The app behaviour is not
affected; the intervention is in the harness only.

## Repin to SAM_OpenStudio#32's merge commit and payload equivalence
Done on 2026-10-20, after the owner approved the merge sequence in chat.
- **Merges.**
  - SAM-BIM/SAM_OpenStudio#32 was merged at approved head `3082dc6` as `a9429f7cea975a8f660bac4407779c3828e86627`
    (parents `d4216f35`, `3082dc6a`). Its post-merge Build passed (run 39409026705), and the closeout is `7f21665`.
  - SAM-BIM/SAM_Validation#16 was merged at approved head `ed7a878` as `e9a83df0c2e1162d0a22eb1e010a508044117e12`. Its
    post-merge Build passed (run 39409164929), and the closeout is `2a3acfa`.
- **Repin** (`b3b8e9e`): only the SAM_OpenStudio gitlink changed, `1f4bf60c` -> `a9429f7c`, the exact merge commit and
  not the closeout tip. `git diff --stat 1f4bf60c a9429f7c` lists only
  `documentation/S06-OpenStudio-Cli-Selection-PR.md`, so the executable source is unchanged. The other 23 gitlinks and
  `.gitmodules` are unchanged, and SAM_Validation stays `68eded00`.
- **Gates at `b3b8e9e`** (hosted):
  - Validate passed (run 39409232293).
  - Installer run #228 (39409260663, `publish_release=false`, release job skipped) passed:
    - stamp `2026.4.228.0+b3b8e9e`;
    - all 24 checked-out pins equal the `b3b8e9e` gitlinks;
    - Stage: 271 and 204 dependencies, 1 added each;
    - Assert: 268/271 and 199/204 byte-identical, the rest the same or a newer version; both producers start from the
      payload;
    - H12: 0 violations.
  - Artifact: `SAM_Install_s06-repin-candidate.exe`, 264,387,711 bytes, sha256 `a9284962…f58c9`; zip digest
    `19fdbd4b…`. See `repin/installer-run-228.txt`.
- **Rebuilt-payload equivalence** (local, `repin/payload-equivalence-227-228.txt`). Both hosted EXEs (#227 and #228)
  were installed for real, one after the other, each into its own isolated profile with `install-hosted-exe.ps1`.
  Each was inventoried (`tools/payload-inventory.ps1`) and uninstalled, and the inventories were compared
  (`tools/compare-payloads.ps1`). The owner's real folders were unchanged: 2518 entries, 0 differences, every time.
  Of the same 1759 paths (Inno's per-install `unins000.dat` excluded):

  | Class | Files |
  |---|---|
  | byte-identical: every third-party, .NET runtime and OpenStudio/EnergyPlus file, including `hostfxr`, `hostpolicy`, `coreclr`, `clrjit` and `System.Private.CoreLib` 8.0.31, `openstudiolib.dll`, and the three `runtimeconfig.json` files | 1104 |
  | expected stamp, binary: same length; FileVersion `2026.4.227.0` -> `2026.4.228.0`; ProductVersion `+717533c` -> `+b3b8e9e` | 474 |
  | expected stamp, text: the `deps.json` files, identical after normalising the stamp and SAM_OCCT's build-time `AssemblyVersion("1.0.*")` (days since 2000 . seconds/2, so `1.0.9789.14597` -> `1.0.9789.19474`) | 51 |
  | `.pdb` debug symbols, reported separately: not executable, dependency or runtime content. A deterministic rebuild changes them with the stamp (the PDB ID in the header, and the compressed compilation metadata naming the re-stamped referenced assemblies); this explanation is inferred from where the bytes differ | 129 |
  | the Inno uninstaller's own label (`s06-smoke-candidate` -> `s06-repin-candidate`) | 1 |
  | other differences (drift) | **0** |

  Result: no executable, dependency or runtime drift. The genuine-installed licensed results (x1 Tas, x2 OpenStudio, x3
  Both, on #227) **carry forward to the repinned build**; the smoke cases were not repeated. Two installs of the #227 EXE
  reproduce the committed `installer-exe/installed-manifest.tsv` exactly, except `unins000.dat`.
## Installed smoke on the mirrored payload (supporting, 2026-10-20)
Environment:
- `APPDATA`/`USERPROFILE` set to the isolated candidate profile.
- `PATH` has no developer folder; ladybug's OpenStudio 3.11 `bin` comes **first**, the 3.10 runtime second.
- No `SAM_BENCHMARK_*`, no `SAM_COMMIT`.
- .NET host tracing on.

Engines: TAS 9.5.7.0 (`TBD.exe` `aa658fcd`); OpenStudio 3.10.0 CLI (`46a80a3d`); EnergyPlus 25.1.0-1c11a3d85f.

| Case | Expected | Result |
|---|---|---|
| Tas (Run Simulation > Tas) | Succeeded, valid outputs | **PASS**: `Succeeded`; TBD, TSD and `box.tas-run.json` written. `application.sourceRevision` = `717533c` (unknown on developer builds); every component path is in the candidate folder. Persisted results equal the dev baseline: 602/602 values. |
| OpenStudio (explicit `Budapest.epw` `472ffb4e`) | Succeeded, valid outputs | **PASS**: `Succeeded`. The CLI that ran was **3.10.0** (`openStudioSdkVersion` 3.10.0, `energyPlusVersion` 25.1.0-1c11a3d85f) although 3.11 was first on `PATH`. Raw comparison against the dev baseline: `exactMatch: false` (45/45 numbers, 24 differences). All 24 are the 4 run-generated subsurface names, mapped 1:1 through their host-panel reference (one aperture per panel in this fixture), with equal values (`runs/os-subsurface-mapping.txt`). |
| Both (embedded weather) | Both producers succeed, valid comparison | **PASS**: `Compared`. Producers taken from beside the app (`<candidate>\benchmark-*.exe`, the staged hashes); Tas 21.2 s and OpenStudio 7.1 s, both exit 0. `environment.SAM_COMMIT` not set; both report `samCommit` = `runnerCommit` = `717533c`. Weather: embedded, exported EPW `5afbeb32` (post-F1). Snapshot `0c30db14`, canonical hash `05c1e334`, `comparison.csv` `454e42dc`: identical to the dev baseline and S05 case 4. |

.NET host trace for the installed Both run: 3 apphost starts (the app and two producers), dotnet root = the candidate folder, 0 references
to a developer folder (also 0 for Tas and OpenStudio). The user's real `%APPDATA%\SAM`: 2101 files before and after, 0
differences. Installed SAM, Rhino, Grasshopper and Revit folders were not touched.

## Tests and checks
- SAM_OpenStudio#32:
  - local: 51/51 benchmark tests pass, including 9 new selection tests; a mutation check fails 4 of them. They were rerun
    on 2026-10-20 at the PR head `3082dc6` (code = `1f4bf60c`) and passed 51/51 again:
    `dotnet test benchmark/SAM.Analytical.OpenStudio.Benchmark.Tests/SAM.Analytical.OpenStudio.Benchmark.Tests.csproj -c Release -p:Platform=x64 --filter "TestCategory!=Simulation"`;
  - hosted: build and spdx pass at `3082dc6`.
- The producer gate's negative cases were exercised on a copy of the developer payload:
  - before staging: 9 failures;
  - with framework-dependent producers: both fail to start (the defect in 2 above).
- `BuildAll_Release` ordering probes (scratch MSBuild projects), comparing old and new:
  - old: SAM_UI batched with SAM, ahead of SAM_OpenStudio;
  - new: the exact listed order, with both SAM_Revit years kept.
- Hosted (GitHub):
  - Validate PR passed at `717533c` (SAM_Deploy run 39386787081; full Release BuildAll), at record heads `1faa383` (run
    39390296835), `2665546` (run 39396367650) and `bcc6735` (run 39399003022). Run 39398892361 is SAM_Validation#16's
    Build (Windows) at `cb84fd9`, not a SAM_Deploy run; an earlier version of the PR description attributed it to
    `bcc6735` by mistake. Later heads: see the PR description;
  - Build & Release SAM-BIM Installer run #227 (39389974089, `workflow_dispatch`, `publish_release=false`) passed at
    `717533c`, including the two new producer steps and H12 (0 violations).
  - The final record head's Validate run is in the PR description.
- Local (this laptop, not CI): the installer replay, the genuine install and uninstall, and the six licensed real-UI runs
  (i1-i3 mirrored, x1-x3 genuine). SAM_Deploy has no unit-test project; its gates run inside `installer.yml`.
- The S05 nine-case matrix was not repeated; there was no regression to chase.

## Findings not fixed here (owner decisions)
- **`CommonCIProps` never reaches the solutions.** When the MSBuild task's items carry `Properties` metadata, the task ignores its own `Properties` parameter (probe). So `TreatWarningsAsErrors=true` and the other `CommonCIProps` were never applied; CI stamping works through the `SAMVersion` / `InformationalVersion` / `SAMSourceRevision` environment variables. Making it effective turns NuGet NU1504 (a duplicate `System.Text.Json` PackageReference in 7 SAM_Revit projects) and probably many compiler warnings into errors. That needs a separate PR.
- **`BuildAll_Debug.csproj`** was not changed. `BuildAlls_v5` is the local Debug path.
- **`samCommit`/`runnerCommit` in installed builds are the SAM_Deploy commit**. This is check 9, an owner-accepted and documented limitation (SAM_Validation#16).
- **`drive-both.ps1` (SAM_UI S05 harness) answers the weather MessageBox without `WM_ACTIVATE`**; it should use
  `Click-DialogButton`. Harness only.
- **SAM_UI's "locate producer" hint** (`SimulateBothEngines`) still names developer folders. It is not reached when the producers are installed.

## Limits of this evidence
- **Genuine installer, but an isolated profile:** the hosted EXE was installed and uninstalled for real. The profile was
  redirected through the environment, which makes Inno's `{userappdata}` resolve there; nothing was installed into the
  owner's own profile. Rhino, Grasshopper and Revit were not started, so their installed files are present but not tested.
  The earlier mirrored-payload smoke (i1-i3) is a staged-payload copy, not an installer test.
- **Local replay deviations:**
  - Windows PowerShell 5.1 instead of `pwsh`;
  - .NET SDK 10.0.401;
  - run number 0;
  - native OCCT not built from the SDK: the prebuilt `SAM_OCCT\build` native runtime was seeded, hence the single local H12 violation.

  The hosted installer run is the authoritative staging and gate run.
- **The 3.10 CLI used is a portable copy** under the workspace's `.icon-migration\runtime`, not a standard install. A machine with only ladybug's 3.11 would still run 3.11 (prefer, not refuse), visibly in the manifest.
- **The explicit CLI-path override** is covered by code inspection and a unit test only (no UI or producer option sets it).
- **The final SAM_Deploy merge will not be the tested commit:** before merge, only the SAM_OpenStudio gitlink moves, to SAM_OpenStudio#32's exact merge commit. Its source differs from `1f4bf60c` only by #32's record document, as long as `sow/2026-Q4` has not moved, and the stamp will change. The new head's Validate, installer gates and payload-equivalence evidence decide whether the licensed results carry forward (Next step 3-5).
- **In CI, the self-contained publish of `benchmark-tas` also writes into `SAM_Tas\build`** (its project fixes `OutputPath` and disables RID subfolders). That happens after the payload is staged and is harmless there; in a developer checkout it would mix runtime files into `SAM_Tas\build`. The script is meant for CI and the clean replay only.

## Files changed
- `.github/scripts/benchmark-producers-payload.ps1` (new)
- `.github/workflows/installer.yml` (+2 steps)
- `BuildAll_Release.csproj` (order: per-entry batching, SAM_OCCT after SAM_Solver)
- 24 gitlinks: 23 Q4-tip pins, plus the supporting SAM_OpenStudio pin (`1f4bf60c` while #32 was open, now #32's merge commit `a9429f7c`); `.gitmodules` unchanged
- `DEPLOY_S06_SMOKE_CANDIDATE.md` (this record), `evidence/s06-20261020/` (redacted evidence and harness)

## Reproduce
Genuine installer (the acceptance run), on a licensed laptop with no SAM Inno registration:
1. `gh run download <installer run id> --repo SAM-BIM/SAM_Deploy --name SAM_Install --dir <new empty folder>`
2. `install-hosted-exe.ps1 -Installer <SAM_Install_*.exe>`
3. `run-s06-case.ps1` three times:
   - `-Name x1 -Kind TasRunSimulation -Candidate installer`
   - `-Name x2 -Kind OpenStudio -Candidate installer -EpwPath <Budapest.epw>`
   - `-Name x3 -Kind Both -Candidate installer`
4. `compare-persisted.ps1` against the S05 case outputs; `summarise-both.ps1 -Cases x3`
5. `install-hosted-exe.ps1 -Mode Uninstall`

Mirrored payload (supporting), with the sibling SAM-BIM checkouts at the pinned commits:
1. `build-candidate.ps1 -Commit <sha>`
2. `install-candidate.ps1`
3. `run-s06-case.ps1 -Candidate installed`, cases i1-i3 as above.

Prerequisites, machine-local and not committed:
- TAS licence;
- OpenStudio 3.10 runtime;
- the S05 inputs (`box-aperture.json` `99ba2ab9`, `Budapest.epw` `472ffb4e`);
- the S05/S01b drivers from SAM_UI.

## Next step
Steps 1-5 of the owner-approved sequence are done (see the Repin section): #32 merged and closed out, #16 merged and
closed out, SAM_OpenStudio repinned to `a9429f7c`, Validate and installer #228 green at `b3b8e9e`, and payload
equivalence PASS, so the licensed evidence carries forward. Remaining:
6. Merge this PR at its final head once its final-head Validate passes (owner approval given 2026-10-20), then do its
   `PROJECT_PROGRESS.md` closeout.
7. Close out S06 in the SAM roadmap through a reviewed docs PR: S06 Done, with the merge SHAs and the accepted limitation
   (check 9 stays "Not PASS: accepted limitation"). The roadmap PR needs its own review and merge authorization. Any
   release remains a separate owner decision.