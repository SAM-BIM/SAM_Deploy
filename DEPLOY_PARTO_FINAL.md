# Deploy - Part O final (ship PR-4 .. PR-6 and the Iteration 3 / progress / provenance work)

**Status (1 Oct 2026): pins moved; Validate PR green; installer run 221 green (payload gate passed, nothing published); release regression gate passed (section 3).**
Branch `chore/deploy-parto-final-2026-10-01` from `sow/2026-Q3` `f8df7f3`. Programme record: SAM_UI `documentation/PartO-SystemsInAssessment-PR6.md` (SAM_UI#156).

## 1. Why

`sow/2026-Q3` still pinned the Part O build of 28 Sep (PR3C/PR4). Since then Part O gained, on the merged `sow/2026-Q3` tips: the design-model protection (PR-4), the Systems
materialisation scope (PR-1/PR-2/PR-3), the BaselineReference on every saved result (PR-5), the relative `Path_TSD` locator (SAM#174) and "Systems in this assessment" (PR-6), plus the
Iteration 3, progress-stage and TSD read-performance fixes. Pointer-only; no workflow, project or assembly change.

## 2. Pins

| Submodule | Old pin | New pin | Includes |
|---|---|---|---|
| SAM | `bc85ba61` | `c3890d5c` | SAM#167-#174 (SAM#173 BaselineReference, SAM#174 relative `Path_TSD`) + closeouts |
| SAM_Systems | `fbef48ff` | `09063b4c` | SAM_Systems#33, #34 (PR-3 system scope) + closeouts |
| SAM_Tas | `5753ad2e` | `057faf37` | SAM_Tas#72-#77 (day-major TSD reads, Iteration 3 TPD performance, progress callback) + closeouts |
| SAM_UI | `0c7b5ec5` | `bdcc2a54` | SAM_UI#139-#156 (PR-6 merge `84e7ad9`, closeout `bdcc2a5`) |
| SAM_Tas_Grasshopper | `9ddf8ff` | unchanged | already at the `sow/2026-Q3` tip |

All are fast-forwards to the merged `sow/2026-Q3` tips.

## 3. Validation

- **Validate PR** (build): green on `585d380`.
- **Installer build:** installer.yml run [36824670419](https://github.com/SAM-BIM/SAM_Deploy/actions/runs/36824670419) (#221) on `585d380` (dispatch, `publish_release=false`): `build` success, `release` skipped,
  nothing published. Artifact `SAM_Install_v20261001.221.exe` (artifact `SAM_Install`, 250,089,982 bytes; `h12-audit-report` also uploaded). Reporting/PDF payload gate: passed. The DLL FileVersion
  is `2026.4.221.0+585d380` because a `chore/*` branch falls back to the current UTC quarter (README, Versioning); a dispatch from `sow/2026-Q3` stamps `2026.3.x`.
- **Release regression gate** on the merged `sow/2026-Q3` tips (SAM `c3890d5c`, SAM_Systems `09063b4c`, SAM_Tas `057faf37`, SAM_UI `bdcc2a54`), Release, local:
  `SAM.Tests` 2792/2792; `SAM.Analytical.Systems.Tests` 303/303; `SAM.Analytical.Systems.Mollier.Tests` 123/123; `SAM.Analytical.Tas.TM59.Tests` 1023/1023; `SAM.Analytical.UI.WPF.Tests` 1590/1590.
- **Real model (read-only, no TAS):** real `SAM Analytical.exe` built from the merged SAM_UI tip, UI Automation on a hash-verified copy of the cleaned model (SHA256 `F561161F...0B78`, unchanged afterwards).
  Flat 1 Natural, Flat 2 Nuaire XBC15, Flat 3 Nuaire MRXBOXAB-ECO5-AECV with cooling On, **Check design**: "SAM can build this mixed design ... Nothing was simulated."; Systems in this assessment:
  **2 included** (MVHR Flat 2, MVHR Flat 3) / **3 retained, not assessed** (MV 1 naming AHU1, NV 1, UV 1). No SharedSystem or missing-AHU refusal.

## 4. Not exercised / next step

- The installed-product smoke through the installer (as in SAM_Deploy#58) and any licensed TAS run were not repeated: the PR-6 and Part O changes since #58 are covered by the tests above and the real-model Check; the last
  licensed Mixed acceptance is SAM_UI#154 (PASS).
- After merge: `PROJECT_PROGRESS.md` closeout on `sow/2026-Q3` (docs-only, direct) with the merge SHA.
