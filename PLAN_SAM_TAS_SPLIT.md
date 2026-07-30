# SAM_Tas / SAM_Tas_Grasshopper Repository Split — P0 Verification Report (Revised)

**Date:** 2026-07-30 · **Mode:** PLAN / READ-ONLY — P0 ONLY · **Verified against:** `origin/sow/2026-Q3` in every repo, freshly fetched during this session. No edits, branches, commits, or pushes were made anywhere; all `git` operations below are read-only (`fetch`, `status`, `log`, `show`, `ls-tree`, `branch`, `stash list`, `diff --submodule=log`).

This revision applies five corrections requested after the first draft: (1) the SAM_Tas_Grasshopper CI strategy no longer refers to a nonexistent "engine + Grasshopper subset of SAM_Tas.sln" — it names the exact nine engine projects to build directly; (2) the resource-deployment design is now assigned its own PR, sequenced after the progress migration and before repo extraction, with idempotency/guard requirements spelled out; (3) P1's scope is corrected from "move" to "copy," with the SAM_UI original left untouched until the later deletion PR; (4) the repository-extraction sequence is now an explicit 12-step list; (5) PR numbering is updated throughout to include the new resource-deployment PR. Architecture, verified findings, and the overall verdict are unchanged from the first draft.

> **Execution status (2026-07-30, end of session):** PRs 1-5 below are merged (SAM_Windows#10, SAM_Tas#24, SAM_Tas#25, SAM_Revit_UI#23) or open awaiting review (SAM_Rhino_UI#11). See `HANDOVER.md` at the repo root for the current exact state, what each PR did, and the immediate next action — that file is the one to read first when resuming. This document is the full P0 investigation/design record, kept for reference when PRs 6-11 need the detailed rationale (identity baseline, CI strategy, resource-deployment target spec, the 13-step SAM_Tas_Grasshopper import sequence) behind them.

---

## 1. Preflight status

- Kimi's assessment (`C:\Users\Virtual Machine\Documents\SAM_daily\2026-07-30-Plan\NewPlan.MD`) was not attached to the original prompt; user pointed to this file, which has now been read in full.
- All seven affected repos fetched. SAM_Tas, SAM_UI, SAM_Windows, and the superproject (`SAM_Deploy`, = this workspace root) SHAs cross-checked against Kimi's citations.
- No working trees were dirty in a way that affects this split, except the superproject's own gitlink pointers (expected — §2) and pre-existing, unrelated local WIP (stashes/branches in SAM, SAM_Windows, SAM_Tas, SAM_Revit, SAM_Revit_UI — none conflict with the approved architecture; §2 "Unrelated local WIP").
- **Verdict: no blockers found.** Two items are logged as non-blocking corrections to Kimi's report (§2), and one pre-existing local branch should get a one-line conflict check at the start of P1 (§9).

---

## 2. Differences from Kimi's assessment

### 2a. Repository state (origin, fetched this session)

| Repo | Kimi's cited SHA | Current `origin/sow/2026-Q3` | Match? |
|---|---|---|---|
| SAM_Tas | `6c03805a` | `6c03805a3d1f1250f2ce3935a1dc8cc3ed91bc4a` | ✅ exact, no divergence |
| SAM_UI | `17a3ff7` | `17a3ff739ba3c25a23f0096828f17aa6bc9c8d22` | ✅ exact, no divergence |
| SAM_Windows | `c39bb6e` | `c39bb6e804d9e64c9512f6102bacf51514ad3bbd` | ✅ exact, no divergence |
| SAM_Deploy (superproject) | `07332f4` | `07332f4` = current checked-out HEAD; **origin tip is now `1673a57`, 7 commits ahead** | ⚠️ origin has moved — see below |

The 7 new superproject commits (`07332f4..1673a57`) are all submodule-pin bumps and doc/CI cleanups for **SAM_Revit, SAM_Revit_UI, SAM_Rhino_UI, SAM_UI** — **none touch the SAM_Tas gitlink**.

### 2b. Gitlink pin correction (non-blocking, cosmetic-but-worth-flagging)

Kimi states "SAM_Deploy currently pins SAM_Tas @ `8017a1bd` … and SAM_UI @ `92ef1b40`" as if both hold at the SAM_Deploy SHA Kimi cites (`07332f4`). **They don't both hold at that commit:**

- SAM_Tas gitlink at `07332f4`: `8017a1bd` ✅ matches Kimi, **and is unchanged at the current origin tip `1673a57` too** — the pin has not moved forward at all since Kimi's snapshot.
- SAM_UI gitlink at `07332f4`: actually `048f87b2` (not `92ef1b40`). `92ef1b40` only becomes the pinned SHA starting at the newer commit `05fa723`/`1673a57`.

**Practical effect: none on this split.** The only gitlink that matters for Finding E-1 (below) is SAM_Tas, and that one is confirmed exactly as Kimi described, at both the old and new superproject tips. This is purely a citation slip in Kimi's report.

### 2c. Finding E-1 — confirmed, plus one addition

Kimi's Finding E-1 (SAM_Deploy's `BuildAll_Release_net.csproj` is green today only because the pinned SAM_Tas gitlink `8017a1bd` predates PR #23) is **fully confirmed**:
- `git show 8017a1bd:Grasshopper/SAM.Analytical.Grasshopper.Tas/SAM.Analytical.Grasshopper.Tas.csproj` has zero `Core.UI.WPF`/`ProgressWindow` references.
- `git merge-base --is-ancestor 8017a1bd 6c03805a` confirms `8017a1bd` strictly precedes the PR #23 merge.

**Addition Kimi didn't call out explicitly:** `.github/workflows/installer.yml` inherits this exact same latency. It does `submodules: recursive` (line 40) then runs `BuildAll_Release_net.csproj` directly (lines 393, 406) — no per-repo special-casing. So the installer pipeline is "green by timing" for the identical reason as the local csproj build, not just the local build. This doesn't change the recommended fix (the atomic gitlink-bump PR, §7/§8), it just means the installer workflow needs no separate remediation beyond that same PR.

### 2d. Project count arithmetic error (should be corrected before anything machine-checkable is built on it)

Kimi states SAM_Tas.sln has "exactly 15 projects." **This is an arithmetic error in Kimi's own report** — Kimi's own breakdown is 9 engine + 3 benchmark + 6 Grasshopper = **18**, and direct `.sln` inspection confirms **18** real `.csproj` entries (plus 4 non-buildable Solution Folder pseudo-projects). The *names and classification* are 100% correct and complete — no project is missing or extra — only the summary count "15" is wrong. Use **18** in any baseline tooling.

### 2e. Two Grasshopper-plugin-identity corrections

- **`SAM.Weather.Grasshopper.Tas` and `SAM.Core.Grasshopper.Tas.UKBR` have no `GH_AssemblyInfo` subclass at all** — no independent Grasshopper plugin GUID exists for these 2 of the 6. Only 4 of 6 (`Core.GH.Tas`, `Analytical.GH.Tas`, `Analytical.GH.Tas.GenOpt`, `Analytical.GH.Tas.TPD`) have one. Nothing to preserve for the other 2 — not a blocker, just corrects an implicit assumption that all 6 carry a plugin identity.
- **Pre-existing (not split-related) duplicate plugin GUID:** `SAM.Core.Grasshopper.Tas` and `SAM.Analytical.Grasshopper.Tas` both declare the identical `GH_AssemblyInfo.Id = 41efcf7f-7fc8-4ed2-85d0-d116b6c30e8b` / `Name = "SAM"`. This exists today, independent of the split, and the split neither fixes nor worsens it. Flagged as a non-blocking pre-existing risk (§10), not something to fix in this programme unless asked.

### 2f. Path citation corrections (cosmetic only)

Kimi's consumer-site paths omit one folder-nesting level that actually exists on disk:
- Actual: `SAM_UI\WPF\SAM.Analytical.UI.WPF\...` (Kimi wrote `SAM_UI\SAM.Analytical.UI.WPF\...`)
- Actual: `SAM_UI\SAM_UI\SAM.Analytical.UI\Modify\PrintRoomDataSheets.cs`
- Actual: `SAM_Revit_UI\SAM_Revit_UI\SAM.Analytical.Revit.UI\...`
- Same nesting exists for SAM_Tas's own engine tier: `SAM.Core.Tas.csproj` lives at `SAM_Tas\SAM_Tas\SAM.Core.Tas\SAM.Core.Tas.csproj` relative to the repo root (i.e. the repo has an inner `SAM_Tas\` physical folder mirroring the sln's "SAM_Tas" solution folder), while `Grasshopper\` and `benchmark\` sit directly at repo root, and `files\resources\` also sits directly at repo root. This matters for the MSBuild path math in §6.

No functional effect on the architecture — every referenced API/site itself is confirmed correct.

### 2g. Unrelated local WIP present in the workspace (informational, not blockers)

None of the following relate to the Tas/progress split; listed only because P0 was asked to report unpushed/overlapping work:
- `SAM`: unmerged local branches `fix/plane-optimalization`, `fix/shellsplitter-optimalization` (remotes deleted); 2 unrelated GitHub-Desktop/manual stashes (map-panels perf test, Grasshopper-component-modernisation JSON).
- `SAM_Windows`: unmerged local branch `feature/tas-workflow-progress-cancel` @ `7e10da8` ("add", remote deleted) — **name coincidentally overlaps this programme's theme; see §9 for the one check this needs before opening PR 1.**
- `SAM_Tas`: local branch `feature/tas-workflow-progress-cancel` — already merged except a single orphaned "WIP" tip commit; no action needed.
- `SAM_Revit_UI`: unmerged local branches `ci/build-revit-2027`, `fix/revit-2027-appdata-deploy` (remotes deleted) — unrelated to this split.
- `SAM_Revit`: one unrelated stash ("WIP on sow/2026-Q3-update-optimization").
- Superproject: one disconnected orphan branch `claude/mystifying-lumiere-9af0ce` (single root commit, not on origin, not reachable from `sow/2026-Q3`) — harmless, unrelated, not touched.
- Superproject's local `sow/2026-Q3` branch has **no upstream configured** (unusual vs. every submodule, which all track normally) — worth being aware of before pushing any SAM_Deploy PR branch in P1, but not a blocker.

---

## 3. Approved implementation inventory (§B, verified)

**SAM_Tas.sln — 18 projects, confirmed complete and correctly classified** (corrects the "15" in §2d):

| Class | Projects | TFM | Disposition |
|---|---|---|---|
| Engine (9) | Core.Tas, Analytical.Tas, Geometry.Tas, Weather.Tas, Core.Tas.UKBR, Analytical.Tas.TM59, Analytical.Tas.SAP, Analytical.Tas.TPD, Analytical.Tas.GenOpt | netstandard2.0 (all 9, confirmed) | stays |
| Benchmark (3) | Analytical.Tas.Benchmark, Analytical.Tas.Benchmark.Cli, Analytical.Tas.Benchmark.Tests | net8.0 / net8.0-windows (Cli) — not netstandard2.0, flagged for completeness only | stays |
| Grasshopper (6) | Core.Grasshopper.Tas, Analytical.Grasshopper.Tas, Weather.Grasshopper.Tas, Core.Grasshopper.Tas.UKBR, Analytical.Grasshopper.Tas.GenOpt, Analytical.Grasshopper.Tas.TPD | net8.0-windows (all 6) | **moves** |

**The nine engine projects — exact paths (repo-relative) and verified internal dependency order:**

| Order | Project | Path | Depends on (internal) |
|---|---|---|---|
| 1 | SAM.Core.Tas | `SAM_Tas\SAM.Core.Tas\SAM.Core.Tas.csproj` | (leaf) |
| 2 | SAM.Geometry.Tas | `SAM_Tas\SAM.Geometry.Tas\SAM.Geometry.Tas.csproj` | (leaf) |
| 3 | SAM.Core.Tas.UKBR | `SAM_Tas\SAM.Core.Tas.UKBR\SAM.Core.Tas.UKBR.csproj` | (leaf) |
| 4 | SAM.Weather.Tas | `SAM_Tas\SAM.Weather.Tas\SAM.Weather.Tas.csproj` | Core.Tas |
| 5 | SAM.Analytical.Tas | `SAM_Tas\SAM.Analytical.Tas\SAM.Analytical.Tas.csproj` | Core.Tas, Core.Tas.UKBR, Geometry.Tas, Weather.Tas |
| 6 | SAM.Analytical.Tas.TM59 | `SAM_Tas\SAM.Analytical.Tas.TM59\SAM.Analytical.Tas.TM59.csproj` | Core.Tas, Analytical.Tas |
| 7 | SAM.Analytical.Tas.SAP | `SAM_Tas\SAM.Analytical.Tas.SAP\SAM.Analytical.Tas.SAP.csproj` | Analytical.Tas |
| 8 | SAM.Analytical.Tas.TPD | `SAM_Tas\SAM.Analytical.Tas.TPD\SAM.Analytical.Tas.TPD.csproj` | Core.Tas |
| 9 | SAM.Analytical.Tas.GenOpt | `SAM_Tas\SAM.Analytical.Tas.GenOpt\SAM.Analytical.Tas.GenOpt.csproj` | Core.Tas |

(Paths shown are relative to the SAM_Tas repo root, i.e. full path from workspace root is `SAM_Tas\SAM_Tas\SAM.Core.Tas\...` per the inner-folder nesting noted in §2f.) This is also confirmed to be the **complete and minimal** set: the union of every engine `ProjectReference`/HintPath pulled in by the six Grasshopper adapters (Core.Tas, Analytical.Tas, Weather.Tas, Core.Tas.UKBR, Analytical.Tas.SAP, Analytical.Tas.TM59, Analytical.Tas.TPD, Analytical.Tas.GenOpt, plus transitively Geometry.Tas) equals exactly these nine — none can be dropped, none are extraneous.

**Per-project verified baseline (the six movers):**

| Project | sln GUID | GH plugin GUID | ComponentGuids | SAM.Core.UI.WPF ref | SAM.Core.Windows ref | .resx |
|---|---|---|---|---|---|---|
| Core.Grasshopper.Tas | `{B8F0EE34-A776-4518-ADA2-E047E468B47B}` | `41efcf7f-...` ⚠️dup | 3 | no | no | yes |
| Analytical.Grasshopper.Tas | `{F0881D8C-68B0-4F9C-AFCE-61C0A7C1F293}` | `41efcf7f-...` ⚠️dup | 67 | **yes** (2 sites) | **yes** (RunOnStaThread + ProgressForm) | yes |
| Weather.Grasshopper.Tas | `{10C34676-558F-4C79-8D73-D7E4AE1B06A1}` | none (no GH_AssemblyInfo) | 2 | no | no | yes |
| Core.Grasshopper.Tas.UKBR | `{6AD97F9A-C18B-41CB-9CB7-FE0A3EF247DC}` | none (no GH_AssemblyInfo) | 2 | no | no | yes |
| Analytical.Grasshopper.Tas.GenOpt | `{FFF18B3E-2C47-4557-9BD9-9E888AA82180}` | `5e5594d2-...` | 16 | no | no | yes |
| Analytical.Grasshopper.Tas.TPD | `{83EE9A11-1D2A-470C-BE4C-4416952720AC}` | `a4d423e9-...` | 14 | no | **yes** (RunOnStaThread) | yes |

Total ComponentGuids: 3+67+2+2+16+14 = **104**, matching Kimi's cited total exactly.

- **PostBuild targets: byte-identical (MD5-verified) across all 6** — safe to template. Their raw form (confirmed by direct inspection of `SAM.Core.Grasshopper.Tas.csproj`) is a single `<Target Name="PostBuild" AfterTargets="PostBuildEvent">` wrapping an `<Exec Command="...">` batch script that: copies `.dll`→`.gha`, mirrors `*.dll` into `%APPDATA%\SAM\`, `xcopy`s `$(SolutionDir)\files\resources` into both `$(APPDATA)\SAM\resources` and `$(USERPROFILE)\Documents\SAM\resources`, and (guarded by `if Exist`) `xcopy`s `$(SolutionDir)\files\Grasshopper\UserObjects` into `$(APPDATA)\Grasshopper\UserObjects\SAM`. This exact property-naming convention (`$(APPDATA)`, `$(USERPROFILE)`) is what §6's new target reuses.
- `files\resources\` at the SAM_Tas repo root contains **only** `Analytical\Tas\` (confirmed via directory listing) — so the existing `xcopy $(SolutionDir)\files\resources` is already scoped to exactly the Tas resource set; nothing else is being (or needs to be) carried along.
- `Analytical.Grasshopper.Tas` is the only one with `UseWPF=true`; it also has 3 external-repo HintPath refs beyond SAM_Tas (`SAM_gbXML`, `SAM_Windows`, `SAM_UI`).
- `Analytical.Grasshopper.Tas.TPD` additionally HintPath-references `SAM_Systems` (4 assemblies) — a 4th external repo dependency for that one project, already reflected in Kimi's CI dependency table.

**Non-project files** (`files\resources\Analytical\Tas\`, `files\Grasshopper\UserObjects\SAM_Tas\`) — contents enumerated and confirmed to match Kimi's disposition table. **Confirmed by direct grep: the engine itself hardcodes filenames from this resource set** (`SAM.Analytical.Tas\Manager\ActiveSetting.cs:46-47` → `Calendars.tcr`, `NCMActivities_v6.1.b (Part L 2021).tic`; `SAM.Analytical.Tas.GenOpt\Create\Files.cs:8-13` → `Template.txt`, `Variables.txt`, `Command.txt`). This is the load-bearing fact behind §6's design — the engine needs these files at runtime, but today only the (soon-to-move) Grasshopper projects' post-build actually deploys them.

---

## 4. Progress API and consumer inventory (§C, verified)

**Complete list of live `ProgressWindowHost` / `ProgressWindow` / `Query.Duration` consumers — confirmed exhaustive** (full-workspace grep across every `SAM_*` repo found no consumers beyond this list):

| # | Site | API |
|---|---|---|
| 1 | `SAM_Tas\Grasshopper\SAM.Analytical.Grasshopper.Tas\Modify\RunWorkflow.cs:67` | ProgressWindowHost |
| 2 | `SAM_Tas\Grasshopper\SAM.Analytical.Grasshopper.Tas\Component\SAMAnalyticalWorkflowTBD.cs:331` | ProgressWindowHost |
| 3 | `SAM_Revit_UI\SAM_Revit_UI\SAM.Analytical.Revit.UI\Modify\RunWorkflow.cs:67` | ProgressWindowHost |
| 4 | `SAM_Revit_UI\SAM_Revit_UI\SAM.Analytical.Revit.UI\IExternalCommands\Simulate.cs:144` | ProgressWindowHost |
| 5–6 | `SAM_UI\WPF\SAM.Analytical.UI.WPF\Modify\RunWorkflow.cs:64,218` | ProgressWindowHost |
| 7–8 | `SAM_UI\WPF\SAM.Analytical.UI.WPF\Modify\Simulate.cs:130,543` | ProgressWindowHost |
| 9 | `SAM_UI\SAM_UI\SAM.Analytical.UI\Modify\PrintRoomDataSheets.cs:61` | ProgressWindow (direct) |

= exactly 9 call sites across 2 GH-Tas + 2 Revit_UI + 4 Analytical.UI.WPF + 1 Analytical.UI, matching Kimi's "~9 call sites" migration-effort estimate exactly.

**Implementation** (`SAM_UI\WPF\SAM.Core.UI.WPF\Windows\ProgressWindow.xaml(.cs)`, `\Classes\ProgressWindowHost.cs`, `\Query\Duration.cs`) confirmed self-contained; `Query\Duration.cs` line 15 has an explicit comment calling itself *"a deliberate twin of `SAM.Core.Windows.Query.Duration` rather than a shared implementation"* — confirms the canonical twin at `SAM_Windows\SAM_Windows\SAM.Core.Windows\Query\Duration.cs` is safe to reuse and the UI.WPF copy is safe to delete once every consumer is migrated (§11).

**No committed binaries, no reflection-based loading found anywhere in the workspace.** The only `SAM.Core.UI.WPF.dll` files present are untracked, gitignored `build\` output in SAM_Tas/SAM_Revit_UI/SAM_Rhino_UI/SAM_UI — not a distribution/discovery concern.

**Recommendation on forwarding wrappers (Approved Decision #5):** the audit found **no consumers outside the known source repos** (SAM_Tas, SAM_Revit_UI, SAM_UI — all 9 sites accounted for, all in-repo source, no external binary/reflection consumers). **Obsolete forwarding wrappers are not necessary.** Delete the 4 files from `SAM.Core.UI.WPF` cleanly once all consumer-migration PRs land (§7).

**Separately confirmed, out of scope for this migration but worth noting for completeness:**
- `RunOnStaThread` (SAM.Core.Windows, WinForms-tier): 2 live consumers, both already in SAM_Tas's Grasshopper projects (`TasSimulate.cs:220`, `SAMSystemsTASTPDSimulate.cs:144`) — stays exactly as-is per Decision #6.
- `Core.Windows.Forms.ProgressForm`: 11 live consumers (7× SAM_Revit_UI, 2× SAM_Windows itself, 1× SAM_Tas's `SAMAnalyticalWait.cs:104`, plus the one already counted above) — all WinForms, untouched per Decision #6.

---

## 5. Corrected CI dependency graph (§D)

**Selected strategy — exact, as specified:** during the population-PR window (i.e. while SAM_Tas still temporarily contains the six legacy Grasshopper projects on `sow/2026-Q3`), SAM_Tas_Grasshopper's own CI **never builds SAM_Tas.sln, in whole or "subset" form** — the Grasshopper projects are built **only** from `SAM_Tas_Grasshopper.sln`. SAM_Tas_Grasshopper's workflow instead builds the nine named SAM_Tas engine `.csproj` files directly, by explicit project list:

1. Start from a clean runner (no cached `build\` output from any prior job).
2. Clone and build the verified dependency chain, in order: `SAM → SAM_Psychrometrics → SAM_Mollier → SAM_Systems → SAM_Windows → SAM_gbXML → SAM_SolarCalculator`.
3. Build **only** the nine SAM_Tas engine projects listed in §3, in the dependency order shown there (`SAM.Core.Tas`, `SAM.Geometry.Tas`, `SAM.Core.Tas.UKBR`, `SAM.Weather.Tas`, `SAM.Analytical.Tas`, `SAM.Analytical.Tas.TM59`, `SAM.Analytical.Tas.SAP`, `SAM.Analytical.Tas.TPD`, `SAM.Analytical.Tas.GenOpt`) — each built by explicit `.csproj` path, not via `SAM_Tas.sln`.
4. Do **not** build: the six legacy Grasshopper projects still temporarily present in SAM_Tas (they remain untouched in the SAM_Tas repo until PR 8, §7); the three benchmark projects; `SAM_Validation` (only the benchmark projects need it — the engine and the Grasshopper adapters never reference it).
5. Build all six projects in `SAM_Tas_Grasshopper.sln`.
6. Verify no `SAM_UI` repository is cloned and no `SAM.Core.UI.WPF` build output exists anywhere in the job workspace (a job-end assertion step: fail if `SAM_UI\` directory or `SAM.Core.UI.WPF.dll` is found).

**After PR 8** (six Grasshopper projects removed from SAM_Tas, §7), SAM_Tas_Grasshopper's CI **may continue using this same explicit nine-project build list unchanged** — it was never coupled to the Grasshopper projects still being physically present in SAM_Tas, so their removal doesn't invalidate anything about this workflow. SAM_Tas's own CI remains separately responsible for building its complete engine-and-benchmark solution (all 12 projects post-split), including `SAM_Validation` for the benchmark tier — that dependency is internal to SAM_Tas's own workflow and does not leak into SAM_Tas_Grasshopper's.

**What the CI must prove (all four, achievable with this strategy):**
- SAM_Tas builds without SAM_UI → proven by SAM_Tas's own CI (no SAM_UI clone anywhere in its workflow, confirmed today and unchanged post-split).
- Required SAM_Tas outputs exist → proven by SAM_Tas_Grasshopper's workflow building the nine named engine projects from source, from a clean runner, in the same job, before building its own `.sln` — not trusting a cross-job artifact cache.
- SAM_Tas_Grasshopper builds without SAM_UI → proven structurally by step 6's explicit assertion, plus the fact that no `.csproj` in the six moved projects will reference `SAM.Core.UI.WPF` after PR 2 lands (verified already true today for 5 of 6; `Analytical.Grasshopper.Tas` becomes true once PR 2's HintPath swap merges).
- No hidden output masks a missing dependency → achieved by the clean-runner requirement in step 1 and the explicit nine-project build list in step 3 (no accidental pickup of the six legacy Grasshopper projects' outputs, since they're never built by this workflow at all, even though they still exist in the SAM_Tas working tree during the population-PR window).

---

## 6. Resource-deployment design and its own PR (§E)

**This design is now assigned to its own PR** (PR 3 in §7) — it does not ride along with the progress-consumer migration, and the new repository's population PR (PR 7) explicitly may not remove the six legacy resource-copy operations from the Grasshopper post-builds until this PR has merged and been verified (§7, §8).

**Requirement (Decision #11):** SAM_Tas remains sole canonical owner; one explicit mechanism; remove copying from all 6 Grasshopper post-build targets (deferred until this PR is verified, per above); installer payload equivalent; deployed exactly once in effect (a single idempotent producer, not a claim of exactly-one invocation); works with SAM_Tas built alone; no new SAM_Tas→SAM_Tas_Grasshopper dependency; no CI reliance on stale APPDATA.

### Where the target lives: SAM.Core.Tas vs. a repository-level target

**Recommendation: keep it directly in `SAM.Core.Tas.csproj`.** Reasoning, weighed against the alternative of a repo-level `Directory.Build.targets` or a dedicated deployment-only project:

- Every cross-repo consumer of SAM_Tas engine output (SAM_Revit_UI, SAM_UI, the Grasshopper adapters today, SAM_Tas_Grasshopper post-split) references the built DLLs via **HintPath**, never `ProjectReference` — confirmed as the universal pattern across this codebase (§4). That means a target attached to `SAM.Core.Tas.csproj` can only ever fire when SAM_Tas's **own** build process compiles `SAM.Core.Tas` from source — i.e. inside SAM_Tas's own CI/local build, or inside SAM_Tas_Grasshopper's CI when it builds the nine engine projects from source in the same job (§5). It cannot accidentally fire inside a downstream repo's build.
- A repo-level `Directory.Build.targets` would apply to all 9 (post-split: 12) projects in the repo unless scoped with an identical `Condition="'$(MSBuildProjectName)'=='SAM.Core.Tas'"` — i.e. it would need the exact same anchor-project condition, just relocated to a second file, adding indirection without added safety.
- A dedicated deployment-only project would need its own build-order slot and solution wiring that Decision #11 doesn't ask for ("one explicit mechanism," not a new project).
- `SAM.Core.Tas` is the correct anchor specifically because it is a leaf project with no internal SAM_Tas dependencies (§3) — every one of the other 8 engine projects depends on it directly or transitively, so it is guaranteed to be part of any real build of the engine tier, in both SAM_Tas's own solution build and SAM_Tas_Grasshopper's explicit nine-project CI list.

This conclusion is conditional on the HintPath-only cross-repo reference pattern holding, which is directly confirmed by the repository evidence gathered in §4 and §3 — not assumed.

### The target, with every required guard — **already implemented, see `SAM_Tas/SAM_Tas/SAM.Core.Tas/SAM.Core.Tas.csproj` on `sow/2026-Q3` (SAM_Tas#25, merged)**

```xml
<Target Name="DeploySamTasResources"
        AfterTargets="Build"
        Condition="'$(DesignTimeBuild)' != 'true' And Exists('$(MSBuildThisFileDirectory)..\..\files\resources\Analytical\Tas')">
  <ItemGroup>
    <TasResourceFiles Include="$(MSBuildThisFileDirectory)..\..\files\resources\Analytical\Tas\**\*.*" />
  </ItemGroup>
  <MakeDir Directories="$(APPDATA)\SAM\resources\Analytical\Tas"
           Condition="!Exists('$(APPDATA)\SAM\resources\Analytical\Tas')" />
  <MakeDir Directories="$(USERPROFILE)\Documents\SAM\resources\Analytical\Tas"
           Condition="!Exists('$(USERPROFILE)\Documents\SAM\resources\Analytical\Tas')" />
  <Copy SourceFiles="@(TasResourceFiles)"
        DestinationFiles="@(TasResourceFiles->'$(APPDATA)\SAM\resources\Analytical\Tas\%(RecursiveDir)%(Filename)%(Extension)')"
        SkipUnchangedFiles="true" />
  <Copy SourceFiles="@(TasResourceFiles)"
        DestinationFiles="@(TasResourceFiles->'$(USERPROFILE)\Documents\SAM\resources\Analytical\Tas\%(RecursiveDir)%(Filename)%(Extension)')"
        SkipUnchangedFiles="true" />
