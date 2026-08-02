# Handover — SAM_Tas / SAM_Tas_Grasshopper repo-split programme (2026-07-30, evening)

**Supersedes:** handover 2026-07-30 (earlier same day, which ended at "PR5 open"). **Repo root:**
`…\Documents\GitHub\SAM-BIM` (path differs per machine — everything below is repo-relative except
machine-specific tool paths, which are flagged). **Branch:** `sow/2026-Q3` everywhere unless noted.

Since that handover the programme went from "PR5 open" to **the entire split being executed**: PR6,
P7A (history import), P7B (independent build) and P7C (SAM_Tas engine-only) are all done. Only
PR8/P7C's review+merge and the SAM_Deploy/installer tail remain. The governing decisions (§0 of the
previous handover) all still stand and were followed — they are not repeated here; see
`PLAN_SAM_TAS_SPLIT.md` alongside this file for the full design record.

**If you only read one thing:** §1 (exact state) and §2 (exact next action).

---

## 1. Exact state as of 2026-07-30 evening (check this first — it will have moved)

| # | Repo | PR | Status |
|---|---|---|---|
| 1 | SAM_Windows | [#10](https://github.com/SAM-BIM/SAM_Windows/pull/10) | **merged** |
| 2 | SAM_Tas | [#24](https://github.com/SAM-BIM/SAM_Tas/pull/24) | **merged** |
| 3 | SAM_Tas | [#25](https://github.com/SAM-BIM/SAM_Tas/pull/25) | **merged** |
| 4 | SAM_Revit_UI | [#23](https://github.com/SAM-BIM/SAM_Revit_UI/pull/23) | **merged** |
| 5 | SAM_Rhino_UI | [#11](https://github.com/SAM-BIM/SAM_Rhino_UI/pull/11) | **merged** |
| 6 | SAM_UI | [#69](https://github.com/SAM-BIM/SAM_UI/pull/69) | **merged** |
| — | SAM_Tas | [#26](https://github.com/SAM-BIM/SAM_Tas/pull/26) | **merged** — unplanned bug fix, see §4a |
| 7 | SAM_Tas_Grasshopper | [#1](https://github.com/SAM-BIM/SAM_Tas_Grasshopper/pull/1) | **merged** (`ce4b6e5f`) |
| **8** | **SAM_Tas** | **[#27](https://github.com/SAM-BIM/SAM_Tas/pull/27)** | **OPEN — the only thing awaiting action** |
| 9 | SAM_Deploy | — | **not started** |
| 10 | BuildAlls_v4 (local, untracked) | — | **not started** |
| 11 | validation / hand tests | — | **not started** |

Key SHAs: `SAM_Tas` `sow/2026-Q3` = `957dc1d` (pre-PR#27). `SAM_Tas_Grasshopper` `sow/2026-Q3` =
`master` = `ce4b6e5f`; its P7A import commit (useful for diffing preserved content) = `3ed49399`.

---

## 2. Exact next action

~~Review and merge SAM_Tas#27, then PR9 / SAM_Deploy.~~ **Both are done.** SAM_Tas#27 is merged
(`36aa4eb8`) and the SAM_Deploy integration is complete — see §5.

**The remaining work is validation, not code**: the installer run, the release
acceptance matrix and the clean-profile resource check (old "PR11"). The matrix
itself was never actually defined anywhere until now — earlier handovers owed
"H1–H12 hand tests" without saying what they were. It is now defined as the
**SAM_Deploy release acceptance matrix v1** in `RELEASE_VALIDATION.md`
(H1–H12, all results PENDING at definition time). See §5 and §6.

---

## 3. What P7A / P7B / P7C actually did

**P7A — preserved-history import into SAM_Tas_Grasshopper.** `git filter-repo` in a *disposable* clone
of SAM_Tas @ `08b42216`, extracting only `Grasshopper/`, `files/Grasshopper/`, `.gitignore`,
`.gitattributes`, `COPYRIGHT_HEADER.txt`, `LICENSE`, `NOTICE`, `Directory.Build.props`. Result
`3ed49399`, 576 commits, verified byte-identical to source by git **tree-hash** comparison (a Merkle
proof covering every file at once — stronger than per-file checks). Pushed to both `sow/2026-Q3` and
`master` with `--force-with-lease` anchored to the recorded old SHA `d4e70249`, which was an unrenamed
`SAM_Template` placeholder copy — confirmed placeholder-only before replacing, and **never merged
into** the extracted history. Independently re-verified from a second fresh clone.

**P7B — make it independently buildable** ([SAM_Tas_Grasshopper#1](https://github.com/SAM-BIM/SAM_Tas_Grasshopper/pull/1),
3 commits): new `SAM_Tas_Grasshopper.sln` (6 projects, all GUIDs + config mappings byte-identical to
the originals); all 16 cross-repo engine `ProjectReference`s converted to `Reference`+HintPath under
`..\..\..\SAM_Tas\build\` — only the assemblies each project actually needed, not all nine; all 17
interop HintPaths repointed to `..\..\..\SAM_Tas\references_buildonly\` (that folder deliberately
*not* copied into the new repo); the two legacy `files\resources` xcopy lines removed from all six
post-build targets; new CI workflow plus the org-standard SPDX/cleanup workflows.

**P7C — make SAM_Tas engine-only** ([SAM_Tas#27](https://github.com/SAM-BIM/SAM_Tas/pull/27), 2
commits): removed the six GH project entries, their config mappings and nested entries, and the
now-empty "Grasshopper" solution folder from `SAM_Tas.sln` — **now exactly 12 real projects (9 engine
+ 3 benchmark)**, remaining GUIDs untouched; deleted 211 tracked files (`Grasshopper/`,
`files/Grasshopper/`); removed `UseWindowsForms`/`ImportWindowsDesktopTargets` from `SAM.Core.Tas` and
`SAM.Analytical.Tas` (§4c). SAM_Tas's CI needed **zero** changes — it already builds `SAM_Tas.sln`
unconditionally with no Grasshopper-specific comments, assertions or paths.

---

## 4. Bugs found and fixed along the way

**(a) `SAM.Analytical.Tas.TM59` / `.SAP` / `.TPD` were each missing their `Release|AnyCPU`
`OutputPath` block** — [SAM_Tas#26](https://github.com/SAM-BIM/SAM_Tas/pull/26), merged `957dc1d`.
Unlike their six siblings they declared only `Debug|AnyCPU`, so in a Release build their DLL landed in
the project's own `bin\Release\` instead of the shared `build\`. **This was invisible for a long
time** because the legacy Grasshopper adapters referenced them by `ProjectReference`, and MSBuild's
copy-local behaviour re-copies a referenced project's output next to the *referencing* project's
output — which is `build\`. So `build\` had the right DLL, just never because these three put it
there. It surfaced as a hard CI failure in SAM_Tas_Grasshopper#1 (whose HintPaths assume
`build\<Assembly>.dll` exists) and **would have silently broken SAM_Tas's own solution build once P7C
removed the adapters**. Fixed properly in SAM_Tas rather than worked around in CI.

**(b) `SAM_Tas_Grasshopper.sln` began with a blank line** — Codex finding; MSBuild wants the
`Microsoft Visual Studio Solution File, Format Version …` header on line 1 (MSB5010). Fixed in
`1b6ad1b`. Note the *original* `SAM_Tas.sln` legitimately starts with a UTF-8 BOM + CRLF, which some
editors render as a blank first line but isn't one — don't "fix" that.

**(c) Windows-desktop property experiment (P7C, second commit) — removal succeeded.** Inventory across
all 12 remaining projects found only `SAM.Core.Tas` and `SAM.Analytical.Tas` carrying both properties
(plus `SAM.Analytical.Tas.Benchmark.Cli` with `UseWindowsForms` alone — a benchmark project,
deliberately left alone). Neither engine project uses `System.Windows.Forms`; the only matches were
`using System.Drawing;` in three files. Removed from both and verified by isolated per-project rebuild
**and** a full 12-project solution rebuild — 0 errors, COM interop (`EmbedInteropTypes`, the `stdole`
`COMReference`) resolves fine without them. No revert or explanatory comment was needed.

---

## 5. SAM_Deploy — COMPLETE (do not action the old PR9/PR10 steps)

The TAS split and its SAM_Deploy integration are **done**. `SAM_Tas_Grasshopper` is a submodule, its
`.sln` builds immediately after `SAM_Tas`, and the `SAM_Tas` gitlink is `36aa4eb8` — PR#27's own merge
commit. The build orchestrators have since been renamed and consolidated; the tracked set is now:

| File | Role |
|---|---|
| `BuildAll_Debug.csproj` | Full-stack Debug orchestrator |
| `BuildAll_Release.csproj` | Full-stack Release/installer orchestrator (driven by `installer.yml`) |
| `BuildRevit_Debug.csproj` | Revit / Revit UI Debug helper (SAM_Revit + SAM_Revit_UI only) |
| `BuildAlls_v4.bat` / `.csproj` | Configurable local developer runner (`pull`/`fast`/`skip2027`/`nopause`) |

`BuildAlls_v4` is now **intentionally tracked**. This deliberately supersedes the earlier Decision #14
instruction that it remain untracked and local-only — that instruction is withdrawn, not overlooked.

The PR9 and PR10 actions previously described in this section are complete and **must not be followed
as future work**; they name files that no longer exist (`BuildAll_Release_net.csproj`,
`BuildAll_Debug_net.csproj`).

**PR11 is the exception — its testing obligations are still owed.** The build/integration half is
done, but the installer run, the release acceptance matrix and the clean-profile resource check
have **not** been performed. The matrix (previously the undefined phrase "H1–H12") is now defined
in `RELEASE_VALIDATION.md` — **SAM_Deploy release acceptance matrix v1** — and every row is still
PENDING: no acceptance test has been run across the entire programme, and the Rhino/Grasshopper
smoke test was waived rather than executed (H3–H7 now cover it).
Everything verified to date is *build* verification, not *feature* verification.

---

## 6. Owed / waived — be honest about these when reporting

- **The isolated Rhino/Grasshopper smoke test for SAM_Tas_Grasshopper#1 was explicitly WAIVED by
  Michal, not performed.** No desktop-automation tool was available in that session. Nothing has yet
  proven that Rhino loads the six *new* `.gha`s (as opposed to stale copies previously produced by
  SAM_Tas), that all six assemblies load without duplicate-assembly/component warnings, that both
  `.ghuser` UserObjects open, or that a representative TAS workflow solves. **This is the single
  biggest untested area in the programme.** If you have Rhino 8 available, this is high-value: record
  and rename aside the six existing `.gha`s + their DLLs under `%APPDATA%\SAM`, clear
  `SAM_Tas_Grasshopper\build` and all six projects' `bin`/`obj`, rebuild **only**
  `SAM_Tas_Grasshopper.sln` (sibling engine outputs already built), confirm the six new `.gha`s carry
  fresh timestamps and both `.ghuser` files deployed, then test in Rhino.
- **Release acceptance tests**: none run, across the entire programme. The acceptance matrix is
  now defined in `RELEASE_VALIDATION.md` (v1, H1–H12, all PENDING); it supersedes the undefined
  "H1–H12 hand tests" wording used in earlier handovers.
- Everything so far was verified by **full Visual Studio MSBuild only** — that is *build*
  verification, not *feature* verification. Say so when reporting status.

---

## 7. Technical notes / traps (carried forward + new)

- **Full VS MSBuild path used throughout:**
  `C:\Program Files\Microsoft Visual Studio\18\Community\MSBuild\Current\Bin\MSBuild.exe` — **this
  will differ on a new machine.** Re-find it with
  `vswhere.exe -latest -requires Microsoft.Component.MSBuild -find "MSBuild\**\Bin\MSBuild.exe"`.
- **In Git Bash, MSBuild switches need `MSYS2_ARG_CONV_EXCL="*"` and `-t:` style, not `/t:`** — MSYS
  path-mangles `/t:Restore` into a filename and MSBuild then fails with
  `MSB1008: Only one project can be specified`.
- **SAM_Tas has a doubled path segment.** Its engine projects live at
  `SAM_Tas/SAM_Tas/<Project>/<Project>.csproj` (an inner `SAM_Tas\` folder mirrors the `.sln`'s
  solution folder). In SAM_Tas_Grasshopper's CI, where SAM_Tas is cloned as a sibling, that becomes
  `SAM_Tas\SAM_Tas\SAM.Core.Tas\SAM.Core.Tas.csproj`. Planning docs describe these paths
  repo-root-relative and therefore look single-segment — **always verify on disk before writing a CI
  path for this repo.**
- **A sibling repo's local checkout can be stale even if you never touched it**, and its `build\*.dll`
  then predates already-merged source. This bit twice: a `SAM_Windows` clone missing PR#10's WPF
  classes caused a CS0234 in a consumer repo, and staleness also masked bug §4a. Before trusting a
  HintPath dependency, compare `git log -1 HEAD` vs `git log -1 origin/<branch>` **for that sibling** —
  and rebuild it if behind.
- **`git filter-repo` needs a real Python interpreter**, and **this machine's Group Policy blocks
  running installers** (`winget install` fails with `0x8007029c`; running the downloaded `.exe`
  directly fails with "blocked by group policy"). Michal installed Python manually; then
  `pip install git-filter-repo` worked normally, with the entry point in
  `…\AppData\Local\Python\pythoncore-3.14-64\Scripts\` (needs adding to PATH for the session). Don't
  burn time trying to route around the policy.
- **Windows MAX_PATH**: cloning SAM_Tas into a deep scratchpad path fails with "Filename too long".
  Use `git -c core.longpaths=true clone`, or `git init` + `git config core.longpaths true` + fetch.
- **`gh pr diff <n> -- <path>` is not supported** (`accepts at most 1 arg`). Dump the whole diff and
  grep it.
- **Reply to a Codex inline review comment** with
  `gh api repos/<org>/<repo>/pulls/<n>/comments/<comment_id>/replies -f body="…"` — note the
  `pulls/<n>/` segment; the shorter `pulls/comments/<id>/replies` form 404s.
- **Long PR bodies**: write them to a file and use `gh pr create --body-file`. Heredocs containing
  backticks and `$` inside a Bash tool call reliably produce "unexpected EOF" parse errors.

---

## 8. Settled — do not reopen

- Namespace is flat **`SAM.Core.Windows.WPF`** (the physical `Windows\` folder is unrelated).
- **No forwarding/Obsolete shims** for the deleted `SAM.Core.UI.WPF` progress classes — audited, zero
  external consumers.
- The **pre-existing duplicate Grasshopper plugin GUID** (`41efcf7f-…`, shared by
  `Core.Grasshopper.Tas` and `Analytical.Grasshopper.Tas`) is **not** to be fixed as part of this
  programme. It now exists only in SAM_Tas_Grasshopper.
- **Two of the six GH projects have no `GH_AssemblyInfo`/plugin GUID at all**
  (`Weather.Grasshopper.Tas`, `Core.Grasshopper.Tas.UKBR`) — pre-existing, not a defect.
- `SAM_Tas` is the **sole canonical deployer** of `files\resources\Analytical\Tas`, via
  `DeploySamTasResources` in `SAM.Core.Tas.csproj` (PR#25). Re-proved after P7C removed the legacy
  xcopy: cleared both `%APPDATA%\SAM\resources\Analytical\Tas` and
  `%USERPROFILE%\Documents\SAM\resources\Analytical\Tas`, built `SAM.Core.Tas.csproj` alone, got all
  15 files back byte-identical in both destinations, then confirmed a full-solution rebuild keeps them
  correct.
- Branch protection is configured on `SAM_Tas_Grasshopper` ("Protect Master v1", mirroring SAM_Tas:
  `~DEFAULT_BRANCH` only, 1 required approval, no force-push/deletion). **`sow/2026-Q3` is
  deliberately *not* protected** in these repos — that's the existing org pattern, not an oversight.
- Still binding from earlier handovers: **the title-bar X is not Cancel**; **coarse-stepped dialogs get
  no Cancel button**; **`AddParameters`/`GenerateSharedParametersFile` stay non-cancellable**;
  **unconfirmed dialog shutdown reports cancelled, not success**.

---

## 9. Carried forward, untouched — WinForms retirement (Task 3)

Unchanged and **not touched by PR6–PR8**: 3a (49 SAM_UI files still `using System.Windows.Forms` for
`DialogResult`/`MessageBox`/`IWin32Window`/file dialogs/`Screen` — the `IWin32Window` →
`System.Windows.Window` signature change is the bulk of the work; Grasshopper `ToolStrip*` menus
stay); 3b (remaining WinForms window consumers — `ComboBoxForm`, `ComboBoxControl`, `TextBoxForm`,
`InternalConditionForm`, `SpacesForm`, `ApertureForm`/`PanelForm`/`SpaceForm`,
`ConstructionLibraryForm`); 3c (delete SAM_Windows' legacy WinForms projects — blocked on 3b, and
confirm SAM_Finance has no external consumer first).

Two known bugs still flagged and unfixed: `SAM_Revit_UI/.../ParameterNames.cs:30` inverted condition
(needs Michal's decision — deliberately preserved bit-for-bit through the WinForms→WPF migration), and
`MultipleSelectionTreeViewControl.GetObjects<T>(bool selected)` not forwarding `selected`.

Also still open and unrelated to this programme: the **Revit 2027 Energy Analysis API** breakage
documented in the previous handover (`EnergyDataSettings.AnalysisType` throws;
`EnergyAnalysisDetailModelOptions` is `[Obsolete]` in 2027 and its `EnergyModelType` ignored). Michal
was mid-way through checking `energyDataSettings.CheckAnalysisType(AnalysisMode.RoomsOrSpaces)` in the
Immediate Window. Affects `SAM_Revit/.../ToSAM/AnalyticalModel.cs:44` and `.../TogbXML/gbXML.cs:84`.

---

*Generated by Michal Dengusiak and CodeClaude.*
