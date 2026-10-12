# Deploy: final GenOpt native optimisation integration (PR record)

Branch `feature/genopt-final-deploy-q4` -> `sow/2026-Q4`. Status: pins and gate done, hosted validation green (see Validation); installed upgrade acceptance NOT TESTED (owner manual). No tag, release, installer publication or deployment is authorised by this PR.

## Scope
Move the installer to the accepted final SAM-native optimisation chain (programme PR1-PR9, sizing copies, PR7b-2 acceptance and its D1/D2 protections, Tas result units correction) and prove it packages. SAM_Deploy#62 (PR6 payload gate and the Java retirement) is the baseline; it shipped the runtime but pinned the pre-PR7 tips. No optimisation, SAM_UI, SAM_Tas or SAM code is changed here.

## Upstream acceptance (live SAM-BIM API, 2026-10-12)
All merged into `sow/2026-Q4`, no open PR in SAM, SAM_Tas, SAM_UI, SAM_Tas_Grasshopper, SAM_OpenStudio, SAM_Systems or SAM_Deploy before this one:
- SAM_Tas #93 (PR9 Apply best design), #94 (Sizing copies), #95 (PR7b-2 acceptance record), #96 (D2: failed plant simulation fails the evaluation), #97 (D1: refuse setpoint/glazing on frozen Sizing capacities), #98 (units 4/4).
- SAM_UI #220, #222, #223 (harness), #224 (D1 UI), #225 (docs).
- Tas units set (owner option A): SAM#192, SAM_Tas_Grasshopper#13, SAM_OpenStudio#26, SAM_Tas#98.
The licensed acceptance evidence is the PR7b-2 record (`NATIVE_OPTIMISATION_PR7B2.md` in SAM_Tas) and the SAM_Tas/SAM_UI closeouts; it is machine-local licensed evidence, not re-run here. Known accepted limits: D1 option (a) (Sizing-frozen TBD refused, option (b) deferred to V2); multi-plant-room TPD, internal glazing and large glazing pools were not exercised for lack of inputs.

## Pins (explicit, no `git submodule update --remote`)
| Repo | was | now (Q4 tip) | product content |
|---|---|---|---|
| SAM | `b081065e` | `69f999cf97cf424609f2c4eece6d8a214605bccf` | SAM#186-#190 (units, Optimisation Definition, bindings, aperture GUID fix, try-every-option), #179 icons, #192 units; later commits docs |
| SAM_Tas | `7f2043ac` | `4cb3094cc7c8efea168f37d5f04897be2e9415bc` | #88-#98; later commits docs |
| SAM_Tas_Grasshopper | `a852a6ec` | `d827409a10e8911f9eb6b5e81d1cbb341c2fc0ce` | #8 icons, #13 units; later docs |
| SAM_UI | `245045fc` | `ebe5e09b30b95e43e5d047b3aef2d8c5f01110e9` | #213-#224 incl. #203 icons; later docs |
| SAM_OpenStudio | `5522dd80` | `fb21e03fee89d8c42758c1a84e23ed46e4e79fd9` | #26 units marker (required with the units set), #24 icons, #25 coverage audit; later docs |

The other 19 gitlinks do not move. Every one of them is also ahead on Q4, but only by icon migration, URL fixes, CI fallback edits and agent docs (listed per repo during review: SAM_Systems, SAM_Validation, SAM_Windows, SAM_Mollier, SAM_Psychrometrics, SAM_SolarCalculator, SAM_gbXML, SAM_Rhino_UI, SAM_Solver, SAM_OCCT, ...); none changes GenOpt behaviour, so they are deliberately not upgraded. SAM#179 / SAM_UI#203 / TG#8 / OpenStudio#24 icons arrive with their repos because history is linear; they cannot be separated from the pins.
SAM_Tas builds against SAM, SAM_gbXML, SAM_Mollier, SAM_Psychrometrics, SAM_SolarCalculator, SAM_Systems, SAM_Validation and SAM_Windows; whether the Q3-pinned versions of those still compile with the new SAM/SAM_Tas is proven by the full Release build, not assumed.

## Packaging change
New runtime assembly `SAM.Core.Optimisation.dll` (SAM, netstandard2.0, `System.Text.Json` 8.0.5): referenced by `SAM.Analytical.Tas.GenOpt` (SAM_Tas) and `SAM.Analytical.UI.WPF` (SAM_UI), output to `SAM\build`, no post-build copy of its own. `assert-native-optimisation-payload.ps1` now requires it at the payload root and every staged copy equal to the SAM build (same rule as `SAM.Math.dll`). Dry run on synthetic stages: consistent tree exits 0; missing root copy, stale Rhino copy and missing build output each exit 1. `.iss`, `installer.yml`, H12 and the other gates are unchanged. `RELEASE_VALIDATION.md` H13 lists the new assembly.

## Files changed
5 gitlinks (SAM, SAM_Tas, SAM_Tas_Grasshopper, SAM_UI, SAM_OpenStudio); `.github/scripts/assert-native-optimisation-payload.ps1`; `RELEASE_VALIDATION.md` (H13); this file.

