# Deploy: final GenOpt native optimisation integration (PR record)

Branch `feature/genopt-final-deploy-q4` -> `sow/2026-Q4`. Not merged. Status: pins and gate done, hosted validation in progress (see Validation). No tag, release, installer publication or deployment is authorised by this PR.

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
Filled in as results arrive; see the PR description for the live table.
