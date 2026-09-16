# Project Progress

## Branch
`sow/2026-Q3`

## Last updated
2026-09-17 — 2026-Q3 release closeout, candidate freeze (SAM-BIM-AI / Claude).

## Current status
2026-Q3 release candidate FROZEN, not yet released. This commit pins every
installer submodule to the exact `sow/2026-Q3` tip below and reconciles the one
master-only commit (#28). Next gates: installer build from this commit →
fresh H1–H12 on that artifact → quarter-close `sow/2026-Q3 → master` →
publish → website (`sam-bim.github.io#3`, on hold until the installer is public).

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
| SAM_OCCT | `2afaf029b4708c0a1988effcfb32fa41c60ff479` |
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
- Pending: installer build + fresh H1–H12 (see RELEASE_VALIDATION.md for the matrix;
  previous hardening-rc1/run 210 result does NOT cover this candidate).

## Issues / blockers
- H2 (clean profile), H8/H9 (Revit 2025/2026 + Rhino.Inside) need an operator and
  hardware not available on the automation VM (Revit 2027 only).

## Next step
- Build the installer from this commit (installer.yml, workflow_dispatch on
  `sow/2026-Q3`, `publish_release=false`) and run H1–H12 against that artifact.
