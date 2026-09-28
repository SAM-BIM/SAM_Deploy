# Deploy - Part O Mixed Dwelling Strategies PR4 (ship PR3B/PR3C per-dwelling cooling)

**Status (28 Sep 2026): pins moved; installer run 220 green (payload gate, H12 no violations); installed-product smoke
of the mixed cooled route PASSED (§3).**
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

- **Validate PR:** green on `87d3560` (build, 14m43s).
- **Installer build:** installer.yml run [36459447134](https://github.com/SAM-BIM/SAM_Deploy/actions/runs/36459447134)
  on `87d3560` (dispatch, `publish_release=false`): success, release job skipped, nothing published.
  - Artifact `SAM_Install_v20260928.220.exe`, 250,292,675 bytes, SHA-256
    `21f54cf1eb9cb06028496524f9984fce0b63b904b2a7545a18c9b43a660e4430`. SAMVersion `2026.3.220.0+87d3560`.
  - Stage payload, *Assert reporting/PDF payload*, H12 audit: all pass; H12 report: **Violations: None.**
- **Installed-product smoke (28 Sep, owner's laptop, licensed TAS).**
  - The dev build in `%APPDATA%\SAM` (1,434 files, version 1.0.0) was moved to `%APPDATA%\SAM.dev-backup-2026-09-28`
    first (WMI-launched `move`, outside the Claude desktop app's MSIX container). A container shadow copy in
    `…\Packages\Claude_pzs8sxrjxfjjc\LocalCache\Roaming\SAM` (1,407 files, made by this session's SAM_UI builds) was
    moved to `SAM.shadow-2026-09-28` beside it, so in-container checks read the real folder. Nothing deleted.
  - Silent install (`/VERYSILENT /SUPPRESSMSGBOXES /NORESTART`, WMI-launched): exit 0 in 140 s, 1,711 files (as run
    219). Installed `SAM.Analytical.UI.WPF.dll` carries the PR3C code (`SimulatePartOMaterialisationSystems`,
    `PartOMixedSystemsCall`, `checkBox_Cooling`), `SAM.Analytical.dll` `PartOCooledDwelling`, the Grasshopper `.gha`
    `RunPartOIteration` (#7).
  - The PR3C acceptance case through the installed `%APPDATA%\SAM\SAM Analytical.exe` (2026.3.220.0+87d3560,
    confirmed by the process path), UI Automation: copy of the PR2 clean baseline (SHA-256 `89a8ac7b…9446`,
    unchanged afterwards); Flat 1 Natural, Flat 2 MVHR automatic, Flat 3 MVHR + Nuaire MRXBOXAB-ECO5-AECV.
    - Cooling on for Flat 1 → refused: "Active cooling is on the MVHR supply: select MVHR (or Optimised MVHR) first
      for Flat 1." Flat 3 → `On`; readiness "1 with active cooling (whole building on the TAS Systems route)". PASS.
    - Check design → "SAM can build this mixed design … Flat 3 (Nuaire … at 80 l/s); the whole building runs on the
      TAS Systems route. Nothing was simulated." PASS.
    - Build & Run (4.4 min) → "Final mixed run: FAIL — 1 dwelling pass · 2 fail · 0 not assessed · communal corridor:
      significant risk (Corridor_1) · TAS Systems route, 1 dwelling cooled"; Flat 2 FAIL (Bedroom 2_3, Kitchen_4),
      Flat 3 FAIL (Kitchen_7) - the PR3C result. Open final TM59 result… → TM59 window FAIL, 5 spaces · 2 pass · 3 fail,
      corridor significant risk. Ribbon Save → 121,383 bytes (as PR3C). PASS.
    - SAM_UI env-gated `PartOMixedCoolingAcceptanceInspection` on the saved model (expect cooled): **INSPECTION
      PASSED, 24 PASS** - route Systems; one cooled dwelling Flat 3, design 63/63 → 80 l/s; one TPD; TAS guidance
      read-back for 1 unit (DX cooling 1505 h, the PR3B gate figure); scenarios Flat 1 `BaseNaturalVentilation`,
      Flat 2 `BasePassive`, Flat 3 `ActiveTrimCooling`, corridor `DwellingIndependent`; no unit supply setpoint.
  - Files: `C:\TasOut\parto-pr4-deploy-2026-09-28\` (local only: `drive.log`, `inspect-cooled.txt`, `shots\`,
    installer, H12 report). The installed product is left in `%APPDATA%\SAM`; the dev build is in the backup folder.

## 4. Open items / next step

- The PR4 large-project finding (TAS TSD per-zone read scaling; the ~5,000-space full-year run is not practical on
  current TAS) is recorded in the SAM_UI PR4 record; it does not block shipping PR3C.
- After merge: `PROJECT_PROGRESS.md` closeout on `sow/2026-Q3` (docs-only, direct), with the merge SHA.