## Validation
Tested content head `d24561185e6a831249dab72545b1936fe2d7fa94` (pins + gate + H13 text + first record). Later commits on this PR are record-only.

**Hosted (GitHub)**
- Validate PR run `38291227798`: success (YAML, repository references, restore + rebuild of the full Release orchestrator at the new gitlinks). Proves the five new pins compile together with the 19 unchanged Q3 pins.
- Installer workflow run `38292747933` (workflow_dispatch, `publish_release=false`, version `v20261012.genopt-final`; no tag or release created, latest release still `v20261006.1`): success. SAMVersion `2026.4.226.0`, InformationalVersion `2026.4.226.0+d245611`.
  - Gate "Assert native optimisation payload": passed. `SAM.Math.dll` `AD1FECC79999`, 6 staged copies equal (SAM root, SAMdependencies, Revit 2025/2026/2027, Rhino package). `SAM.Core.Optimisation.dll` `8384F8879C23`, 5 staged copies equal (SAM root, three Revit years, Rhino package). `SAM.Analytical.Tas.GenOpt.dll` `D5F96C7DED4C`, 5 staged copies equal (same places). No `GenOpt.bat` staged.
  - Reporting/PDF gate passed. H12 (enforced): "No H12 violations found" (1398 files scanned: 430 SAM-owned managed, 4 SAM-owned native, 856 third-party, 108 OCCT SDK). `SAM.Occt.Native.dll` present in the packaged Revit year folders.
  - Inno: "Successful compile (185.516 sec)", `SAM_Install_v20261012.genopt-final.exe`; artifact `SAM_Install` 253,403,517 bytes (CI test artifact, not a release; not downloaded or executed by the agent). Artifact SHA-256 not recorded (not downloaded).

**Local (this workstation, `APPDATA` redirected to a scratch folder so the real SAM install was untouched; evidence `C:\TasOut\deploy-final`, machine-local)**
- Sources: SAM `69f999cf`, SAM_Tas `4cb3094c` (clean checkouts equal to the pins). `SAM.sln` Release 0 errors; `SAM_Tas.sln` Release 0 errors.
- `SAM.Analytical.Tas.GenOpt.Tests` (net8.0, rebuilt `SAM.Core.Optimisation.dll`, `SAM.Math.dll`, `SAM.Analytical.Tas.GenOpt.dll` from those sources): 426 passed, 0 failed, 0 skipped. This is the unlicensed, headless native-optimisation suite (kernel, definition run, tas-model script generation, refusals); it loads the three GenOpt assemblies from disk.
- Gate dry run on synthetic stages (extended gate): consistent tree exits 0; missing root `SAM.Core.Optimisation.dll`, stale Rhino copy and missing build output each exit 1.

**NOT TESTED (needs a human on a Windows machine with the products installed)**
No agent installed or executed the installer; installers are blocked by Group Policy on the agent workstation and installing would modify the owner's real SAM folders. The following are therefore NOT TESTED:
1. Clean install of `SAM_Install_*.exe` on a machine with no SAM.
2. Upgrade over an existing SAM install: `GenOpt.bat` and `config.txt` removed from `%APPDATA%\SAM\resources\Analytical\Tas\GenOpt`, other files in that folder kept, `Documents\SAM\resources\...` mirror untouched (the `[InstallDelete]` from #62 is still not covered by any automated run).
3. Deployed hashes: `SAM.Math.dll`, `SAM.Core.Optimisation.dll`, `SAM.Analytical.Tas.GenOpt.dll` under `%APPDATA%\SAM`, the Revit year folders and `Rhino\...\packages\8.0|9.0\SAM` equal the installer's (compare `Get-FileHash`; expected short hashes above, SHA-256 prefixes).
4. SAM_UI (`SAM Analytical.exe`) Simulate > Optimisation opens, the examples load, no stale-assembly message; Optimisation journey with licensed TAS (Run, Apply best design, Energy Simulation) on a copy of a TBD project.
5. Rhino 8 and 9: Grasshopper loads SAM and the Tas components without assembly conflicts; Tas results show kWh/kW (units set).
6. Revit 2025/2026/2027: add-in loads (the new `SAM.Core.Optimisation.dll` sits beside it); Revit 2025 remains owner-skipped from Q3.
7. Existing SAM functionality regression smoke: SAM_UI open/save a model, Part O workflow, OCCT native available, uninstall.
Q3 carried gaps (H5-H7 TAS Grasshopper tests, H8, dedicated H10, H11 upgrade-over-previous) are unchanged.

## Risks / notes
- Units set: persisted results are not migrated (see SAM `documentation/TasResultUnits-PR.md`); external scripts that divided Tas values by 1000 must stop doing so on newly corrected results.
- The pinned Q4 tips include icon migrations of the five bumped repos; the other 19 repos keep their old (Q3) icons until their own reviewed bumps.
- This PR is not a release. Tag, release asset and publication remain separate owner-approved work.

## Next step
Owner runs the manual list above on a real machine (the installer artifact of run `38292747933` is available for the artifact retention period, or rerun the installer). Then the release decision, separately.
