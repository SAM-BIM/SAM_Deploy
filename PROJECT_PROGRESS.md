# Project Progress

## Branch
`sow/2026-Q3`

## Last updated
2026-09-23 — post-acceptance submodule bump to every `sow/2026-Q3` tip (branch
`chore/bump-submodules-2026-09-23`), followed by a non-publishing test installer build.
Previously: 2026-09-17 — 2026-Q3 release candidate ACCEPTED (run 214).

## 2026-09-23 submodule bump (post-acceptance, owner-requested)

`git submodule update --remote` (each submodule follows `branch = sow/2026-Q3`). The
bump picks up the 2026-09-22/23 cleanup across the family: dead .NET Framework `app.config` files
(SAM#126 + siblings), redundant bare framework references that caused MSB3243 (SAM_UI#104,
SAM_Solver#13), the missed SAM_OpenStudio leftover (#21), stray legacy gbXML project folders
(SAM_gbXML#9), and `PROJECT_PROGRESS.md` updates. No engineering or runtime behaviour change.

| Submodule | Old pin | New pin |
|---|---|---|
| SAM | `63dd763c` | `86213eb3` |
| SAM_BHoM | `a0823b4f` | `9f0af877` |
| SAM_Excel | `92cdcad7` | `28a26b26` |
| SAM_GEM | `fbd34ba1` | `5af5d69e` |
| SAM_IFC | `d9fa8593` | `50c128d8` |
| SAM_LadybugTools | `d52d7b0c` | `17775e3a` |
| SAM_Multitasker | `e8d09c14` | `55337969` |
| SAM_OpenStudio | `269359eb` | `6972b3e7` |
| SAM_Revit | `1f0a0324` | `c82287af` |
| SAM_SolarCalculator | `3a36b73c` | `9b833996` |
| SAM_Solver | `3c6f5d53` | `de79a826` |
| SAM_Systems | `05ca0c18` | `0e891145` |
| SAM_Tas_Grasshopper | `01508b8e` | `a4d4f731` |
| SAM_UI | `9f515c4c` | `5606a82d` |
| SAM_gbXML | `3b96001f` | `26111c9b` |

Unchanged (already at tip): SAM_Tas, SAM_SQLite, SAM_Psychrometrics, SAM_Windows, SAM_Rhino_UI,
SAM_Revit_UI, SAM_Mollier, SAM_OCCT, SAM_Validation.

**Status of run 214.** This bump moves `sow/2026-Q3` off the exact submodule set that run 214 was
accepted on. Run 214 stays the formally **accepted** 2026-Q3 candidate (record below). The test installer
built after this bump (`gh workflow run installer.yml --ref sow/2026-Q3`, `publish_release=false`) is a
build-health check, **not** a new accepted candidate. Re-running the release matrix on it is a separate owner decision.

**Test installer result - run 215: SUCCESS.** [installer.yml run 215](https://github.com/SAM-BIM/SAM_Deploy/actions/runs/35823794153), dispatched on `sow/2026-Q3` at SAM_Deploy `039def99` (merge of #44), `publish_release=false` (release job skipped, no tag, no GitHub Release). SAMVersion `2026.3.215.0` (from branch `sow/2026-Q3`); 15 min. Produced `SAM_Install_v20260923.215.exe`, artifact `SAM_Install` (233 MB, zip SHA-256 `6c783450c92b7b6779002576d69f29b5e811fc3b0121dbe17ffd75c954de2c77`, expires 2026-12-22). H12 payload audit (enforce mode): **no violations**. Not installed or smoke-tested on a workstation; not an accepted release candidate.

**Local-clone note.** Before the bump, the local `SAM_Deploy` clone showed 24 submodules "modified". Their
working trees were clean but detached at assorted older/unrelated commits (e.g. SAM at `173ababc`), not at
their pins. That was local state only and nothing committed; `git submodule update --remote` resolved it.

## Current status (as of 2026-09-17; see the 2026-09-23 bump above)
2026-Q3 release candidate **ACCEPTED**. Installer `SAM_Install_v20260917.214.exe`
(installer.yml [run 214](https://github.com/SAM-BIM/SAM_Deploy/actions/runs/35194487176),
SAM_Deploy `cbd05b655076b859c709052d006b6edbb88dd113`, SAMVersion `2026.3.214.0`,
SHA-256 `EFB0BDAB28FDDD9915ED9845EAA4CAD271F2DA4774BF8BB7A5942EE16EF091DB`) has
the formal matrix only partially re-evidenced: **formal PASS** on H1, H2, H9,
H12; **formal PARTIAL** on H11 (uninstall PASS, upgrade-over-previous-version
not exercised); H3/H4 and H5–H7 **not separately recorded / not exercised**
this closeout (owner ran Part O + Rhino/Grasshopper smoke acceptance, not the
version-split Rhino gates or a TAS workflow); H8 and the dedicated H10
runtime-path test are **OWNER-SKIPPED** (waived), not PASS; plus a full
**additional owner smoke-test PASS** on every non-matrix item exercised
(SAM_UI, Part O ×2, Rhino `.rhp`, Grasshopper+SAM, Grasshopper+OCCT with no
OCCT SDK installed, Revit add-in, Revit 2026/2027+RiR, SAM_UI from host,
uninstall). Do not read this as "H1–H12 all PASS". Full table:
`RELEASE_VALIDATION.md` → "Results — 2026-Q3 release candidate (run 214, FINAL
ACCEPTED)". This supersedes the run-213 draft record that was carried only in
the never-merged PR #41 (run 213 itself is retired — see H12 provenance
follow-up below, which is what produced run 214).
Nothing in this closeout rebuilds the installer, dispatches a new workflow run,
publishes a GitHub Release, tags a commit, or promotes `sow/2026-Q3` to master
— quarter-close promotion (per-repo `sow/2026-Q3 → master` PRs, then publish,
then `sam-bim.github.io#3`) remains a separate, not-yet-started next step.

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
  native (`SAM.Occt.Native.dll`), or third-party. Enforces
  `FileVersion == SAMVersion` / `ProductVersion == InformationalVersion` on
  the first two classes only; reports third-party metadata without comparing
  it to `SAMVersion`; enforces OpenCASCADE's `TK*.dll` runtime against the
  pinned OCCT SDK version; flags any test-only binary found in the payload as
  a hard violation; **fails if any of the 9 approved SAM_OCCT release
  binaries is absent from the payload**, regardless of what else is present.
  `-Enforce` exits 1 on a real violation; without it, the script only reports.
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

### v2 fixes (2026-09-17, same day, same branch) — independent review found 4 gaps

An independent review of the first version of this PR found 4 correctness gaps
in the audit script (not in the SAM_OCCT fix itself). All 4 fixed in place,
plus one bug found while testing fix #1:

1. **Required-presence gate (most important).** The original script only
   checked files it found — an absent file (failed native build, or the known
   `SAM.Core.Grasshopper.OCCT` `OutputPath` quirk combined with that project's
   live-deployment copy being `IgnoreExitCode="true"`, i.e. best-effort) would
   never be scanned and so could never fail. Inspected the real staging
   pipeline rather than guessing: each SAM_OCCT Grasshopper project's own
   PostBuild target ("Local packaging: must succeed") copies its
   `$(TargetPath)` to a sibling `.gha`, and `installer.yml`'s own
   "Root Grasshopper DLLs -> GHA" step independently ensures the same for
   anything matching `^SAM\..*Grasshopper.*\.dll$` at the payload root — so
   both `.dll` and `.gha` are genuinely expected for the 3 Grasshopper OCCT
   projects. Added an explicit 12-name required list (5 single-file + 3
   dll/gha pairs + the native DLL) checked for presence after the scan,
   independent of whether anything was actually found.
2. **OCCT toolkit classification.** The old case-sensitive `^TK[A-Z]` match
   missed `TKernel.dll` (OCCT's own historical naming: lowercase after `TK`).
   Replaced the regex entirely: the toolkit set and its expected version are
   now resolved from the real OCCT SDK at `C:\OCCT` (same path
   `installer.yml`'s own native-engine step uses) — every `TK*.dll` actually
   present next to `TKernel.dll` there is the toolkit allowlist, and
   `TKernel.dll`'s own embedded `FileVersion` is the expected version. A
   static 74-name fallback list (enumerated from the same SDK) covers a local
   dry run without the SDK downloaded.
3. **SAM-owned classification vs. H12 wording.** H12 says "produced by a
   non-test project in a pinned submodule", not "filename starts with
   `SAM.`". The ownership map is now built by reading each pinned repo's own
   non-test `*.csproj` files' `<AssemblyName>` (falling back to the csproj's
   base name), registering a `.gha` sibling for anything under a
   `Grasshopper\` folder and a `<TargetExt>` sibling (e.g. `.rhp`) when a
   project overrides it — the project's own declared output identity, not a
   naming guess. A payload file matching the `SAM.*` convention is still
   always treated as SAM-owned even if the map missed it (fail-safe net,
   flagged `UNATTRIBUTED`). Confirmed against a real, previously-undetected
   case: `SAM_Tas/benchmark/SAM.Analytical.Tas.Benchmark.Cli` sets
   `<AssemblyName>benchmark-tas</AssemblyName>` — its output `benchmark-tas.dll`
   does not match `^SAM\.` at all, and is now correctly classified SAM-owned
   managed (owner: `SAM_Tas`) instead of silently falling to third-party.
   Side benefit: because ownership is now per-project rather than "any repo
   whose build folder happens to contain a copy", the previous known
   limitation (widely-shared files like `SAM.Core.dll` listing 22 "owner"
   repos) is resolved — `SAM.Core.dll` now attributes to exactly `SAM`.
4. **OCCT SDK version drift.** The script no longer hard-codes `8.0.0`
   independently of `installer.yml`'s own `OCCT_SDK_TAG` resolution. It reads
   `TKernel.dll`'s own embedded `FileVersion` from `-OcctSdkRoot` (default
   `C:\OCCT`, the same path `installer.yml` downloads/caches the SDK to) — the
   literal same physical files the native build links against. `-OcctSdkVersion`
   (default `8.0.0`) is now only a fallback for when that path has no SDK to
   read (e.g. an offline dry run).
5. **Bug found while testing fix #1** (not one of the 4 requested, found
   while writing the negative test for it): `$violations = $rows |
   Where-Object {...}` — in Windows PowerShell 5.1, a `Where-Object` match of
   **exactly one** item unwraps to a bare object instead of a one-element
   array, so `.Count` silently returns `$null`, and `$null -gt 0` is `$false`
   — a single real violation (e.g. exactly one missing required binary) would
   have passed enforcement silently. First reproduced live: removing only
   `SAM.Occt.Native.dll` from an otherwise-clean payload reported "No H12
   violations found" / exit 0 despite the violation correctly appearing in the
   written report. Fixed by forcing array semantics: `$violations = @($rows |
   Where-Object {...})`. Applied the same defensive fix to `$submoduleNames`.

### Validation performed (before opening the PR, and re-run for v2)

Assembled a complete synthetic payload from real local build output: all 12
required SAM_OCCT binaries (`SAMVersion=2026.3.214.0`, per SAM_OCCT PR #70's
own validation, including real `.gha` copies this time), 3 real `TK*.dll`
(`TKernel.dll`, `TKBRep.dll`, `TKMath.dll`) + `tk86.dll` + `freetype.dll` from
the real local OCCT SDK / build output.

- **(e) clean payload passes**: `-Enforce` → exit 0, zero violations. 11
  SAM-owned managed / 1 SAM-owned native / 3 third-party (OCCT SDK) / 2
  third-party.
- **(b) TKernel 8.0.0 passes**: report shows
  `TKernel.dll | 8.0.0 | 8.0.0 | 8.0.0 | OK` (and `TKBRep.dll`, `TKMath.dll`
  likewise) — OCCT SDK identity resolved as `version=8.0.0 (resolved from
  C:\OCCT\...\win64\vc14\bin (74 TK*.dll, TKernel.dll FileVersion))`.
- **(c) wrong TKernel version fails**: forced the fallback path
  (`-OcctSdkRoot` pointed at a nonexistent folder, `-OcctSdkVersion 9.9.9`)
  against the same real `TKernel.dll` (embedded `8.0.0`) → exit 1,
  `TKernel.dll`/`TKBRep.dll`/`TKMath.dll` all `MISMATCH`, expected `9.9.9`.
- **(d) tk86 stays generic third-party**: `tk86.dll | 8.6.15 | ... |
  <not enforced - third-party> | REPORTED` — never compared to the OCCT SDK
  version.
- **(a) removing a required binary fails H12**: tested twice — removing
  `SAM.Occt.Native.dll` alone (exit 1, `MISSING_REQUIRED_BINARY`, and the
  exact case that first caught the PowerShell array-unwrapping bug above), and
  separately removing only `SAM.Core.Grasshopper.OCCT.gha` (the real-world
  OutputPath-quirk scenario) — exit 1, `MISSING_REQUIRED_BINARY`, class
  `SAM-owned managed`, owner `SAM_OCCT`.
- Regression: re-ran the original synthetic payload (unstamped `SAM.Core.dll`,
  a planted `SAM.OCCT.UnitTests.dll`) — both still correctly flagged
  (`MISMATCH`, `TEST_BINARY_IN_PAYLOAD`), plus now also correctly flags the 3
  missing `.gha` files that payload never had (required-presence gate working
  as intended, catching a gap the first version's own dry run had missed).

No new SAM-owned provenance violation outside the 9 already approved (the 8
SAM_OCCT managed assemblies + `SAM.Occt.Native.dll`) was found in this local
validation. **A full real installer.yml run has NOT been executed yet** — that
happens after this branch merges, per the approved plan (section 20).

**PR #42 has NOT been merged** — holding for explicit human review per
instruction.

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
- installer.yml run 214 on `cbd05b6`: H1 PASS, H12 PASS (full-payload provenance
  audit, PR #42, ran clean).
- Owner manual acceptance (2026-09-17) against `SAM_Install_v20260917.214.exe`:
  PASS on every item the owner's own checklist exercised (clean install,
  SAM_UI, Part O x2, Rhino `.rhp`, Grasshopper+SAM, Grasshopper+OCCT with no
  OCCT SDK installed, Revit add-in, Revit 2026/2027+RiR, SAM_UI from host,
  uninstall). That checklist does not 1:1 map onto the formal H1–H12 matrix:
  H9 formally PASS; H11 formally PARTIAL (uninstall PASS, upgrade-over-previous
  not exercised); H3/H4 and H5–H7 formally not separately recorded/not
  exercised (owner smoke acceptance is not a substitute for the version-split
  Rhino gates or a TAS workflow). H8 (Revit 2025) and the dedicated H10
  (`ToSAM_AnalyticalModel`/`TogbXML`) runtime-path test are OWNER-SKIPPED
  (waived), not PASS. Full detail and per-gate evidence in
  `RELEASE_VALIDATION.md` → "Results — 2026-Q3 release candidate (run 214,
  FINAL ACCEPTED)".

## Issues / blockers
- H8 (Revit 2025) and the dedicated H10 runtime-path test remain
  OWNER-SKIPPED for Q3 — no Revit 2025 environment was available and the
  owner waived the dedicated H10 acceptance for this closeout.
- H5–H7 (TAS-specific Grasshopper assembly/UserObject/workflow tests) were not
  separately re-exercised against run 214; the owner's acceptance pass used
  Part O workflows instead. Not explicitly waived — flagged for awareness only.

## Next step
- Quarter-close promotion (per-repo `sow/2026-Q3 → master` PRs, merge commit,
  human-approved per "Protect Master v1"; then publish the run-214 bytes as
  `v20260917.214`; then `sam-bim.github.io#3`) is the natural next step but is
  **out of scope for this closeout** and was not started here.
