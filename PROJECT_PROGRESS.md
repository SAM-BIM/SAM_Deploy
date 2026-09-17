# Project Progress

## Branch
`sow/2026-Q3`

## Last updated
2026-09-17 — H12 provenance fix follow-up, branch `feat/h12-payload-audit`
(SAM-BIM-AI / Claude).

## Current status
2026-Q3 release candidate FROZEN at `2ce3d87` (run 213), superseded by this
work (see "H12 provenance follow-up" below — not yet merged). Next gates after
this branch merges: rebuild the installer from the new `sow/2026-Q3` tip →
fresh H1 + H12 (automated, enforced) on that artifact → owner-run H2–H11 →
quarter-close `sow/2026-Q3 → master` → publish → website
(`sam-bim.github.io#3`, on hold until the installer is public).

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
  native (`SAM.Occt.Native.dll`), or third-party (built from an ownership map
  walked across all 24 pinned submodules' own build output, keyed by the
  `SAM.*` naming convention). Enforces `FileVersion == SAMVersion` /
  `ProductVersion == InformationalVersion` on the first two classes only;
  reports third-party metadata without comparing it to `SAMVersion`; enforces
  OpenCASCADE's `TK*.dll` runtime against the pinned OCCT SDK version
  (`8.0.0`) via a case-sensitive `TK[A-Z]` match (excludes unrelated
  case-insensitive collisions like Tcl/Tk's own `tk86.dll`); flags any
  test-only binary found in the payload as a hard violation. `-Enforce` exits
  1 on a real violation; without it, the script only reports (used for the
  dry run below and for local investigation).
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

### Validation performed (before opening the PR)

Ran `audit-payload-versions.ps1` locally (report mode, then `-Enforce`)
against a synthetic payload assembled from real local build output: the 8
SAM_OCCT assemblies + `SAM.Occt.Native.dll` built with
`SAMVersion=2026.3.214.0` (per SAM_OCCT PR #70's own validation), 5 real
`TK*.dll`, `freetype.dll`, plus two deliberately-wrong files to prove the
negative path (an unstamped `SAM.Core.dll` at `1.0.0.0`, and
`SAM.OCCT.UnitTests.dll` to test the test-binary guard):

- Report mode: correctly classified 8 SAM-owned managed / 1 SAM-owned native /
  5 third-party (OCCT SDK) / 2 third-party; correctly flagged both planted
  defects (`SAM.Core.dll` MISMATCH, `SAM.OCCT.UnitTests.dll`
  TEST_BINARY_IN_PAYLOAD); exit 0 (report-only never fails the build).
  `tk86.dll` (a Tcl/Tk DLL that name-collides with the `TK*.dll` glob
  case-insensitively) correctly fell into generic third-party, not the OCCT
  SDK bucket — this only works because of the case-sensitive `TK[A-Z]` match;
  a naive case-insensitive `^TK.*\.dll$` would have wrongly flagged it as an
  OCCT-SDK-version mismatch.
- `-Enforce` against the same payload: exit 1, both violations reported.
- `-Enforce` against the same payload with the two planted-defect files
  removed (i.e. a genuinely clean payload): exit 0, zero violations.

No new SAM-owned provenance violation outside the 9 already approved (the 8
SAM_OCCT managed assemblies + `SAM.Occt.Native.dll`) was found in this local
validation. **A full real installer.yml run has NOT been executed yet** — that
happens after this branch merges, per the approved plan (section 20).

### Known limitation (not a defect, documented here so it isn't rediscovered)

The ownership map attributes a `SAM.*` filename to *every* pinned repo whose
own build output happens to contain a copy of it, not just the repo that
actually produces it as a `ProjectReference` output. Widely-referenced shared
assemblies (e.g. `SAM.Core.dll`) therefore list many "owner" repos in the
audit report/CSV — this is because most repos carry a HintPath-copied local
build of their dependencies, not because ownership is ambiguous. It does not
affect classification (SAM-owned vs third-party) or the FileVersion/
ProductVersion enforcement, only the diagnostic `OwnerRepo` column's precision.

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
- Pending: installer build + fresh H1–H12 (see RELEASE_VALIDATION.md for the matrix;
  previous hardening-rc1/run 210 result does NOT cover this candidate).

## Issues / blockers
- H2 (clean profile), H8/H9 (Revit 2025/2026 + Rhino.Inside) need an operator and
  hardware not available on the automation VM (Revit 2027 only).

## Next step
- Build the installer from this commit (installer.yml, workflow_dispatch on
  `sow/2026-Q3`, `publish_release=false`) and run H1–H12 against that artifact.
