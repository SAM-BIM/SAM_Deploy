# Deploy - Part O final (ship PR-4 .. PR-6 and the Iteration 3 / progress / provenance work)

**Status (1 Oct 2026): pins moved; installer build and validation recorded in section 3 as they complete.**
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

(filled in below as runs complete)
