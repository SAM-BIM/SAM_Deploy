# Deploy: SAM-native optimisation (PR record)

Branch `feature/native-optimisation-deploy` -> `sow/2026-Q4`. Not merged. Status: implementation done, CI green on head `bec3cc3`; awaiting owner approval and real-install upgrade acceptance.

## Scope
Ship the PR6 native optimisation runtime (SAM_UI -> SAM_Tas `GenOptDocument.RunNative` -> SAM.Math) and retire the
Java GenOpt deployment artefacts. No optimisation, SAM.Math, `RunNative`, SAM_UI or Grasshopper change.

## Commits
1. `bc215d2` pins (explicit, no `--remote`): SAM `b081065e`, SAM_Tas `7f2043ac`, SAM_Tas_Grasshopper `a852a6ec`, SAM_UI `245045fc`.
2. `2b75e7c` installer + gate (below).

## Findings that drove the design
- Payload = the runner's `%APPDATA%\SAM`, filled flat by each project's post-build `copy *.dll` (last writer wins); Rhino
  package (SAM_Rhino_UI), `SAMdependencies` (SAM_Windows) and Revit year folders carry their own copy-local `SAM.Math.dll`.
- H12 audits only `build\SAM`; Rhino package and `SAMdependencies` were unaudited, and nothing required `SAM.Math.dll` or
  `SAM.Analytical.Tas.GenOpt.dll`. A developer machine showed four distinct `SAM.Math.dll` hashes across locations.
- `SAM.Analytical.Tas.GenOpt.dll` reaches `%APPDATA%\SAM` (beside `SAM Analytical.exe`) from the SAM_UI and GenOpt GH
  post-builds. The CI payload also carries identical copies in the Revit year folders and the Rhino package (copy-local side effect); the gate requires them to match too.
- `GenOpt.bat`/`config.txt` came from `SAM_Tas files\resources\Analytical\Tas\GenOpt` (removed in SAM_Tas `f4daf33`) into
  `%APPDATA%\SAM\resources\...` and the `Documents\SAM\resources\...` mirror. Inno never deletes files that left the payload.
  The native writer creates its own `config.txt` in run workspaces, so deletion is by exact path only.

## Decisions
- `[InstallDelete]` for exactly `{userappdata}\SAM\resources\Analytical\Tas\GenOpt\GenOpt.bat` and `config.txt`.
  Documents mirror left untouched (owner option A). Other GenOpt resources stay.
- New `.github/scripts/assert-native-optimisation-payload.ps1` (not a change to the H12 audit, whose scope lock stands):
  hashes the staged tree; every `SAM.Math.dll` must equal `SAM\build`, root `SAM.Analytical.Tas.GenOpt.dll` required and
  equal to `SAM_Tas\build`, no staged `GenOpt.bat`. Reports only; no overwrite that could hide a defect.

## Files changed
`SAM`, `SAM_Tas`, `SAM_Tas_Grasshopper`, `SAM_UI` (gitlinks); `SAM_Installer/Build_Installer.iss`;
`.github/workflows/installer.yml`; `.github/scripts/assert-native-optimisation-payload.ps1`; `RELEASE_VALIDATION.md` (H13);
this file.

## Validation
- Gate dry run on a synthetic stage: consistent tree exits 0; stale Rhino `SAM.Math.dll`, missing root GenOpt.dll and a
  staged `GenOpt.bat` each fail, exit 1. (Local; no Inno Setup installed, so the `.iss` compile is CI's.)
- Evidence head `bec3cc3` (`bec3cc3bac1fe2fc0d708b16f20de7ff8b0b8534`; later commits on this PR are docs-only record updates).
  Installer workflow run `37746250880` (workflow_dispatch, `publish_release=false`, version `v20261008.nativeopt`, no tag/release): success.
  Validate PR run `37746246411` on the same head: success.
- Gate "Assert native optimisation payload": passed.
  - `SAM.Math.dll` source `SAM\build` = `04EB9092DDAD`; all 6 staged copies equal: `SAM\`, `SAMdependencies\`,
    `SAM\Revit 2025\`, `Revit 2026\`, `Revit 2027\`, `SAM_Rhino_UI\1.0.0\`.
  - `SAM.Analytical.Tas.GenOpt.dll` source `SAM_Tas\build` = `5FA6E1FFF0CD`; 5 staged copies equal: `SAM\` (root, required),
    three Revit year folders, `SAM_Rhino_UI\1.0.0\`.
  - No `GenOpt.bat` staged.
- H12 (unchanged, `-Enforce`): "No H12 violations found" (1394 files scanned, 426 SAM-owned managed). Reporting/PDF gate also passed.
- Inno: "Successful compile (122.813 sec)", `SAM_Install_v20261008.nativeopt.exe` (CI test artifact only).
- Scope/quality: changed files are the 4 gitlinks, `Build_Installer.iss`, `installer.yml`, the new gate script, `RELEASE_VALIDATION.md`
  and this file; the other 20 gitlinks did not move. `git diff --check` clean, no control characters, workflow YAML parses.
  The `.iss` diff is only the `[InstallDelete]` section with the two exact paths. The gate never copies or overwrites.
- Historical failed attempts (kept, not hidden): Validate PR `37746095355` and installer push run `37746074349` on the earlier
  head failed because a Python edit had turned `\a`/`\b` in two workflow paths into BEL/backspace bytes (invalid YAML); fixed in
  the follow-up commit. Codex P1 on `55d7fd1` reported exactly that; it is fixed on `bec3cc3`.
- Not covered by CI: the `[InstallDelete]` runtime behaviour on an existing installation (owner acceptance below).

## Open / next
- Owner real-install upgrade acceptance (H13 manual list in `RELEASE_VALIDATION.md`) is the final sign-off.
- After approval: merge commit pinned to reviewed head, post-merge CI, then direct `PROJECT_PROGRESS.md` `[skip ci]` closeout.
