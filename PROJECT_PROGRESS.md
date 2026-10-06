# Project Progress

## Branch
`sow/2026-Q3`

## Last updated
2026-10-06 (closeout) — **Final 2026-Q3 SAM-BIM master baseline captured in SAM_Deploy.** SAM_Deploy#61 merged as `37933daf` (PR head `c369ebd`); `sow/2026-Q3` now pins **all 24 submodules**
to their final SAM-BIM `master` commits (e.g. SAM_Solver `d5e59f52`, SAM_Tas_Grasshopper `b4fce7c8`; full table in the section below). `.gitmodules` unchanged. **Next step: create and verify the new installer**
from the final `sow/2026-Q3` closeout SHA. Q4 has not started; no installer, tag or release has been created for this baseline.
Previously: 2026-10-01 (closeout) — **Part O final deploy COMPLETE.** SAM_Deploy#59 merged as `a61875a`; `sow/2026-Q3` pins SAM `c3890d5c`, SAM_Systems `09063b4c`, SAM_Tas `057faf37`,
SAM_UI `bdcc2a54` (SAM_Tas_Grasshopper unchanged at `9ddf8ff`). Ships PR-4 .. PR-6 (SAM_UI#150-#156, SAM#170-#174). See the section below.
Previously: 2026-09-28 (closeout) — **Mixed Part O PR4 deploy COMPLETE.** SAM_Deploy#58 merged as `c74122b3`; `sow/2026-Q3` pins
SAM_UI `0c7b5ec5` (ships PR3C per-dwelling cooling, SAM_UI#134; + #135, #136, #137), SAM_Tas_Grasshopper `9ddf8ff`
(#7), SAM `bc85ba61`, SAM_Systems `fbef48f`, SAM_Tas `5753ad2`. See the section below.
Previously: 2026-09-28 (closeout) — **PR2F-3 COMPLETE.** SAM_Deploy#57 merged as `3d531508`; `sow/2026-Q3` pins SAM `3d6fa80a`,
SAM_Tas `e7cc0ed4`, SAM_Systems `005c4fe1`, SAM_UI `8971cfb0` (SAM_UI#133 batch export). See the section below.
**Convention from now on (owner, 28 Sep):** code + tests + evidence → final PR CI → merge → update
`PROJECT_PROGRESS.md` afterwards as a direct docs-only closeout commit on the base branch (not on the PR branch).
Previously: 2026-09-28 — **PR2F-3: ship batch Space report export (SAM_UI#133).** SAM `6c255ad8` -> `3d6fa80a`, SAM_Tas
`fedf34cd` -> `e7cc0ed4`, SAM_Systems `22133736` -> `005c4fe1`, SAM_UI `cbe1c076` -> `8971cfb0`. Pointer-only, no
workflow or gate change. Installer run 219 built, installed and accepted on the installed product (A-I PASS). Branch
`chore/deploy-space-report-batch-2026-09-28`, SAM_Deploy#57; see the section below.
Previously: 2026-09-27 (closeout) — **SAM Documentation Framework Phase 2: COMPLETE.** SAM_Deploy#55 merged as `1506da5f`;
`sow/2026-Q3` pins SAM `6c255ad8` (SAM#159), SAM_Tas `fedf34cd`, SAM_UI `cbe1c076` (SAM_UI#127). See the section below.
Previously: 2026-09-27 — **PR2E: ship the Space Design Load Summary PDF (reporting Phase 2).** SAM `00db4b85` -> `6c255ad8`,
SAM_Tas `b32c0808` -> `fedf34cd`, SAM_UI `4b773f3e` -> `cbe1c076`; SAM_Systems unchanged. Pointer-only, no workflow or
gate change. Installer run 218 built, installed and accepted on the installed product (A/A2/B/C/D PASS). Branch
`chore/deploy-space-design-load-summary-2026-09-27`, SAM_Deploy#55; see the section below.
Previously: 2026-09-26 — **B0 Phase-1 correctness deployment:** SAM `22f9c743` -> `00db4b85`, the merge of SAM#147 (PR2A-0,
issue SAM#146). This fixes the stale Design Heating/Cooling Load read from duplicate `SAM.Analytical` ParameterSets, which
made the shipped Space Assumptions PDF print e.g. 0 W instead of 1139.87 W. The move is a fast-forward and also brings
docs-only SAM#144/#145. No other gitlink moves. Branch `chore/bump-sam-b0-stale-design-load-2026-09-26`; see the section
below.
Previously: 2026-09-26 (Part O pass 6) — pointer bump SAM_UI `7e7de033` -> `4b773f3e`, the merged Part O UX Pass 6 (SAM_UI#122: final
consistency fixes and end-to-end acceptance - presentation only; Part O UX ready for closeout/freeze). A fast-forward;
SAM (`22f9c743`) and SAM_Tas (`b32c0808`) are already what it builds against, and no other gitlink moves. Branch
`chore/bump-sam-ui-parto-pass6-2026-09-26`.
Previously: 2026-09-26 (closeout) — **SAM Documentation Framework Phase 1: COMPLETE.** SAM_Deploy#51 merged as `8e6740af`:
- `sow/2026-Q3` pins SAM `22f9c743` and SAM_UI `7e7de033`;
- installer and payload validation passed;
- the installed-product smoke test passed.

The deployment gate is complete. See the section below.
Previously: 2026-09-26 (latest) — ship the Space Assumptions PDF (reporting Phase 1): SAM `78a57466` -> `22f9c743`,
SAM_UI `5a0b9bf6` -> `7e7de033`, plus a new installer gate for the reporting/PDF payload. Branch
`chore/deploy-space-assumptions-pdf-2026-09-26`.
Previously: 2026-09-26 (later) — pointer bump for the Part O 2B per-round `.sam` growth fix: SAM `7dbeb2e4` -> `78a57466`
(SAM#142, deep clone no longer doubles Guid-less cluster objects; also brings the reporting PRs #136/#139/#140, which
sit below it on `sow/2026-Q3` and which SAM_UI CI already builds against), SAM_Tas `39828c6` -> `b32c0808` (SAM_Tas#67,
design days and zone results replaced per run instead of appended), SAM_UI `3b29e41f` -> `5a0b9bf6` (SAM_UI#118 Pass 5
2B journey + #119 growth regression/evidence). All three fast-forwards to their merged tips; no other gitlink moves.
No engineering change beyond removing accumulated stale records (live TAS: 12/12 TM59 reports identical, `.sam` flat).
Branch `chore/bump-parto-sam-growth-2026-09-26`.
Previously: 2026-09-26 — pointer bump SAM_UI `90b42e0e` -> `3b29e41f` (SAM_UI#113-#117: Part O Review iteration, TM59 result
window, Hub outcome line, reopened-run naming, shared progress window - all presentation/orchestration) and SAM
`80b01052` -> `7dbeb2e4`, the SAM#137 merge that SAM_UI#114 consumes (per-space TM59 status). Both fast-forwards.
SAM is deliberately NOT moved to its tip: the later reporting PRs (#136/#139/#140) are not needed by SAM_UI and
are left for a separate bump. Branch `chore/bump-sam-ui-parto-pass4-2026-09-26`; no other gitlink moves.
Previously: 2026-09-25 (later) — SAM_UI pointer bump `6230d7d1` -> `90b42e0e`, the merged Part O Prepare & Run Hub
presentation pass SAM_UI#111 (branch `chore/bump-sam-ui-hub-presentation-2026-09-25`). A fast-forward; the pass is
presentation-only in SAM_UI, with no engineering change. SAM, SAM_Systems and SAM_Tas are already at their
`sow/2026-Q3` tips (PR #47), and no other gitlink moves.
2026-09-25 — pointer bump of SAM, SAM_Systems, SAM_Tas and SAM_UI to the merged Nuaire-reply and Part O
workflow-simplification commits (branch `chore/bump-parto-workflow-merged-pointers`, PR #47).
2026-09-24 — minimal pointer bump to the merged Nuaire / Part O manufacturer-guidance commits
(branch `chore/bump-parto-nuaire-merged-pointers`, PR #46).
2026-09-23 — post-acceptance submodule bump to every `sow/2026-Q3` tip (branch
`chore/bump-submodules-2026-09-23`), followed by a non-publishing test installer build.
2026-09-17 — 2026-Q3 release candidate ACCEPTED (run 214).

## 2026-10-06 Final Q3 SAM-BIM master baseline deployment - MERGED as SAM_Deploy#61 (`37933daf`)

**Current status.** The final 2026-Q3 SAM-BIM repository baseline has been synchronised into SAM_Deploy. [SAM_Deploy#61](https://github.com/SAM-BIM/SAM_Deploy/pull/61) merged into `sow/2026-Q3` as `37933dafaee7e4952da5795511132a0e23093c48` (normal merge commit; PR head `c369ebd921ec92523aeb0fe667644e1857c5810e`; parents `e0a451bf` and `c369ebd`). `sow/2026-Q3` pins all 24 submodules to the final SAM-BIM `master` commit of each repository. Installer creation is the next step. Q4 has not started.

**Work completed.** 24 gitlinks were moved from the preserved `sow/2026-Q3` branch-tip pins to the verified final SAM-BIM `master` SHAs (each checked against the live remote when the PR was made and again immediately before and after the merge):

| Submodule | Old (`sow/2026-Q3` pin) | New (final SAM-BIM `master`) |
|---|---|---|
| SAM | `c3890d5c` | `56a7059269e2aa77bec87415430957f3421a36c4` |
| SAM_BHoM | `9f0af877` | `c734297b831866a6af2968ef8bd4a4fb93005a6a` |
| SAM_Excel | `28a26b26` | `befb1acdc84358520de98b5be014efa81f208bb9` |
| SAM_gbXML | `26111c9b` | `4228e6ef828c870f4794d85c3c5f782e5c1fddb5` |
| SAM_GEM | `5af5d69e` | `96719c9943a0a3520ea64f0348010fff3dd9c7a9` |
| SAM_IFC | `50c128d8` | `14ae71abfb9cdf0031ec5cc754fae0582ce3b999` |
| SAM_LadybugTools | `17775e3a` | `abf0d215f6d0b999ff935f39ce831af6e05f96f6` |
| SAM_Mollier | `5c336cdc` | `fc73fd6902528145405c9d920e98eb9bfcdbffda` |
| SAM_Multitasker | `55337969` | `45f6854dcefd832b5c9828522056313c7ed454a7` |
| SAM_OCCT | `e9b453bd` | `25801568f687537c47c91abe6ac3961415c8226a` |
| SAM_OpenStudio | `6972b3e7` | `5522dd80613aec4c72f785751475d5697d3a075f` |
| SAM_Psychrometrics | `5addfa77` | `e8b204989bde8351516b1c1b449a99100203cd64` |
| SAM_Revit | `c82287af` | `192efab49cf34aeffec0aa5d4ec3900d66685044` |
| SAM_Revit_UI | `05fa2e7f` | `64d6d9fc74cd5d4508c666fbca2b60f66427bbdb` |
| SAM_Rhino_UI | `296875ef` | `6e4f0643884d92d2e50155b75ead637aad9f4c71` |
| SAM_SolarCalculator | `9b833996` | `9f50c91f14fa1c116358baad59233ebf2dc1244d` |
| SAM_Solver | `de79a826` | `d5e59f52f26e0b258ad0473035221d83f19d008b` |
| SAM_SQLite | `7bc76f28` | `80ab3b68234a0392cf63c8065b1037a52311b005` |
| SAM_Systems | `09063b4c` | `d5f239e4344ca6ed9234dd72f6bb1d903fe11bb5` |
| SAM_Tas | `057faf37` | `28ac11a786a80639509963e2fc1d31b131e33c50` |
| SAM_Tas_Grasshopper | `9ddf8ff6` | `b4fce7c878b27407fff53b1d83ee31c4d6af2c90` |
| SAM_UI | `bdcc2a54` | `ab08013458b29e2768ec93fbce4513f8844f97a1` |
| SAM_Validation | `002ff0ee` | `662d72553b27bbb361ba7f9af22f67ac3860ce19` |
| SAM_Windows | `b5bb64e4` | `b6e251d90202e50338d510c8ab994a486dc9d65a` |

- `SAM_Solver`: old `de79a826` -> new `d5e59f52f26e0b258ad0473035221d83f19d008b`.
- `SAM_Tas_Grasshopper`: old `9ddf8ff6` -> new `b4fce7c878b27407fff53b1d83ee31c4d6af2c90`.

**Decisions and assumptions.**
- `.gitmodules` keeps `branch = sow/2026-Q3` for every submodule, deliberately. The reproducible deploy baseline is defined by the recorded gitlink SHAs, not by that setting.
- `git submodule update --remote` must not be used to recreate this exact final baseline (see risks).
- `SAM_Topologic` is not part of the final Q3 deploy set (it is not a submodule on `sow/2026-Q3`).
- `SAM_Deploy:master` remains the older Q2 baseline and was intentionally not changed.
- A suggestion to rewrite the `.gitmodules` branch tracking as part of this repin was considered and deliberately not adopted for this closeout.

**Files changed.** PR #61 changed 24 gitlinks only (no other file; `.gitmodules` was not changed). This closeout commit changes only `PROJECT_PROGRESS.md`.

**Validation.**
- PR #61 `Validate PR` (`build`: Release restore + rebuild of `BuildAll_Release.csproj`, non-publishing) passed before the merge; merge SHA `37933daf`.
- All 24 recorded gitlinks on the merged tip equal the verified final SAM-BIM `master` SHAs and are identical to the PR head. All 24 submodule URLs remain under `https://github.com/SAM-BIM/`. No submodule was dirty.
- 23 of 24 `master` trees matched the preserved Q3 product trees, excluding `AGENTS.md` and `PROJECT_PROGRESS.md`. The only additional `SAM_Tas_Grasshopper` difference was the intentional one-line `.github/workflows/cleanup.yml` change.
- No HoareLea lineage or `SAM_Solver_Upstream` dependency is present. No `sow/2026-Q4` branch exists in SAM_Deploy or any submodule repository.
- No installer was built, and no tag or release was created, for this baseline.

**Unresolved items / risks.** These are known repository-state facts, not blockers for creating the Q3 installer from the exact pinned branch SHA.
- `git submodule update --remote` on this Q3 branch follows `sow/2026-Q3` and could move the checked-out submodules away from the final `master` gitlinks.
- `SAM_Deploy:master` is still the Q2 baseline.

**Next step.** Create and verify the new installer from the final `SAM_Deploy:sow/2026-Q3` closeout SHA.

## 2026-10-01 Part O final deployment (PR-4 .. PR-6, SAM#174) - MERGED as SAM_Deploy#59 (`a61875a`)

**Status.** [SAM_Deploy#59](https://github.com/SAM-BIM/SAM_Deploy/pull/59) merged into `sow/2026-Q3` (PR head `7244406`, merge `a61875a`). Pointer-only: SAM `bc85ba61` -> `c3890d5c`, SAM_Systems `fbef48ff` -> `09063b4c`,
SAM_Tas `5753ad2e` -> `057faf37`, SAM_UI `0c7b5ec5` -> `bdcc2a54` (PR-6 SAM_UI#156 merge `84e7ad9`, closeout `bdcc2a5`). All fast-forwards to the merged tips; no workflow, project or assembly change.
Record: `DEPLOY_PARTO_FINAL.md`.

**Validation.**
- Validate PR green (`585d380` and the docs-only head `7244406`).
- Installer run 221 (`585d380`, dispatch, `publish_release=false`): success, nothing published, `SAM_Install_v20261001.221.exe` (250,089,982 bytes), stamp `2026.4.221.0` (a `chore/*` branch takes the UTC quarter).
- Installer run [36827807872](https://github.com/SAM-BIM/SAM_Deploy/actions/runs/36827807872) #222 on the merged `sow/2026-Q3` (`a61875a`): `build` success, `release` skipped, nothing published,
  `SAM_Install_v20261001.222.exe` (artifact `SAM_Install`, 250,095,857 bytes), `2026.3.222.0+a61875a`, reporting/PDF payload gate passed, `h12-audit-report` uploaded.
- Release regression gate, merged tips, Release: `SAM.Tests` 2792/2792; `SAM.Analytical.Systems.Tests` 303/303; `Systems.Mollier.Tests` 123/123; `Tas.TM59.Tests` 1023/1023; `SAM.Analytical.UI.WPF.Tests` 1590/1590.
- Real model (read-only, no TAS): real `SAM Analytical.exe` from the merged SAM_UI tip on a hash-verified copy of the cleaned model, Check design: "SAM can build this mixed design"; Systems in this assessment
  2 included (MVHR Flat 2, MVHR Flat 3) / 3 retained (MV 1 naming AHU1, NV 1, UV 1); no SharedSystem or missing-AHU refusal; source hash unchanged.

**Not done.** The installed-product smoke (as in #58) and any licensed TAS run were not repeated; SAM_UI#154 remains the last licensed Mixed acceptance (PASS). Nothing was published to a GitHub Release.

**Risks / separate follow-ups.** Intermittent TPD `Loading TSD data` (`AddTSDData`) stall (SAM_UI#154); general sidecar absolute-path audit; Save As portability of `.partomixed.json`; Prepare & Run / Iteration 3 do not show the PR-6 section.

**Next step.** None for Part O. A release publish, if wanted, is a separate dispatch of `installer.yml` from `sow/2026-Q3` with `publish_release=true`.

## 2026-09-28 Mixed Part O PR4 deployment (ships PR3C) - MERGED as SAM_Deploy#58 (`c74122b3`)

```text
Mixed Dwelling Strategies - PR4 (large-project acceptance + deploy)
Status: deploy COMPLETE (SAM_Deploy#58 merged as c74122b3); large-project evidence MERGED (SAM_UI#137 d6f098d2)
```

- **Why.** `sow/2026-Q3` pinned SAM / SAM_Systems / SAM_Tas at the PR3C build SHAs but SAM_UI at `8971cfb0`, before PR3C
  (SAM_UI#134 `453ca94`): the shipped app had no per-dwelling active cooling in Mixed Design.
- **Pins** (all fast-forwards to the merged tips; no new project or assembly, payload gate unchanged):

| Submodule | Old pin | New pin | Includes |
|---|---|---|---|
| SAM_UI | `8971cfb0` | `0c7b5ec5` | **SAM_UI#134** PR3C cooling + closeout; #135 progress-dialog pattern; #136 reporting hardening M1/M2; **#137** PR4 tests/evidence (merge `d6f098d2`) + closeout |
| SAM_Tas_Grasshopper | `a4d4f73` | `9ddf8ff` | #7 mixed-building Part O diagnostic log name |
| SAM / SAM_Systems / SAM_Tas | `3d6fa80a` / `005c4fe1` / `e7cc0ed4` | `bc85ba61` / `fbef48f` / `5753ad2` | docs only (AGENTS.md) |

- **Gate evidence.** Installer run [36459447134](https://github.com/SAM-BIM/SAM_Deploy/actions/runs/36459447134) on
  `87d3560` (`publish_release=false`, nothing published): `SAM_Install_v20260928.220.exe`, 250,292,675 bytes, SHA-256
  `21f54cf1…4430`, SAMVersion `2026.3.220.0+87d3560`; payload assert and H12 pass, **H12 violations: none**. Validate
  green on `87d3560` and on the merged head `920f641` (docs-only, identical gitlinks). No review (Codex usage limit).
- **Installed-product smoke (owner's laptop, licensed TAS) PASS.** Dev build moved to `%APPDATA%\SAM.dev-backup-2026-09-28`
  (WMI-launched move); the Claude app's MSIX shadow `…\LocalCache\Roaming\SAM` moved to `SAM.shadow-2026-09-28`;
  silent install exit 0, 140 s, 1,711 files. The PR3C case through the installed `SAM Analytical.exe` (process path
  confirmed): cooling refused on the Natural dwelling; Check names Flat 3 at 80 l/s on the Systems route; Build & Run
  4.4 min → the PR3C result (FAIL, 1 pass · 2 fail, Systems route, 1 cooled); TM59 window 5 spaces · 2 pass · 3 fail;
  ribbon Save 121,383 bytes; `PartOMixedCoolingAcceptanceInspection` **INSPECTION PASSED (24 PASS)**. Record:
  `DEPLOY_PARTO_MIXED_PR4.md`. The installed product stays in `%APPDATA%\SAM`.
- **Open (not a deploy blocker).** PR4 found that a full-year run at ~5,000 spaces is not practical on current TAS
  (TSD per-zone read scaling) - SAM_UI `documentation/PartO-MixedDwellingStrategies-PR4.md`; owner decision on a
  follow-up outside this programme.
- **Next step.** None for this deployment.

## 2026-09-28 PR2F-3 batch Space report export deployment (SAM_UI#133) - MERGED as SAM_Deploy#57 (`3d531508`)

```text
SAM Documentation Framework — PR2F-3 (deploy batch Space report export)
Status: COMPLETE        deployment gate: COMPLETE (SAM_Deploy#57 merged as 3d531508)
```

Gate evidence: SAM_UI#133 merged `7161d9f8`; installer run 219 green (payload gate, H12); installed-product acceptance
A-I PASS; Validate green on the merged head `f186dba` (docs-only over the accepted `dc5c9ab`, identical gitlinks); no
review comments; base `bc76a31` current at merge.

| Submodule | Old pin | New pin | Includes |
|---|---|---|---|
| SAM_UI | `cbe1c076` | `8971cfb0` | **SAM_UI#133** PR2F-2 batch export (merge `7161d9f8`) + closeout docs; test/docs-only #129-#132 below it |
| SAM | `6c255ad8` | `3d6fa80a` | **SAM#163** PR2F-1 `DocumentContext.WithNewDiagnostics()` (`afe90e94`, needed by #133); SAM#161 Part O PR3B-1 (`85a13ec3`) sits below it; docs #160/#162/#164/#165 |
| SAM_Systems | `22133736` | `005c4fe1` | SAM_Systems#31 PR3B-2 |
| SAM_Tas | `fedf34cd` | `e7cc0ed4` | SAM_Tas#71 PR3B-3 |

**Why four pins, not two.** PR2F-1 (`afe90e94`) is above SAM#161 on SAM's first-parent history, so every SAM pin with
`WithNewDiagnostics()` also carries PR3B-1 production code. SAM_UI CI builds SAM, SAM_Systems and SAM_Tas at their sow
tips, so #133 was built and gated only against the full PR3B stack. Shipping SAM#161 without its SAM_Systems#31 /
SAM_Tas#71 partners would be a combination no CI built. All four moves are fast-forwards to the merged `sow/2026-Q3`
tips (28 Sep ~11:30). The only project-file change is a SAM_Tas *test* csproj, so there is no new payload and the
SAM_Deploy#51 gate is unchanged. No report content or SAM_UI behaviour change in this PR.

**Installer build.** installer.yml run [36403829578](https://github.com/SAM-BIM/SAM_Deploy/actions/runs/36403829578) on
`dc5c9ab` (dispatch, `publish_release=false`): success, release job skipped, nothing published.
- Artifact `SAM_Install_v20260928.219.exe`, 250,270,205 bytes, SHA-256
  `5f234575a55ad7091c8d2553292749c18924d3943533bfc3e5c3bc8f9b1cccf1`. SAMVersion `2026.3.219.0+dc5c9ab`.
- *Assert reporting/PDF payload*: passed (85 assemblies from the payload, 1 from the runtime; NotoSans Regular/Bold
  embedded; PdfSharp*/MigraDoc* 6.2.0.7443; Microsoft.Extensions.Logging.Abstractions 8.0; both licences).
- H12 (enforce): **no violations**. Drift: the same 3 unclassified warnings as runs 214/216-218.
- Validate PR: green on `dc5c9ab`.

**Installed-product acceptance (28 Sep, this VM).**
- The PR2F-2 dev build in `%APPDATA%\SAM` (1,877 files, version 1.0.0) was moved to
  `%APPDATA%\SAM.dev-backup-2026-09-28` first (WMI-launched `move`, outside the MSIX container; no shadow copy in the
  package's `LocalCache\Roaming`). Silent install (`/VERYSILENT /SUPPRESSMSGBOXES /NORESTART`, WMI-launched): 36 s,
  "Installation process succeeded", 1,711 files. The gate re-run on the installed `%APPDATA%\SAM` (Windows PowerShell;
  no pwsh on this VM): passed.
- Every case ran the installed `%APPDATA%\SAM\SAM Analytical.exe` (2026.3.219.0+dc5c9ab), confirmed by the process path.
  Fixtures: copies of `C:\TasOut\pr2d\{bridge_peaks,open_peaks}.sam` and `C:\TasOut\pr2f2\accept\bridge_x555.sam`
  (4,995 Spaces, 26 MB); source MD5s unchanged afterwards.
- **A** `bridge_peaks`, ribbon Edit › Reports › Export Space Reports, nothing selected: window opens in 0.08 s with no
  report ticked, Export disabled ("Choose at least one report."), All Spaces (9), folder `bridge_peaks Space reports`
  beside the model. Both reports: **18 PDFs in 1.1 s**, 0 `.tmp`, one log (header, 18 `Created` lines, `Completed`). PASS.
- **B/C/D** re-run into the same folder: prompt "18 of the 18 PDFs are already in the output folder. Yes/No/Cancel".
  No → 0 created / 18 skipped, no PDF touched. Yes → 18 rewritten. Cancel → nothing written, no new log, window
  stays usable. PASS.
- **E** `Bathroom_2 - Space Design Load Summary.pdf` locked (exclusive handle from another process), overwrite: 17
  created, 1 `FAILED` with `stage: Output` (`UnauthorizedAccessException`, "close the file if it is open in a PDF
  viewer"), the documents after it still created, the locked file byte-identical, 0 `.tmp`. PASS.
- **F** tree Ctrl+click Studio 1_0, Bathroom_2, Kitchen_4 › context menu: *Export Space reports...* enabled, both
  one-Space items disabled; scope defaults to Selected Spaces (3); Space Design Load Summary only → 3 PDFs (log
  `Scope: Selected Spaces`, `Spaces: 3`). PASS.
- **G** single-Space regression (Bathroom_2 only): both one-Space items enabled; each saves via its Save dialog and
  shows "... PDF saved: <path> Open it now?". Text equals the batch PDF line for line except the "Generated" time. PASS.
- **H** `open_peaks`, All Spaces (9), both reports: 18 PDFs, 0 `.tmp`. PASS.
- **I** 4,995 Spaces (`bridge_x555`): model loads in 53.5 s; window opens in 0.17 s showing All Spaces (4,995).
  - Full run, both reports: **9,990 PDFs in 1:44** (same as the dev build), 0 failed, 0 `.tmp`, 216
    collision-suffixed names (= the PR2F-2 harness). Progress live ("Space 784 / 4,995 - Space Design Load Summary").
  - Working set 2.8 GB before; rises to a **3.9-4.0 GB plateau from ~45 s** and stays flat to the end (dev: ~4.05 GB);
    3.95 GB after (not released within 90 s - GC, not growth). Samples: `5k-full-memory.txt`.
  - Cancel mid-run (Space 369): summary in **0.12 s**, "Cancelled after 758 of 9,990 documents"; log `CANCELLED`.
  - Close the window mid-run (Space 412): gone in **0.04 s**, app responsive, log `CANCELLED after 837 of 9990`.
- PDFs: all 36 from A/H are A4 with no text outside the page; sampled PDFs have 1-2 pages, Noto Sans Regular/Bold
  embedded, PDFsharp 6.2.0; page renders checked visually (Studio 1_0 2,268/802 W; Bathroom_2 1,140/104 W and a
  genuine 0 W cooling - identical to PR2E). Versus the PR2F-2 dev-build PDFs: same text apart from the version and
  "Generated" lines (the longer version string wraps "sizing ·" onto the next footer line).
- Loaded modules (A, H and the 5k run): all 25 SAM*, PdfSharp*, MigraDoc*, Microsoft.Extensions* modules from
  `%APPDATA%\SAM` at 2026.3.219.0+dc5c9ab / 6.2.0; none from elsewhere. No runtime or dependency error in any case.
- Evidence (outside git): `C:\TasOut\deploy-pr2f3-smoke-2026-09-28` (`installer-run.log`, `install.log`,
  `installed-gate.txt`, `loaded-modules*.txt`, `5k-full-memory.txt`, `log-5k-full.log`, `model\` outputs, `pdf\`
  PDFs + page PNGs, `screens\`, `scripts\` incl. `lib.ps1`/`run5k.ps1`).

**Limitations.** One VM; no upgrade-over-previous or uninstall test; no licensed Tas run (fixtures from PR2D/PR2F-2).
UI driver notes: the output-folder box is read-only (Browse only, not exercised here); an existing-files prompt must
be brought to the foreground before `BM_CLICK`, or the click is lost.

**Next step.** None for PR2F-3. Next reporting work is owner-led (remaining PR2F review items). Part O: PR3C only on the
owner's go-ahead. On this VM `%APPDATA%\SAM` now holds installed build 219; the PR2F-2 dev build is in
`%APPDATA%\SAM.dev-backup-2026-09-28` (a SAM_UI rebuild also re-copies its output there).

## 2026-09-27 PR2E Space Design Load Summary deployment (reporting Phase 2) - MERGED as SAM_Deploy#55 (`1506da5f`)

```text
SAM Documentation Framework — Phase 2 (Space Design Load Summary)
Status: COMPLETE        deployment gate: COMPLETE (SAM_Deploy#55 merged as 1506da5f)
```

Gate evidence: SAM#159 merged `6c255ad8`; SAM_UI#127 merged `cbe1c076`; PR2E merged; payload gate PASS (CI and
installed folder); installed A Bathroom_2, A2 Studio 1_0, B NotSimulated, C Space Assumptions, D UI workflow all PASS;
HOY on full-year peaks only; "Peak sensible load" headline; no installed dependency/runtime failure. Validate was green
on the merged head `c71f6047`.

**Next step.** PR2F (owner-led): review representative real-project PDFs (wording, hierarchy, sentinels, Tas
design-day names, pagination) and scope multi-Space / All-Spaces export. Not started. Out of Phase 2: SAM#138,
SAM#154, OpenStudio peaks, provenance redesign.

| Submodule | Old pin | New pin | Includes |
|---|---|---|---|
| SAM | `00db4b85` | `6c255ad8` | SAM#153 PR2A-1 peak contract, #156 PR2B data, #158 PR2C PDF, **#159** annual HOY + "Peak sensible load" (merge `6c255ad8`) |
| SAM_Tas | `b32c0808` | `fedf34cd` | SAM_Tas#69 PR2A-2 Tas typed peaks; docs #68/#70 |
| SAM_UI | `4b773f3e` | `cbe1c076` | **SAM_UI#127** PR2D Reports command (merge `cbe1c076`) |

All three are fast-forwards to the merged `sow/2026-Q3` tips as of 27 Sep 2026 ~22:00. Unrelated merged work that rides
along because it sits below those tips: SAM Part O mixed-strategy #149-#152, #157 and docs #148/#155; SAM_UI Part O
#125/#126/#128 and docs #123/#124. SAM_Systems `22133736` already is its sow tip; no other gitlink moves. Phase 2 needs
no new third-party payload, so the SAM_Deploy#51 gate (`assert-reporting-payload.ps1`) is unchanged and no check was added.

**Installer build.** installer.yml run [36345583500](https://github.com/SAM-BIM/SAM_Deploy/actions/runs/36345583500) on
`4325402` (dispatch, `publish_release=false`): success, release job skipped, nothing published.
- Artifact `SAM_Install_v20260927.218.exe`, 250,138,264 bytes, SHA-256
  `10785d4dd3ccbe85f4aaa447512ee75aa08ea178d93eb817cf888f12d708237d`. SAMVersion `2026.3.218.0+4325402`.
- *Assert reporting/PDF payload*: passed (85 assemblies from the payload, 1 from the runtime; NotoSans Regular/Bold
  embedded; every PdfSharp*/MigraDoc* 6.2.0 (6.2.0.7443); Microsoft.Extensions.Logging.Abstractions 8.0; both licences).
- H12 (enforce): **no violations**. Drift: the same 3 unclassified warnings as runs 214/216/217.
- Validate PR: green.

**Installed-product acceptance (27 Sep, this VM).**
- The dev build in `%APPDATA%\SAM` was moved to `%APPDATA%\SAM.dev-backup-2026-09-27` first (via a WMI-launched `move`,
  outside the MSIX container), so this was a clean install. Silent install (`/VERYSILENT /SUPPRESSMSGBOXES`, WMI-launched):
  exit 0, 1,713 files. The gate re-run on the installed `%APPDATA%\SAM`: passed.
- Every case ran the installed `%APPDATA%\SAM\SAM Analytical.exe` (2026.3.218.0+4325402), confirmed by the process
  path. Fixtures: copies of `C:\TasOut\pr2d\{open_peaks,bridge_peaks,nores}.sam`; the sources' MD5s were unchanged.
- **A** Bathroom_2 (`open_peaks`), tree context menu › Save › "Open it now?" Yes (opened in Chrome): 1 page A4, no
  clipping. Heating **Peak sensible load** 1,140 W design day `23:00–24:00` (no HOY) / 104 W full year
  `23 Dec 09:00–10:00 (HOY 8554)`. Cooling a genuine **0 W** with the no-demand note, status Available. PASS.
- **A2** Studio 1_0 (`bridge_peaks`): 2 pages, no clipping. Heating 2,268 W (`15:00–16:00`) / 802 W
  (`1 Jan 00:00–01:00 (HOY 1)`); cooling 1,973 W (`00:00–01:00`) / 1,972 W (`3 Jul 19:00–20:00 (HOY 4412)`).
  SENSIBLE LOAD COMPONENTS AT PEAK and LATENT COMPONENTS AT PEAK separate; "No total is derived". PASS.
- **B** Bathroom_2 (`nores`): 1 page; heating and cooling "Not simulated … This is not a zero load", status Not
  simulated, no 0 W, normal "saved" box (no error). PASS.
- **C** Space Assumptions PDF (tree menu, Bathroom_2): 1 page, layout intact. PASS.
- **D** Edit › Reports holds both commands; tree and view context menus hold both; ribbon with nothing selected →
  "Select one Space, then choose Space Design Load Summary PDF."; one Space selected in the view → ribbon › Save dialog ›
  Cancel: no file, no message; ribbon › Save → "saved … Open it now?" (Bathroom_2 PDF); two Spaces (Ctrl+click) →
  "2 Spaces are selected. … one Space at a time" and both items disabled in the view menu; one Space → both enabled. PASS.
- Text of the installed PDFs equals the pre-deploy dev-build PDFs (`C:\TasOut\pr2d`) apart from the version/date lines
  and SAM#159's intended wording (Peak load → Peak sensible load, SENSIBLE COMPONENTS → SENSIBLE LOAD COMPONENTS, HOY
  legend). Numbers identical.
- Loaded modules: SAM.Core/Analytical, the 3 reporting DLLs, PdfSharp*/MigraDoc* and Microsoft.Extensions all from
  `%APPDATA%\SAM` at 2026.3.218.0 / 6.2.0.7443; none from elsewhere. No runtime or dependency error in any case.
- Evidence (outside git): `C:\TasOut\deploy-pr2e-smoke-2026-09-27` (`installer-run.log`, `install.log`,
  `installed-gate.txt`, `loaded-modules.txt`, `pdf\` PDFs + page PNGs, `screens\`, `scripts\`).

**Limitations.** One VM; no upgrade-over-previous or uninstall test; no licensed Tas run (typed-peak fixtures from PR2D).
The UI driver needs the SAM window forced to the foreground (Alt-key + `SetForegroundWindow`, abort if not) - otherwise
real mouse clicks land on whatever window is in front.

**Carry into PR2F (observed, not changed here).** Thermostat sentinels print as −50 / 150 °C; the zero-row note under
SENSIBLE LOAD COMPONENTS AT PEAK also lists latent terms (Bathroom_2); footer right shows the legend "— not available"
even when nothing is missing; the fixtures' SIZING block reads 0 W while the peaks are real (fixture data, not a regression);
raw Tas design-day names (`Leeds_TRY ANN CLG 0% CONDS DB=>GRad`).

## 2026-09-26 B0 Phase-1 correctness deployment (SAM#147) - MERGED as SAM_Deploy#54 (`e5cfeb14`)

| Submodule | Old pin | New pin | Includes |
|---|---|---|---|
| SAM | `22f9c743` | `00db4b85` | SAM#147 one ParameterSet per assembly name (stale design-load read, B0); docs SAM#144/#145 |

SAM_UI (`4b773f3e`) and SAM_Tas (`b32c0808`) are unchanged. The fix is inside SAM.Core, so no SAM_UI or SAM_Tas code
change is needed.

The Phase-1 matrix was deliberately not repeated; this is a narrow correctness deployment.

**Installer build.** installer.yml run [36269327511](https://github.com/SAM-BIM/SAM_Deploy/actions/runs/36269327511) on
`63bf446` (dispatch, `publish_release=false`): success, release job skipped, nothing published.
- Artifact `SAM_Install_v20260926.217.exe`, 249,793,720 bytes, SHA-256
  `3b9f356f4937a855f4e283ae80d2c94e5ed6a9cc0045b4e7f4d4938122f21e0d`. SAMVersion `2026.3.217.0+63bf446`.
- *Assert reporting/PDF payload*: passed (85 assemblies resolved from the payload, 1 from the runtime).
- H12 (enforce): **no violations**. SAM.Core, SAM.Analytical and the reporting DLLs are `2026.3.217.0`.
- Drift: the same 3 unclassified warnings as runs 216 and 214 (System.Text.Json, System.Text.Encodings.Web,
  System.Threading.Tasks.Extensions). There is nothing new.

**Installed-product regression (26 Sep, this VM).**
- Silent install (`/VERYSILENT /SUPPRESSMSGBOXES`): exit 0.
- Because of the MSIX trap, the files the installer wrote to `%APPDATA%\SAM`, taken from its log, were copied to a clean
  folder. That folder passes `assert-reporting-payload.ps1` (exit 0).
- Fixture: a copy of `C:\TasOut\final1b\open_out.sam`. The source md5 `d55f2c33…` was unchanged afterwards.
- UI Automation path: launch `SAM Analytical.exe` with `/Path=<copy>`, then Spaces › **Bathroom_2** › Select, then
  Edit › Reports › **Space Assumptions PDF**, then save. The app reported "Space Assumptions PDF saved".
- PDF (`Bathroom_2 - Space Assumptions.pdf`, 55,949 bytes): **1 page, A4**, Noto Sans Regular and Bold embedded,
  PDFsharp 6.2.0, footer `SAM 2026.3.217.0+63bf446 … Page 1 / 1`.
  - **Design load 1,140 W (heating) / 0 W (cooling)**, i.e. 1139.87 W at display precision.
  - Design load per area 45.6 W/m².
  - Before, with a pre-fix SAM.Core and the same click path, it read **0 W / 0 W**. That run used the local dev build
    of SAM_UI, not an installer.
- Loaded modules: SAM.Core, SAM.Analytical, the 3 reporting DLLs, PdfSharp and MigraDoc all came from the clean
  installed folder (`2026.3.217.0`; PDFsharp/MigraDoc `6.2.0.7443`). There was no missing-dependency or runtime error.
- Evidence (outside git): `C:\TasOut\deploy-b0-smoke-2026-09-26`. It holds `install.log`, `run.log`, `h12\`,
  `clean-gate.txt`, `installed-run\` (PDF, `loaded-modules.txt`), `dryrun-dev\` (the before PDF), and `smoke.ps1` /
  `checkpdf.py`.

**Limitations.** One VM and one Space. No upgrade or uninstall test. No licensed Tas run.

**Next step.** Merge this PR, then SAM#148 (audit doc: B0 fixed). After that, PR2A in SAM_Tas (the result contract,
B1–B5).

## 2026-09-26 Space Assumptions PDF deployment (SAM_UI#121) - MERGED as SAM_Deploy#51 (`8e6740af`)

```text
SAM Documentation Framework — Phase 1
Status: COMPLETE        deployment gate: COMPLETE (SAM_Deploy#51 merged as 8e6740af)
```

Pins on `sow/2026-Q3`: SAM `22f9c743`, SAM_UI `7e7de033`. Validate CI was green on the merged head `45568a3e`. The
Phase 1 completion record is in SAM `documentation/Reporting-PDF.md` › *Phase 1 status*.

Unrelated housekeeping, left untouched: `SAM_Tas-113`, `SAM_Tas-ord` and `SAM_Tas-table` are local scratch worktrees
beside the repos. Their upstream branches are gone or missing, so `BuildAlls_v4.bat pull` stops on them. They are not
part of the deployment.

Proves the installed product ships and runs Edit › Reports › **Space Assumptions PDF**:
`SAM Analytical.exe` -> `SAM.Analytical.Reporting` / `SAM.Core.Reporting` -> `SAM.Core.Reporting.Pdf` -> MigraDoc/PDFsharp.
The renderer design is documented in SAM (`documentation/Reporting-PDF.md`) and is not repeated here.

| Submodule | Old pin | New pin | Includes |
|---|---|---|---|
| SAM | `78a57466` | `22f9c743` | SAM#141 PDF renderer (`ba343bfb`); SAM#143 airflow symbol `l/s` -> `L/s` (`22f9c743`) |
| SAM_UI | `5a0b9bf6` | `7e7de033` | SAM_UI#121 Space Assumptions PDF (`7e7de033`); #120 docs |

Both are fast-forwards to the merged `sow/2026-Q3` tips. No other gitlink moves: SAM_Tas `aa00ff91` only adds docs
above its pin and is left alone.

**Where the payload comes from.** SAM.Core.Reporting.Pdf is a netstandard library, so `SAM\build` never carries its
NuGet dependencies. SAM_UI's `PackageReference PDFsharp-MigraDoc 6.2.0` puts PdfSharp*/MigraDoc* 6.2.0 and
Microsoft.Extensions.* 8.0 into `SAM_UI\build`; its post-build copies them to `%APPDATA%\SAM`, which *Stage payload*
packages. The licences also come from SAM_UI: `licenses\NotoSans\OFL.txt` (linked from SAM) and
`licenses\PDFsharp-MigraDoc\LICENSE.txt`. No installer-side copy was added, so the DLLs have one source.

**New gate.** The `installer.yml` step *Assert reporting/PDF payload* (before H12) runs
`.github/scripts/assert-reporting-payload.ps1` on `SAM_Installer\build\SAM`. It fails the build unless:
- the 3 reporting DLLs, PdfSharp, PdfSharp.System/.Shared/.Charting, MigraDoc.DocumentObjectModel/.Rendering,
  Microsoft.Extensions.Logging.Abstractions and both licence files exist and are non-empty;
- every assembly the reporting DLLs reference, transitively, resolves to the payload root or to the .NET 8 shared
  runtime (pwsh uses System.Reflection.Metadata; Windows PowerShell uses a reflection-only load);
- `SAM.Core.Reporting.Pdf.dll` embeds NotoSans-Regular and NotoSans-Bold;
- every PdfSharp*/MigraDoc* in the root is 6.2.0, and no second copy exists outside `Revit 20xx\` (those are
  reported only).

**Installer build.** installer.yml run 36241348967 on `49bc441` (dispatch, `publish_release=false`): success.
Artifact `SAM_Install_v20260926.216.exe`, 249,796,983 bytes, SHA-256
`719805203948da5623b854f75ef66efaa2cd7676d5f3a50203cbd08665b4c989`. Nothing was published.
- New gate: passed (85 assemblies resolved from the payload, 1 from the runtime; fonts embedded).
- H12: "No H12 violations found". The reporting DLLs carry `2026.3.216.0`.
- Drift diagnostics: only the 3 existing warnings (System.Text.Json, System.Text.Encodings.Web,
  System.Threading.Tasks.Extensions), identical in the 23 Sep run 35823794153. None for PdfSharp, MigraDoc or
  Microsoft.Extensions.

**PDFsharp/MigraDoc in the installed payload** (all product version 6.2.0, file version 6.2.0.7443):
- `%APPDATA%\SAM`: PdfSharp, .BarCodes, .Charting, .Cryptography, .Quality, .Shared, .Snippets, .System, .WPFonts;
  MigraDoc.DocumentObjectModel, .Rendering, .RtfRendering. One copy of each.
- Separate paths with the same 6.2.0: `SAM\Revit 2025|2026|2027` (SAM_Revit) and the Rhino 8/9 packages
  (`McNeel\Rhinoceros\packages\<v>\SAM\1.0.0`, which also carry the reporting DLLs). No other version exists.
- Microsoft.Extensions.Logging.Abstractions 8.0.1024.46610, the only Extensions assembly the renderer references.

**Installed smoke test (26 Sep, this VM).**
- Install: silent (`/VERYSILENT /SUPPRESSMSGBOXES`), exit 0; the log lists 2,825 files.
- Fixture: the real 9-Space Part O model `SAM_zoningAM-CIBSEfutureZ1.sam` (SHA-256 `a7e09a25…`), unchanged afterwards.
- Click path, driven with UI Automation:
  1. Launch `%APPDATA%\SAM\SAM Analytical.exe` (2026.3.216.0+49bc441) with `/Path=<model>`.
  2. Model tree › Spaces › right-click **Studio 1_0** › Select.
  3. Edit › Reports › **Space Assumptions PDF** (enabled; the legacy Print RDS is still present).
  4. In the "Save Space Assumptions PDF" dialog, enter the path › Save.
- Result: "Space Assumptions PDF saved: … Open it now?". The file `Studio 1_0 - Space Assumptions.pdf` is 56,308
  bytes.
- PDF:
  - 1 page, A4 (210 × 297 mm);
  - fonts Noto Sans Regular and Bold (embedded subsets); producer PDFsharp 6.2.0;
  - SAM mark; footer "SAM 2026.3.216.0+49bc441 … Page 1 / 1";
  - air flow printed as **L/s** (3 times; no `l/s`, no cfm);
  - missing values shown as `—`; humidity set points `not set`;
  - opened in the default viewer with the layout intact.
- Loaded modules: all 11 reporting/PDF assemblies came from `%APPDATA%\SAM`, at the installer versions. There was
  no missing-DLL, resource or font-resolver error.
- Caveat, and the extra proof for it: `%APPDATA%\SAM` could not be emptied first. The agent runs inside the Claude
  desktop MSIX container, so its rename was virtualized, and the install overlaid 467 older dev files. The 1,036
  files the installer wrote there (taken from its log) were copied to a clean folder. That copy passes the gate.
  Launched from there, it produced the same PDF (56,306 bytes, same checks), with every reporting/PDF module loaded
  from the clean folder.

**Negative check.** A disposable copy of that installer-only folder, with `PdfSharp.dll` removed:
- gate: FAILED (missing PdfSharp.dll; unresolved reference PdfSharp), exit 1;
- app, same click path: an error box "The PDF could not be rendered: Could not load file or assembly 'PdfSharp,
  Version=6.2.0.0 …'", no file written, and the app keeps running.

The positive artefacts were not modified. The evidence is outside git, in `C:\TasOut\deploy-pdf-smoke-2026-09-26`
(`install.log`; `installed-run3\` screenshots, PDF and `loaded-modules.txt`; `clean-run\`; `negative-run\`).

**Limitations.**
- A smoke test on one VM and one Space, not the H1–H12 matrix.
- No upgrade or uninstall test.
- The "Open it now? › Yes" path was not driven again here (PR3 acceptance step H covers it); the PDF was opened
  directly.

**Outcome.** Merged as `8e6740af` on green validate. Future installer runs apply the gate automatically. Next step:
Phase 2 planning (not started).

## 2026-09-25 pointer bump: Nuaire reply + Part O workflow simplification

Only the four repos that carry the merged Part O work move. Every other submodule was already at its
`sow/2026-Q3` tip. Each move is a fast-forward to that tip.

| Submodule | Old pin | New pin | Includes |
|---|---|---|---|
| SAM | `875655fa` | `80b01052` | Nuaire reply SAM#133, docs SAM#134 |
| SAM_Systems | `df5dd332` | `22133736` | Nuaire reply SAM_Systems#29, docs SAM_Systems#30 |
| SAM_Tas | `f7d39351` | `39828c69` | Nuaire reply SAM_Tas#65, docs SAM_Tas#66 |
| SAM_UI | `4460dc3a` | `6230d7d1` | Nuaire reply SAM_UI#107/#108; workflow simplification SAM_UI#109, docs SAM_UI#110 |

**What moves.**
- Nuaire reply (A. Nash, 24 Sep): the guidance cooling supply is the exchanger (bypass, or recovery), then the
  DX drop, never below 13 C; bypass decided by the MVHR independently of the cooling-stat; 80 l/s default
  cooling airflow. Details in SAM's `PROJECT_PROGRESS.md`.
- Part O workflow simplification (SAM_UI only, no engineering change): the Part O Simulate dialog folded into
  a Hub "Simulation case"; one persistent progress window with honest stage-level progress; no success
  "Time elapsed ... OK" box; an Iteration 3 panel with a pre-flight of units/products before any TAS;
  Iteration 3 results stored per method (legacy records still read); the "Iteration 3 comparison" window,
  virtualised for large projects.

**Checks on these commits.**
- Each code PR (SAM#133, SAM_Systems#29, SAM_Tas#65, SAM_UI#107 and #109) had green CI and a completed Codex
  review before merge; the docs PRs had green CI.
- 2026-09-24: all four solutions rebuilt from the merged `sow/2026-Q3` heads (VS 18 MSBuild Release,
  0 errors).
- SAM_UI at the final tip: `SAM_UI.sln` 0 errors; `SAM.Analytical.UI.WPF.Tests` 1056/1056.
- Live smoke tests on the real `SAM Analytical.exe` with TAS (25 Sep): Prepare & Run (Iteration 1a) and an
  Iteration 3 manufacturer-guidance run, reopened in-session and in a fresh process without TAS. Record in
  SAM_UI `documentation/evidence/parto-workflow-simplification/LIVE-SMOKE-2026-09-25.md`.
- Not rerun here: the SAM, SAM_Systems and SAM_Tas test suites on the merged tips (their own PR records
  hold those results).

Manufacturer-guidance values stay PROVISIONAL until Nuaire confirms them; this is not a certification.
Run 214 remains the accepted 2026-Q3 candidate. No installer was built for this bump.

## 2026-09-24 pointer bump: Nuaire / Part O manufacturer guidance (SAM#123)

Only the four repos that carry the merged guidance work move (SAM#125/#131, SAM_Systems#25/#28,
SAM_Tas#63/#64, SAM_UI#105/#106). Every other submodule was already at its `sow/2026-Q3` tip. Each move
is a fast-forward.

| Submodule | Old pin | New pin |
|---|---|---|
| SAM | `86213eb3` | `875655fa` |
| SAM_Systems | `0e891145` | `df5dd332` |
| SAM_Tas | `c267f52f` | `f7d39351` |
| SAM_UI | `5606a82d` | `4460dc3a` |

**Merged-build acceptance on exactly these commits (2026-09-24).**
- Build: 0 errors in all four solutions (Framework MSBuild, Debug).
- Tests: SAM.Tests 2218/2218, SAM.Analytical.Systems.Tests 251/251, SAM.Analytical.Tas.TM59.Tests
  938/938, SAM.Analytical.UI.WPF.Tests 1031/1031.
- Native `SAM Analytical.exe`: the MG review-only reopen, the 1a reopen with Iteration 3 ready, and a
  fresh B0 whose TM59 reports equal the baseline apart from the `Source:` line. Details are in SAM's
  `PROJECT_PROGRESS.md`.

The product values stay PROVISIONAL manufacturer guidance until Nuaire confirms them; this is not a
certification. Run 214 remains the accepted 2026-Q3 candidate. No installer was built for this bump.

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
