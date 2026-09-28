# Deploy - Part O Mixed Dwelling Strategies PR4 (ship PR3B/PR3C per-dwelling cooling)

**Status (28 Sep 2026): pins moved; installer build and installed-product smoke - see §3.**
Branch `chore/deploy-parto-mixed-pr4-2026-09-28` from `sow/2026-Q3` `e162a25`. Programme record: SAM_UI
`documentation/PartO-MixedDwellingStrategies-PR4.md` (SAM_UI#137).

## 1. Why

`sow/2026-Q3` pinned SAM, SAM_Systems and SAM_Tas at the PR3C build SHAs, but SAM_UI at `8971cfb0`, which predates
Mixed Part O PR3C (SAM_UI#134, `453ca94`): the shipped application had no per-dwelling active cooling in Mixed Design.
SAM_Tas_Grasshopper was also behind its merged PR3B follow-up (#7).

## 2. Pins

| Submodule | Old pin | New pin | Includes |
|---|---|---|---|
| SAM_UI | `8971cfb0` | `0c7b5ec5` | **SAM_UI#134** PR3C per-dwelling cooling (merge `453ca94`) + closeout; SAM_UI#135 progress-dialog pattern (`596a8a1`); SAM_UI#136 reporting hardening M1/M2 (`8f1b7ee`); **SAM_UI#137** PR4 tests/evidence (merge `d6f098d2`) + closeout `0c7b5ec5` |
| SAM_Tas_Grasshopper | `a4d4f73` | `9ddf8ff` | SAM_Tas_Grasshopper#7: mixed-building Part O diagnostic log named from the run's iteration (needs SAM_Tas#71, already pinned) |
| SAM | `3d6fa80a` | `bc85ba61` | docs only (AGENTS.md) |
| SAM_Systems | `005c4fe1` | `fbef48f` | docs only (AGENTS.md) |
| SAM_Tas | `e7cc0ed4` | `5753ad2` | docs only (AGENTS.md) |

All fast-forwards to the merged `sow/2026-Q3` tips; SAM_UI CI builds SAM, SAM_Systems and SAM_Tas at exactly these tips.
No new project or assembly (SAM_UI#135 adds source files and a XAML style inside existing projects), so the SAM_Deploy#51 payload gate is unchanged.

## 3. Validation

- Validate PR: _pending_
- Installer build (installer.yml dispatch, `publish_release=false`): _pending_
- Installed-product smoke on the mixed cooled route: _pending_

## 4. Open items / next step

- The PR4 large-project finding (TAS TSD per-zone read scaling; the ~5,000-space full-year run is not practical on
  current TAS) is recorded in the SAM_UI PR4 record; it does not block shipping PR3C.
- After merge: `PROJECT_PROGRESS.md` closeout on `sow/2026-Q3` (docs-only, direct), with the merge SHA.
