# Handover — SAM_Tas / SAM_Tas_Grasshopper repo-split programme (2026-07-30)

**Supersedes:** handover 2026-07-28 (evening). **Repo root:** `…\Documents\GitHub\SAM-BIM` (path will
differ on a new machine — everything below is written repo-relative except where a machine-specific
tool path is unavoidable, flagged as such). **Branch:** `sow/2026-Q3` everywhere unless noted.

This session (2026-07-30) executed P0 (read-only investigation) through P5 of a multi-repo programme
that splits SAM_Tas's six Grasshopper adapter projects into a new `SAM_Tas_Grasshopper` repo, and
relocates the shared WPF progress-dialog implementation from `SAM_UI` into `SAM_Windows`. This
directly resolves §10 of the previous handover ("the leaf-tier build cycle, and what to do about
SAM_Windows") — the tactical four-pipeline workaround described there is now being dismantled PR by
PR, in the order it was analysed.

**If you only read one thing:** §1 (exact state) and §4 (exact next action).

---

## 0. Governing decisions (asked and answered — do not re-litigate)

These were given explicitly as approved architecture at the start of this session and every PR
executed against them:

1. **SAM_Windows** gets the canonical WPF progress dialog (`ProgressWindow`, `ProgressWindowHost`) added
   to the existing `SAM.Core.Windows` assembly, namespace **`SAM.Core.Windows.WPF`** (flat, no `.Windows`
   segment despite the physical `Windows\` folder — folder layout and namespace are independent here).
2. **SAM_Tas** stays the canonical owner of TAS engine code and `files\resources\Analytical\Tas`; no
   SAM_Windows/SAM_UI/Grasshopper/Rhino dependency once the split completes.
3. **SAM_Tas_Grasshopper** (new repo) gets exactly the six Grasshopper Tas adapter projects, depends on
   SAM_Tas + SAM_Windows, never SAM_UI.
4. **SAM_UI** may depend on SAM_Windows (new edge, explicitly sanctioned); remains after SAM_Tas in
   build order.
5. Migrate all known consumers before deleting `SAM.Core.UI.WPF`'s `ProgressWindow`/`ProgressWindowHost`/
   `Query.Duration`. **No forwarding/Obsolete shims** — a full-workspace audit (P0) found zero consumers
   outside the known source repos (SAM_Tas, SAM_Revit_UI, SAM_UI itself).
6. **Keep unchanged**: `SAM.Core.Windows.Forms.ProgressForm` (WinForms) and
   `SAM.Core.Windows.Modify.RunOnStaThread` — out of scope for this pilot.
7. `SAM_Tas_Grasshopper` repo work only begins after all progress-consumer migration PRs merge.
8. The new repo must be created completely empty — **but it turned out to already exist** (see §4).
9. History extraction via `git filter-repo`, **only** in a disposable fresh clone of SAM_Tas. The
   working SAM_Tas clone and its remote history are never touched.
10. Push `sow/2026-Q3` to the new repo first; create `master` at the same SHA only after verification.
11. SAM_Tas becomes the **single, idempotent** resource-deployment mechanism for
    `files\resources\Analytical\Tas`; remove the six Grasshopper projects' duplicate xcopy — but only
    once the SAM_Tas mechanism is merged and verified (sequenced as its own PR, PR3).
12. Preserve current `SAM.ghlink` installer behaviour unless a hand test proves Tas plugins aren't
    discoverable (P0 found this is a pre-existing gap, unrelated to the split — see §8).
13. Only attempt removing `UseWindowsForms`/`ImportWindowsDesktopTargets` from engine projects with
    full-VS-MSBuild verification; keep with a comment if COM resolution regresses.
14. `BuildAlls_v4.csproj` (untracked, workspace root) gets updated in place for each workflow change;
    do **not** invent a new tracked home for it in this pilot.

---

## 1. Exact state as of 2026-07-30 (check this first — it will have moved)

| # | Repo | Branch | PR | Status |
|---|---|---|---|---|
| 1 | SAM_Windows | `feature/wpf-progress-host` | [#10](https://github.com/SAM-BIM/SAM_Windows/pull/10) | **merged** |
| 2 | SAM_Tas | `feature/gh-progress-to-sam-windows` | [#24](https://github.com/SAM-BIM/SAM_Tas/pull/24) | **merged** |
| 3 | SAM_Tas | `feature/tas-resource-deployment` | [#25](https://github.com/SAM-BIM/SAM_Tas/pull/25) | **merged** |
| 4 | SAM_Revit_UI | `chore/drop-prebuild` | [#23](https://github.com/SAM-BIM/SAM_Revit_UI/pull/23) | **merged** |
| 5 | SAM_Rhino_UI | `chore/drop-prebuild` | [#11](https://github.com/SAM-BIM/SAM_Rhino_UI/pull/11) | **open — check this first** |

**If #11 is not yet merged, that is the only blocker.** Everything else in this table is done. No PR
after this table has been started. Local branches for PRs 1-4 can be pruned; PR 5's local branch
(`chore/drop-prebuild` in `SAM_Rhino_UI`) should stay until it merges.

**Not run this session, still owed:** every interactive Grasshopper/Rhino/Revit hand test (H1-H12 in
the original plan). No desktop-automation tool was available to drive Rhino/Grasshopper UI; Revit
requires a licence not present on this machine. All five PRs above were verified by **full Visual
Studio MSBuild only** (0 errors each, every stated configuration) — this is *build* verification, not
*feature* verification. Say so if reporting these as "done."

---

## 2. What PRs 1-5 actually did (so you don't have to re-derive it)

**PR1 (SAM_Windows#10):** Copied `ProgressWindow.xaml(.cs)` and `ProgressWindowHost.cs` from
`SAM_UI/WPF/SAM.Core.UI.WPF/` into `SAM_Windows/SAM_Windows/SAM.Core.Windows/{Windows,Classes}/`,
namespace → `SAM.Core.Windows.WPF`, internal `Query.Duration` calls fully qualified to
`SAM.Core.Windows.Query.Duration` (the existing twin). SAM_UI's originals untouched. Public API
diff vs. the original: namespace + assembly only — every constructor/property/behavioural contract
byte-identical (verified with a diff, in the PR body).

**PR2 (SAM_Tas#24):** Switched `SAM.Analytical.Grasshopper.Tas`'s two `ProgressWindowHost` call sites
(`Modify/RunWorkflow.cs`, `Component/SAMAnalyticalWorkflowTBD.cs`) to `SAM.Core.Windows.WPF`, removed
the `SAM.Core.UI.WPF` HintPath reference from the csproj, removed the CI pre-build workaround from
`build.yml` (SAM_Excel promotion, `$preProjects`, `$uiRef` ReferencePath escaping).

**PR3 (SAM_Tas#25):** Added `DeploySamTasResources` — a guarded, idempotent MSBuild target — to
`SAM_Tas/SAM.Core.Tas/SAM.Core.Tas.csproj`. Deploys `files\resources\Analytical\Tas` to
`%APPDATA%\SAM\resources\...` and `Documents\SAM\resources\...`. Guards: `DesignTimeBuild != 'true'`,
`Exists()` on source, `$(MSBuildThisFileDirectory)`-relative (not `$(SolutionDir)` — resolves even when
built as a bare project list, not via the `.sln`), `SkipUnchangedFiles="true"`. **The six Grasshopper
projects' own resource xcopy was deliberately left in place** — removal is deferred to the
`SAM_Tas_Grasshopper` population PR (§4, step 7 below). Read the target itself in
`SAM_Tas/SAM_Tas/SAM.Core.Tas/SAM.Core.Tas.csproj` — it's short and the PR body has the full
verification methodology if you need to reproduce it (clean-profile isolated test, then full-solution
coexistence test).

**PR4 (SAM_Revit_UI#23):** Same consumer migration for the two Revit sites (`Modify/RunWorkflow.cs`,
`IExternalCommands/Simulate.cs`), using the `SAM.Core.Windows` reference already present in the csproj
(no csproj change needed). Reverted exactly commit `6161b69` ("ci: pre-build SAM.Core.UI.WPF before
SAM_Tas") in `build.yml` — confirmed by diffing that commit's parent that the `SAM_UI\build`
ReferencePath setup **predates** the workaround and is legitimate/untouched (tree-view/WPF-controls
still use `SAM.Core.UI.WPF` elsewhere in this repo — that reference is deliberately kept, though a grep
found no *current* live `.cs`/`.xaml` consumer of it; that's out of scope to clean up here). Built
Release2025/2026/2027 all green.

**PR5 (SAM_Rhino_UI#11):** Same CI-only revert, exact inverse of commit `952e7e3`. **Zero source
consumers found** in this repo (grepped for `ProgressWindowHost`/`SAM.Core.UI.WPF.*` — nothing) — this
repo's only exposure was the CI workaround, now gone. Single-file diff.

---

## 3. A Revit 2027 build/permission gotcha hit this session

The very first branch-creation attempt (`git checkout -b` in SAM_Windows) was blocked by this
session's auto-mode permission classifier — a plain read-only `git status` even got blocked once. If
you hit this on a fresh machine/session: it's a permission-mode setting, not a code problem. The user
adjusted their Claude Code permission settings and it resolved. Don't try to work around a denial with
a different tool (e.g. PowerShell instead of Bash) beyond one reasonable attempt — surface it and ask.

---

## 4. Exact next action

**Check SAM_Rhino_UI PR #11.** Once merged:

### PR6 — SAM_UI: migrate remaining consumers, delete the duplicate implementation

Repo: `SAM_UI`. Prereq: PR1 + PR4 merged (both done). Branch suggestion: `refactor/progress-to-sam-windows`.

- Switch 5 sites to `SAM.Core.Windows.WPF.ProgressWindowHost`/`ProgressWindow`:
  `SAM.Analytical.UI.WPF/Modify/RunWorkflow.cs` (×2), `.../Simulate.cs` (×2),
  `SAM.Analytical.UI/Modify/PrintRoomDataSheets.cs:61`. **Re-verify these paths/line numbers from a
  fresh grep before editing** — every prior PR in this programme found stored line numbers had drifted;
  don't trust this document's numbers either.
- Add a `SAM.Core.Windows` HintPath reference to `SAM.Analytical.UI.WPF.csproj` and
  `SAM.Analytical.UI.csproj`.
- **Only now** delete `ProgressWindow.xaml(.cs)`, `ProgressWindowHost.cs`, `Query/Duration.cs` from
  `SAM.Core.UI.WPF` — this is safe per Decision #5/§0 (no forwarding shim, no external consumers found).
  This is the one PR in the sequence that removes source, not just CI config.
- SAM_UI merges as a **merge commit** (per its convention, noted in the old handover — auto-merge is
  disabled there).
- Build verification: full VS MSBuild. Check SAM_UI's own `build.yml` for its supported
  configuration(s) fresh — don't assume Release-only or a year matrix without checking.

### PR7 — SAM_Tas_Grasshopper: the repo already exists, do NOT recreate it

**Read this carefully before touching anything.** `SAM-BIM/SAM_Tas_Grasshopper` was already created
before this session and already has a `sow/2026-Q3` branch. It must stay untouched (read-only
inspection only) until this step. Do not create a second repo, do not delete/rename it, do not assume
it's empty.

Exact 13-step sequence (this is corrected from an earlier draft that wrongly assumed the repo needed
creating — trust this version):

1. Confirm PR1, PR2 (SAM_Tas#24), PR3 (SAM_Tas#25) are merged (they are, as of this handover).
2. Confirm PR6 (SAM_UI) is merged.
3. **Inspect the existing remote `SAM_Tas_Grasshopper`**: default branch, every remote branch + SHA,
   current files/commits, branch protection, visibility/permissions, Actions config. Record every
   existing remote SHA before changing anything (`gh api repos/SAM-BIM/SAM_Tas_Grasshopper/...` or
   `git ls-remote`).
4. Determine whether existing commits are placeholder/setup content only, or contain real work. If
   real work is found, **stop and surface it** — do not overwrite.
5. Run `git filter-repo` **only** in a disposable fresh clone of SAM_Tas (never the working clone):
   `--path Grasshopper/ --path files/Grasshopper/ --path .gitignore --path .gitattributes --path
   COPYRIGHT_HEADER.txt --path LICENSE --path NOTICE`.
6. Verify the filtered history and the identity baseline (below) **locally**, before pushing anything.
7. Replace the existing `sow/2026-Q3` branch: normal push if fast-forward compatible; otherwise
   `--force-with-lease` anchored to the exact SHA recorded in step 3. **Never an unguarded `--force`.**
   Placeholder history may be replaced (explicitly authorized) but never *merged into* the extracted
   history.
8. Align `master` to the same filtered SHA (create if absent; `--force-with-lease` if replacing
   placeholder-only history; **stop** if step 4 found real work there).
9. Preserve existing repo visibility/collaborators/permissions throughout.
10. Configure/restore branch protection only after the `sow/2026-Q3` import is verified.
11. Create the normal independent-build branch from the verified `sow/2026-Q3` for the population PR.
12. In that PR: new `SAM_Tas_Grasshopper.sln` (project GUIDs preserved byte-identical), engine
    `ProjectReference`s → HintPath to `..\..\SAM_Tas\build\*.dll`, interop refs repointed, CI per the
    strategy below, add `Directory.Build.props`/spdx/cleanup/build workflows.
    **Trim the six Grasshopper projects' resource-xcopy lines here** — now safe, PR3 is merged.
13. Merge the population PR through the new repo's normal PR process.

**CI strategy for the new repo (do not build `SAM_Tas.sln`, in whole or "subset" form):**
Clean runner → clone+build in order `SAM → SAM_Psychrometrics → SAM_Mollier → SAM_Systems →
SAM_Windows → SAM_gbXML → SAM_SolarCalculator` → build **only these nine SAM_Tas engine `.csproj`
files directly** (not via `.sln`), in this dependency order:
`SAM.Core.Tas → SAM.Geometry.Tas → SAM.Core.Tas.UKBR → SAM.Weather.Tas → SAM.Analytical.Tas →
SAM.Analytical.Tas.TM59 → SAM.Analytical.Tas.SAP → SAM.Analytical.Tas.TPD →
SAM.Analytical.Tas.GenOpt` → then build all six projects in `SAM_Tas_Grasshopper.sln`. Do **not**
build the six legacy GH projects still physically present in SAM_Tas at this point, the three
benchmark projects, or `SAM_Validation` (only the benchmark tier needs it). Assert no `SAM_UI`
directory/DLL anywhere in the job.

**Identity baseline to verify (machine-checkable, from this session's P0 audit — should still hold):**
18 projects total in `SAM_Tas.sln` (9 engine, 3 benchmark, 6 Grasshopper — a Kimi-report predecessor
document said "15", that was an arithmetic error, ignore it). 104 total `ComponentGuid` overrides
across the six moved projects (3+67+2+2+16+14). Only 4 of the 6 have a `GH_AssemblyInfo`/plugin GUID
(`Weather.Grasshopper.Tas` and `Core.Grasshopper.Tas.UKBR` don't — that's pre-existing, not a defect).
Note: `Core.Grasshopper.Tas` and `Analytical.Grasshopper.Tas` share an identical plugin GUID
(`41efcf7f-7fc8-4ed2-85d0-d116b6c30e8b`) — pre-existing, unrelated to the split, don't try to fix it
here.

### PR8 — SAM_Tas: remove the Grasshopper projects

Remove the 6 GH projects from `SAM_Tas.sln`, delete `Grasshopper/` + `files/Grasshopper/`, trim CI
comments. Attempt removing `UseWindowsForms`/`ImportWindowsDesktopTargets` from engine projects —
CI-validated only (Decision #13); keep with a comment if COM resolution regresses.

### PR9 — SAM_Deploy: one atomic commit

Add the `SAM_Tas_Grasshopper` submodule (pinned at its PR7 tip), add its `.sln` to
`BuildAll_Release_net.csproj` immediately after SAM_Tas, bump the SAM_Tas gitlink past PR8 —
**all in one commit**. Splitting this creates either a window where the installer loses all 6 Tas
`.gha`s, or a window where SAM_Tas and the new repo's outputs collide. `SAM_Deploy` = this workspace
root's own repo (origin `SAM-BIM/SAM_Deploy.git`); it currently pins SAM_Tas pre-PR#23 — check
`git ls-tree HEAD -- SAM_Tas` fresh, don't assume the SHA in this document is current.

### PR10 — local, untracked `BuildAlls_v4.csproj`

Insert `SAM_Tas_Grasshopper` after SAM_Tas, delete the single-project pre-build line and its comment
block, demote SAM_Excel back below it. Per Decision #14, do not give this file a new tracked home.

### PR11 — validation

Installer run + the full H1-H12 hand-test matrix (original plan has the table; all of it is genuinely
owed, none of it has been run) + clean-profile resource check.

---

## 5. Known bug found this session, flagged, **NOT fixed** — Revit 2027 Energy Analysis API

Unrelated to the split programme; discovered while the user hand-tested SAM_Revit_UI#23 in Revit 2027.

**Symptom:** `Autodesk.Revit.Exceptions.ArgumentException: The analysis type does not fall within an
appropriate range. Parameter name: analysisType`, thrown from
`Autodesk.Revit.DB.Analysis.EnergyDataSettings.set_AnalysisType`, at
`SAM_Revit/SAM_Revit/SAM.Analytical.Revit/Convert/ToSAM/AnalyticalModel.cs:44`
(`energyDataSettings.AnalysisType = AnalysisMode.BuildingElements;`), reached via
`SAM.Analytical.Revit.UI.ModifyInternalCondition.Execute`.

**Root cause, confirmed by reading `references/Revit 2027/RevitAPI.dll` metadata directly** (a small
`System.Reflection.Metadata`-based console tool was built ad hoc in the session scratchpad to do
this — it did not persist; the technique is worth repeating if `revitapidocs.com` is incomplete for a
brand-new Revit year, which it currently is for 2027):

- The `AnalysisMode` enum itself is **byte-identical** across 2025/2026/2027
  (`BuildingElements=0`, `ConceptualMassesAndBuildingElements=2`, `RoomsOrSpaces=3`) — this is **not**
  a removed enum member, so it compiles fine and only fails at runtime.
- **`EnergyAnalysisDetailModelOptions` — the entire class — is `[Obsolete]` in 2027.** Its
  `EnergyModelType` property is ignored; the obsolete message states verbatim: *"The Mode set in
  Energy Settings will be used. The mode can be set with
  `EnergyDataSettings.GetEnergyDataSettings(revitDoc).AnalysisType`."*
- `EnergyAnalysisDetailModel.Create(doc, options)` is `[Obsolete]` → new `Create(doc)` overload exists.
- `GetAnalyticalShadingSurfaces()` is `[Obsolete]` → use
  `GetAnalyticalSurfaces().Where(s => s.Type == gbXMLSurfaceType.Shade)`.
- `EnergyDataSettings.GetFromDocument(doc)` is `[Obsolete]` → `GetEnergyDataSettings(doc)`.
- `ExportDefaults` and ~12 other `EnergyDataSettings` properties are `[Obsolete]` in 2027.

**Why it throws:** the code asks for `EnergyModelType.SpatialElement` (rooms/spaces) via the now-ignored
options object, but separately sets `AnalysisType = AnalysisMode.BuildingElements` — 2025/2026 tolerated
that mismatch; 2027 validates `AnalysisType` at the setter and rejects it. The user's live debugger
Autos pane showed the document's actual current value as `ConceptualMassesAndBuildingElements`.
`AnalysisMode.RoomsOrSpaces` is the *likely* correct 2027 value given the code wants spatial elements,
but this is **unconfirmed** — the user was mid-way through checking
`energyDataSettings.CheckAnalysisType(AnalysisMode.RoomsOrSpaces)` in the Immediate Window (this method
returns `bool` and is the API's own validity check) when the session moved to writing this handover.
**Check that first**, before writing any fix.

**Affects two call sites**, both need the same fix: `SAM_Revit/SAM_Revit/SAM.Analytical.Revit/Convert/
ToSAM/AnalyticalModel.cs:44` and `Convert/TogbXML/gbXML.cs:84` (the gbXML export path — this one hasn't
even been exercised/crashed yet in this session, but has the identical line and will hit the same
wall).

**Scope decision needed from Michal, not made yet:** a minimal `#if Revit2027` swap to the correct
`AnalysisMode` value at both sites (matches the existing `#if Revit2025 || Revit2026` pattern already
in `gbXML.cs` for the separate `GBXMLExportOptions.ExportEnergyModelType` removal — see old handover
§0/the "Known 2027 API removal" note, still accurate), vs. a proper migration off the whole deprecated
Detailed-Energy-Analysis-Model path (`GetEnergyDataSettings`, `Create(doc)`, the shading-surface LINQ
rewrite) before it's actually *removed* in a future Revit version. This is entirely outside the split
programme — treat as a separate PR/investigation.

---

## 6. Carried forward, untouched this session — WinForms retirement (Task 3)

From the previous handover, still open, not touched by anything in this session:

**3a — SAM_UI leftovers (not started).** 49 files still `using System.Windows.Forms` for
`DialogResult`/`MessageBox`/`IWin32Window`/file dialogs/`Screen` — **not** windows (those are done).
`ToolStripMenuItem`/`ToolStripSeparator`/`ToolStripDropDown` are Grasshopper menus and **stay** —
don't migrate those. The `IWin32Window` → `System.Windows.Window` signature change is the bulk of this
work.

**3b — remaining WinForms window consumers (not started):**

| Form | Consumed by | WPF replacement |
|---|---|---|
| `ComboBoxForm` | `CreateFloorPlans.cs`, `CreateSheets.cs`, `ImportExportAnalyticalModel.cs` | `ComboBoxWindow<T>` — exists |
| `ComboBoxControl` | `Forms/CopyTagsForm.Designer.cs` | host form is itself WinForms — port it |
| `TextBoxForm` | `AddWallTags.cs` | `TextBoxWindow` |
| `InternalConditionForm` | `ModifyInternalCondition.cs` | `InternalConditionWindow` |
| `SpacesForm` | `ModifyInternalCondition.cs` | `SpacesWindow` |
| `ApertureForm`, `PanelForm`, `SpaceForm` | `SAM_Rhino_UI/.../Commands/Properties.cs` | `ApertureWindow`, `PanelWindow`, `SpaceWindow` |
| `ConstructionLibraryForm` | `SAM_Rhino_UI/.../Commands/SetConstruction.cs` | `ConstructionLibraryWindow` |

**3c — delete SAM_Windows' legacy WinForms projects.** Blocked on 3b. Confirm SAM_Finance (not in this
workspace) has no external consumer before deleting the 39 forms with no in-workspace consumer.
**Note:** the split programme in this handover does NOT do this — it *adds* `SAM.Core.Windows.WPF` to
`SAM_Windows` alongside the existing legacy WinForms projects, it doesn't touch or remove them. 3c
remains a fully separate, still-blocked task.

**Two known bugs, still flagged, still not fixed:**
1. `SAM_Revit_UI/.../ParameterNames.cs:30` — inverted condition
   (`unselectedParameterGroups.Contains(...)` pre-ticks a group that should be un-ticked). Needs
   Michal's decision before fixing — deliberately preserved bit-for-bit through the WinForms→WPF
   migration so that PR stayed behaviour-preserving.
2. `MultipleSelectionTreeViewControl.GetObjects<T>(bool selected)` doesn't forward `selected` — a
   one-line fix, still unmerged, still latent (becomes reachable as more of 3b lands).

---

## 7. Technical notes / traps learned this session

- **Full VS MSBuild path used throughout:**
  `C:\Program Files\Microsoft Visual Studio\18\Community\MSBuild\Current\Bin\MSBuild.exe` (found via
  `vswhere.exe -latest -requires Microsoft.Component.MSBuild -find "MSBuild\**\Bin\MSBuild.exe"` — this
  will differ on a new machine, re-run vswhere, don't hardcode the path).
- **`ReferencePath` with multiple paths needs `%3B` escaping** in a `/p:` value — a raw `;` is read as
  an item separator by MSBuild and fails `MSB1006`. Already noted in the old handover; reconfirmed
  repeatedly this session across all four repos' `build.yml`.
- **Verifying a canonical/idempotent MSBuild target requires isolating it from the ambient build.**
  For PR3's resource-deployment target: rename the destination folders aside, build the *single
  project* directly (not the `.sln`, which would exercise the still-present duplicate mechanism too),
  confirm the isolated target reproduces the output, *then* build the full solution to check
  coexistence. Building the solution first would prove nothing about ownership.
- **When online API docs for a brand-new product year are incomplete** (true for Revit 2027 as of this
  session), read the actual shipped reference assembly's metadata directly — `System.Reflection.Metadata`
  + `System.Reflection.PortableExecutable` (`PEReader` → `GetMetadataReader()` → walk
  `TypeDefinitions`/`GetFields`/`GetProperties`/`GetMethods`, decode `ObsoleteAttribute` blobs for the
  actual deprecation messages). PowerShell 5.1's `Add-Type` cannot load `System.Reflection.Metadata` —
  build a throwaway `net8.0` console app instead (`dotnet build` + run the exe). This found the exact,
  correctly-worded Revit 2027 deprecation messages when web search could not.
- **Before editing any CI workflow in this programme, find the exact commit that introduced the thing
  you're removing** (`git log --follow -- .github/workflows/build.yml`, then `git show <sha>`), and
  diff its parent to check whether adjacent-looking setup (e.g. a `ReferencePath` entry) predates the
  change you're reverting or was introduced by it. Every one of PR2/4/5 had at least one piece of
  adjacent infrastructure that looked like part of the workaround but wasn't — removing it would have
  broken a legitimate, unrelated dependency.
- **Branch/status commands can be blocked by the session's auto-mode permission classifier** even when
  read-only (§3). Not a bug in your approach — ask the user to adjust permissions rather than routing
  around it with a different tool.
- Repo-relative paths have an extra nesting level in several repos that's easy to get wrong:
  `SAM_Tas/SAM_Tas/SAM.Core.Tas/...` (not `SAM_Tas/SAM.Core.Tas/...`), similarly `SAM_UI/WPF/...` and
  `SAM_UI/SAM_UI/...`, `SAM_Revit_UI/SAM_Revit_UI/...`. Always confirm with `find`/`Glob` before writing
  an MSBuild-relative path (`$(MSBuildThisFileDirectory)..\..\...`) — PR3's design got this wrong in an
  early draft and was corrected against the actual on-disk layout before committing.

---

## 8. Settled — do not reopen

- **Namespace is flat `SAM.Core.Windows.WPF`**, not `SAM.Core.Windows.WPF.Windows` — explicitly
  corrected by the user during planning; the physical `Windows\` folder name is unrelated to the
  namespace (confirmed the *original* SAM_UI code had the same folder/namespace mismatch).
- **No forwarding/Obsolete shims** for the deleted `SAM.Core.UI.WPF` progress classes (PR6) — audited,
  zero external consumers.
- **SAM_Tas_Grasshopper already exists as a repo** — do not create a new one, do not assume empty, do
  not touch it before PR7.
- **The six legacy Grasshopper resource-copy operations stay until PR7's population step** — PR3
  deliberately does not remove them; removing early would leave a window with no resource deployment
  at all if PR3 and PR7 ever landed out of order.
- Everything under §0 above (the original 14 approved decisions) — all still binding.
- From the previous handover, still binding: **the title-bar X is not Cancel** (dismisses the dialog,
  the run continues and reports success); **coarse-stepped dialogs get no Cancel button**;
  **`AddParameters`/`GenerateSharedParametersFile` stay non-cancellable** (write outside Revit's
  transaction); **unconfirmed dialog shutdown reports cancelled, not success** (implemented everywhere
  progress dialogs exist).

---

*Generated by Michal Dengusiak and Claude Sonnet 5.*