</Target>
```

Every requested element, and why:
- **`DesignTimeBuild` guard** — prevents IntelliSense/design-time builds (triggered constantly while `SAM.Core.Tas` is open in an IDE) from performing file-system side effects.
- **Source-directory existence condition** (`Exists(...)` on the target itself) — the target silently no-ops if `files\resources\Analytical\Tas` isn't present (e.g. a partial/sparse checkout), rather than failing the build.
- **`$(MSBuildThisFileDirectory)`-relative pathing, not `$(SolutionDir)`** — `SolutionDir` is only defined when MSBuild is invoked against a `.sln`; SAM_Tas_Grasshopper's CI builds the nine engine `.csproj` files directly (§5), not via `SAM_Tas.sln`, so a solution-relative path would silently fail there. `SAM.Core.Tas.csproj` sits at `SAM_Tas\SAM_Tas\SAM.Core.Tas\SAM.Core.Tas.csproj` relative to the repo root (§2f), and `files\resources` sits at `SAM_Tas\files\resources`, so the correct relative path from the csproj is `..\..\files\resources\Analytical\Tas` (first `..` exits `SAM.Core.Tas\` into the inner `SAM_Tas\` folder, second `..` exits that into the repo root) — verified directly against the actual on-disk layout, not assumed.
- **`$(APPDATA)` / `$(USERPROFILE)`** — the exact same MSBuild-exposed environment properties already used, verified byte-for-byte, in the six existing Grasshopper post-build targets (§3) — no new property names introduced.
- **Explicit destination-directory creation (`MakeDir`)** — added even though `<Copy>` auto-creates destination folders, so the deployment path's existence is asserted explicitly and independently testable/inspectable rather than an implicit side effect of the copy.
- **`SkipUnchangedFiles="true"`** on both `<Copy>` calls — makes the target a safe, cheap no-op on repeat invocations (e.g. if `SAM.Core.Tas` is rebuilt more than once in a session, or if a future multi-proc build evaluates the target from more than one project context). The target is a **single canonical, idempotent producer** of this deployment — not a guarantee that it executes exactly once; multiple evaluations converge to the same on-disk result with no duplication or corruption risk.

### Installer-staging preservation (verified, zero changes needed)

Confirmed by direct inspection: `installer.yml:702` does `Copy-IfExists "$env:USERPROFILE\Documents\SAM" → stage\user\Documents\SAM` **after the full `BuildAll_Release_net.csproj` build completes**, and `Build_Installer.iss:64` stages `build\user\Documents\SAM\resources\*` into `{userappdata}\SAM\resources` at install time. Since SAM_Tas builds before SAM_Tas_Grasshopper in the final build order (§8), the new target populates `Documents\SAM\resources\Analytical\Tas` before that staging step runs — identical timing/outcome to today's Grasshopper-post-build mechanism, just relocated to the correct owner. **No change to `installer.yml` or `Build_Installer.iss` is required.**

### Required verification for this PR (clean-profile test — corrected) — **already run for SAM_Tas#25, see that PR's body for results**

A solution build would not prove what this PR needs to prove: while the six legacy Grasshopper copy targets still coexist (they are not trimmed until PR 7), building `SAM_Tas.sln` would populate the resource trees whether or not the new target works. The verification must therefore isolate the new target by building its project directly:

1. **Clear or redirect both destination folders** — `%APPDATA%\SAM\resources\Analytical\Tas` and `%USERPROFILE%\Documents\SAM\resources\Analytical\Tas` (rename aside rather than delete, so the prior state is recoverable).
2. **Build `SAM.Core.Tas.csproj` directly, with full Visual Studio MSBuild** — not `SAM_Tas.sln`, and not `dotnet build`. Building the single project is what excludes the six legacy Grasshopper copy targets from the run entirely, and full VS MSBuild is what matches the environment the `$(APPDATA)`/`$(USERPROFILE)` properties and COM-bearing engine projects are actually built under.
3. **Confirm the new target alone recreates both resource trees** — both destinations fully repopulated from nothing, by this target and nothing else.
4. **Then build the full `SAM_Tas.sln`** to verify the new target coexists cleanly with the still-present legacy Grasshopper copy targets — no failure, no conflict, no duplicated or corrupted output where both mechanisms write the same destinations.
5. **Record explicitly in the PR that step 2's direct project build — not step 4's solution build — is what proves independent resource ownership.** Step 4 only proves compatibility during the transition window; it cannot demonstrate ownership, because the legacy copy targets are still active in that build.

---

## 7. Exact PR and branch sequence (§F)

All branches from current `origin/sow/2026-Q3` in their respective repo (except PR 3, based on SAM_Tas `origin/sow/2026-Q3` **after PR 2 merges**, as stated). Sequence renumbered to insert the resource-deployment PR as PR 3; every subsequent PR's prerequisites are restated against the new numbering.

| # | Repo / branch → base | Prereq | Changed areas | Build/CI proof | Hand test | Rollback |
|---|---|---|---|---|---|---|
| **1** ✅ merged [#10](https://github.com/SAM-BIM/SAM_Windows/pull/10) | SAM_Windows `feature/wpf-progress-host` → sow/2026-Q3 | — | **Copy** (not move) `ProgressWindow.xaml(.cs)` and `ProgressWindowHost.cs` into `SAM.Core.Windows`, namespace `SAM.Core.Windows.WPF`, reusing existing `Query.Duration`. Original `SAM.Core.UI.WPF` files untouched. Full scope in §11. | SAM_Windows CI (SAM-only deps) | none (no consumers yet) | revert PR |
| **2** ✅ merged [#24](https://github.com/SAM-BIM/SAM_Tas/pull/24) | SAM_Tas `feature/gh-progress-to-sam-windows` → sow/2026-Q3 | 1 | Switch 2 call sites to `SAM.Core.Windows.WPF.ProgressWindowHost`; delete `SAM.Core.UI.WPF` HintPath ref from `Analytical.Grasshopper.Tas.csproj`; remove SAM_Excel/SAM_UI pre-build clones, `$preProjects`, `$uiRef`/ReferencePath from `build.yml` | SAM_Tas CI green without workaround; full VS MSBuild of SAM_Tas.sln | H1–H3 (TBD workflow progress/cancel/Alt+F4) — **not run**, no desktop-automation tooling | revert PR |
| **3** ✅ merged [#25](https://github.com/SAM-BIM/SAM_Tas/pull/25) | SAM_Tas `feature/tas-resource-deployment` → sow/2026-Q3 (after PR 2 merges) | 2 | New: `DeploySamTasResources` target added to `SAM.Core.Tas.csproj` (§6, full spec above — now live on `sow/2026-Q3`). Does not yet touch the six Grasshopper post-build targets. | SAM_Tas CI green; clean-profile test (§6) run and confirmed | clean-profile rebuild reproduces both resource trees from nothing — **done, see PR body** | revert PR |
| **4** ✅ merged [#23](https://github.com/SAM-BIM/SAM_Revit_UI/pull/23) | SAM_Revit_UI `chore/drop-prebuild` → sow/2026-Q3 | 1, 2 | Switch 2 sites (`Simulate.cs`, `Modify/RunWorkflow.cs`); remove `$preTasProjects`/ReferencePath; demote SAM_Excel back below SAM_Tas. Keep `SAM.Core.UI.WPF` reference (tree views still use it) | CI green (2025/2026/2027) — **done, 0 errors all three** | H9 (licence-dependent) — **not run** | revert PR |
| **5** ⏳ open [#11](https://github.com/SAM-BIM/SAM_Rhino_UI/pull/11) | SAM_Rhino_UI `chore/drop-prebuild` → sow/2026-Q3 | 2 | Remove `$preTasProjects`/ReferencePath; demote SAM_Excel. Zero source consumers found — CI-only diff. | CI green — **build verified locally, 0 errors** | none | revert PR |
| **6** — next | SAM_UI `refactor/progress-to-sam-windows` → sow/2026-Q3 | 1, 4 | Switch 5 sites (`SAM.Analytical.UI.WPF/Modify/RunWorkflow.cs` ×2, `.../Simulate.cs` ×2, `SAM.Analytical.UI/Modify/PrintRoomDataSheets.cs:61`); add `SAM.Core.Windows` reference to `SAM.Analytical.UI.WPF.csproj` + `SAM.Analytical.UI.csproj`; **only now** delete `ProgressWindow.xaml(.cs)`, `ProgressWindowHost.cs`, `Query/Duration.cs` from `SAM.Core.UI.WPF` (no forwarding wrapper — §4 confirms it's unnecessary) | SAM_UI CI green | H10 | revert merge commit |
| **7** | SAM_Tas_Grasshopper — **existing repo** (already created, already has `sow/2026-Q3`; do not delete/recreate/rename; untouched until this PR): (a) remote inspection + filter-repo history replacement; (b) population PR | **1, 2, 3** | (a)/(b) per the explicit 13-step sequence in §7a below | new repo CI green per §5 | build locally; open Rhino/GH: all 6 plugins load, H7-H8 | re-run the filter-repo replacement from the recorded pre-change SHA |
| **8** | SAM_Tas `chore/remove-grasshopper` → sow/2026-Q3 | 7 | Remove 6 GH projects from `SAM_Tas.sln`; delete `Grasshopper/` + `files/Grasshopper/`; trim CI comments; attempt `UseWindowsForms`/`ImportWindowsDesktopTargets` removal, CI-validated only (Decision #13) | SAM_Tas CI green (engine-only, PR3's resource target stays) | — | revert PR |
| **9** | SAM_Deploy `feature/tas-grasshopper-submodule` → sow/2026-Q3 | 7, 8 | **One atomic commit**: add SAM_Tas_Grasshopper submodule, add its `.sln` to `BuildAll_Release_net.csproj` after SAM_Tas, bump SAM_Tas gitlink past PR 8 | dispatch installer.yml; green | install output; GH loads all 6 plugins | revert pin commit |
| **10** | workspace-local (untracked `BuildAlls_v4.csproj`) | 9 | Insert `SAM_Tas_Grasshopper` after SAM_Tas, delete single-project pre-build, demote SAM_Excel back below it | full local `BuildAlls_v4` 0 errors | — | n/a |
| **11** | validation | 9, 10 | Installer run + H1–H12 matrix + clean-profile resource check + spot-check serialized `.gh` files | — | full matrix | — |

### 7a. Explicit new-repository import sequence (revised — SAM_Tas_Grasshopper already exists)

**Correction to the original plan:** `SAM-BIM/SAM_Tas_Grasshopper` has already been created and already has a `sow/2026-Q3` branch. It is **not** created fresh in PR 7 as the earlier draft assumed. It must **not** be deleted, recreated, or renamed, and must **not** be assumed empty. It stays untouched — read-only inspection only, if needed — until PR 7 itself. Steps 1-4 below (PRs 1-3 and the remaining consumer migrations) proceed exactly as before and do not touch this repository at all.

1. Complete and merge the SAM_Windows progress PR (PR 1). ✅ Done.
2. Complete and merge the SAM_Tas progress-consumer PR (PR 2). ✅ Done.
3. Complete and merge the SAM_Tas canonical resource-deployment PR (PR 3). ✅ Done.
4. Complete the remaining known progress-consumer migrations (PRs 4 ✅, 5 ⏳, 6 — SAM_Revit_UI, SAM_Rhino_UI, SAM_UI).
5. **At the start of PR 7, before touching anything:** inspect the existing remote `SAM_Tas_Grasshopper` repository — default branch, every remote branch and its SHA, current files and commit history, branch protection rules, repository visibility/permissions, and Actions configuration. Record every existing remote SHA before changing anything.
6. Determine whether the existing commits are placeholder/setup content only (vs. any real, valuable work) — this determination gates everything after it.
7. Run `git filter-repo` **only** in a disposable fresh clone of `SAM_Tas` (Decision #9) — the working SAM_Tas clone and its remote history are never touched, and this step does not touch `SAM_Tas_Grasshopper` at all yet.
8. Verify the filtered history and the identity baseline (§3's GUID/ComponentGuid/plugin-GUID table) **locally**, before pushing anything to the existing remote.
9. Replace the existing `SAM_Tas_Grasshopper` `sow/2026-Q3` branch with the verified filtered history: a normal push if fast-forward compatible; otherwise `--force-with-lease` anchored to the exact remote SHA recorded in step 5; **never an unguarded `--force`**. Placeholder history is authorized to be removed/replaced for this purpose (per explicit instruction) — but placeholder history must never be *merged into* the extracted history; it is replaced, not combined.
10. After `sow/2026-Q3` is verified, align `master` to the same filtered SHA: create it if absent, or replace placeholder-only history with `--force-with-lease` if necessary. If step 6 found anything beyond placeholder/setup content on `master` or any other branch, **stop and surface it** rather than overwriting it.
11. Preserve the repository's existing visibility, collaborators, and permissions untouched throughout.
12. Configure or restore branch protection only after the history import on `sow/2026-Q3` is verified — never before.
13. Continue with the normal independent-build branch and population PR (PR 7(b) in the table above) from the verified `sow/2026-Q3` — new `.sln`, dependency corrections per §5, trimmed post-build targets per §6, CI per §5's nine-project strategy.

Do not delete the `SAM_Tas_Grasshopper` repository itself at any point in this sequence.

---

## 8. Build-order sequence (§G)

**Current temporary order** (workaround live in exactly 4 places, confirmed): `SAM_Tas/.github/workflows/build.yml`, `SAM_Revit_UI/.github/workflows/build.yml`, `SAM_Rhino_UI/.github/workflows/build.yml` (each: SAM_Excel promoted above SAM_Tas + single-project `SAM.Core.UI.WPF` pre-build), and untracked `BuildAlls_v4.csproj` (lines 37, 54). SAM_UI's own workflow has no workaround (confirmed). **Now removed from SAM_Tas (PR2), SAM_Revit_UI (PR4), SAM_Rhino_UI (PR5) — only `BuildAlls_v4.csproj` (PR10) remains.**

**Original/canonical order** (tracked `BuildAll_Release_net.csproj`, unaffected by any workaround, currently what ships in the installer): `SAM → SAM_OCCT → SAM_Psychrometrics → SAM_Mollier → SAM_Systems → SAM_Windows → SAM_IFC → SAM_Acoustic → SAM_BHom → SAM_gbXML → SAM_GEM → SAM_LadybugTools → SAM_Solver → SAM_SolarCalculator → SAM_Validation → SAM_Tas → SAM_Excel → SAM_SQLite → SAM_OpenStudio → SAM_Origin → SAM_Multitasker → SAM_Revit(×3 years) → SAM_UI`. (Untracked `BuildAlls_v3.csproj` matches this original order too — it predates the workaround.)

**Final order (post-split, all PRs merged):** … `SAM_Validation → SAM_Tas (engine-only) → SAM_Tas_Grasshopper → SAM_Excel (original slot restored) → SAM_SQLite → … → SAM_UI → SAM_Rhino_UI`. SAM_Tas_Grasshopper's slot is valid because its full dependency set (SAM, SAM_Systems, SAM_Windows, SAM_gbXML, SAM_SolarCalculator, SAM_Tas) sits above it.

**SAM_Deploy stale-gitlink risk (Finding E-1, confirmed):** exists today because the SAM_Tas gitlink is pinned pre-PR#23; both the local `BuildAll_Release_net.csproj` build path and the `installer.yml` CI path share this exposure. **Exact atomic update required (PR 9):** a single commit that simultaneously (a) adds the SAM_Tas_Grasshopper submodule pinned at its PR-7 tip, (b) inserts its `.sln` into `BuildAll_Release_net.csproj` right after SAM_Tas, and (c) bumps the SAM_Tas gitlink past PR 8 (engine-only). Splitting these across separate commits creates one of two bad windows: bumping SAM_Tas past PR 8 alone drops all 6 Tas `.gha`s from the installer payload; wiring in the new repo before bumping SAM_Tas past PR 8 risks the two repos' Grasshopper outputs colliding in `%APPDATA%\SAM`. Atomicity in one commit eliminates both windows.

---

## 9. Rollback points

Every PR in §7 is independently revertible and SAM_Tas's own history is never rewritten (the filter-repo extraction runs against a disposable clone per Decision #9, §7a step 6). Specific notes:
- PR 1 is a copy-only addition — zero consumers exist yet, zero risk, trivial revert.
- PR 3 (resource deployment) is additive to `SAM.Core.Tas.csproj` only — revert removes the target; the six Grasshopper post-builds still have their original resource-xcopy lines at this point (not removed until PR 7), so reverting PR 3 alone never leaves resources undeployed.
- PRs 2, 4, 5, 10: plain reverts restore the exact workaround text (nothing destructive happens to it, it's just deleted, git revert brings it back verbatim).
- PR 6 is a merge commit per SAM_UI convention — revert the merge commit.
- The new repo (PR 7) is inert until PR 9 wires it into the installer's build order — safe to delete/re-extract any time before PR 9 merges, at zero cost.
- PR 8 (removing GH projects from SAM_Tas) is a plain forward commit — reverting restores the projects; nothing about the split rewrites SAM_Tas's committed history.
- PR 9 (SAM_Deploy atomic commit) — revert restores the pre-split state by re-pointing the SAM_Tas gitlink and dropping the submodule; disaster path is re-dispatching `installer.yml` on the current tip, which reproduces today's exact payload.

---

## 10. Blocking issues

**None.** Two items are logged as non-blocking, pre-existing conditions unrelated to the split (§2e — duplicate `41efcf7f-...` Grasshopper plugin GUID between `Core.Grasshopper.Tas` and `Analytical.Grasshopper.Tas`; §9 — the SAM_Windows local branch check, done, no conflict found).

Kimi's own "Open questions requiring Michal's decision" (§15 of the source assessment) are cross-checked against the Approved Decisions already given in this session's prompt:

| Kimi's Q | Status |
|---|---|
| Q1 (SAM.ghlink registers no Tas GHAs) | Resolved by Decision #12 — preserve current behaviour unless the installer hand test proves a discoverability gap; confirmed via `Build_Installer.iss` that `CreateSamGhLink` (the procedure that *would* register more plugins) is dead code and only the narrower `CreateStandaloneGhLink` runs, which never registered Tas GHAs — pre-existing, unaffected by the split either way. |
| Q2 (namespace) | Resolved by Decision #2 — `SAM.Core.Windows.WPF`. |
| Q3 (delete vs. Obsolete shim) | Resolved by Decision #5 + this report's §4 finding (no external consumers) — delete cleanly once all consumers migrate (PR 6), no shim. |
| Q4 (resource deployment owner) | Resolved by Decision #11 + this report's §6 design and its own PR (PR 3, merged). |
| Q5 (UseWindowsForms/ImportWindowsDesktopTargets removal) | Resolved by Decision #13 — attempt only with full VS MSBuild verification in PR 8. |
| Q6 (new repo `master` branch timing) | Resolved by Decision #10 — push `sow/2026-Q3` first, create `master` after verification (§7a steps 7-9). |
| Q7 (BuildAlls_v4.csproj permanent home) | Explicitly deferred by Decision #14 — not resolved in this pilot, and correctly so; PR 10 updates it in place, untracked, as scoped. |
| Q8 (WinForms remnants stay) | Resolved by Decision #6 — confirmed unchanged. |

No open question blocks progress.

---

*See `HANDOVER.md` for the current exact PR/branch state, what's done, the immediate next action, a Revit 2027 bug found (unrelated) mid-session, and carried-forward items from the previous handover.*
