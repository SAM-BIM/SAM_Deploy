# Deploy: SAM-native optimisation (PR record)

Branch `feature/native-optimisation-deploy` -> `sow/2026-Q4`. Not merged. Status: implementation done, CI run pending.

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
  post-builds. Rhino and Revit do not reference it, so it is not needed there.
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
- Pending: installer.yml run on this branch (`publish_release=false`, no tag/release): gate output, H12, ISCC compile.

## Open / next
- Owner real-install upgrade acceptance (H13 manual list in `RELEASE_VALIDATION.md`) is the final sign-off.
- After approval: merge commit pinned to reviewed head, post-merge CI, then direct `PROJECT_PROGRESS.md` `[skip ci]` closeout.
