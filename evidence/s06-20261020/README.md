# S06 installed smoke candidate - evidence (2026-10-20)

Record: `DEPLOY_S06_SMOKE_CANDIDATE.md` (repository root). Paths are redacted: `<SAM-BIM>` is the local SAM-BIM workspace,
`<USERPROFILE>` the user profile. Machine-local, not committed: `C:\TasOut\s06` (full run folders with TBD/TSD/OSM/SQL/EPW,
the staged and installed candidate, full build logs, full .NET host traces).

- `tools/`: the S06 harness.
  - `build-candidate.ps1`: an isolated local replay of `installer.yml` at one SAM_Deploy commit. It uses a local clone, submodules taken from the sibling checkouts, a sandboxed APPDATA/USERPROFILE, and step bodies run verbatim through `extract-step.ps1`.
  - `install-candidate.ps1`: mirrors `Build_Installer.iss` `[Files]` into an isolated profile.
  - `run-s06-case.ps1`: one licensed real-UI case, `dev` or `installed`. It calls the S05/S01b drivers in `SAM_UI/documentation/evidence/s05-20261020/tools` and `../s01b-20261019/tools`.
  - `summarise-both.ps1`: S05's Both summary, taking the run root as a parameter.
- `candidate-build/`:
  - `steps.txt` (step outcomes);
  - `stamp.txt` (SAMVersion / InformationalVersion);
  - `submodule-status.txt` (the 24 pins built);
  - the outputs of the two new steps and of the three existing gates, plus the H12 report.
- `runs/<case>/`:
  - `environment.txt`, `driver.log`, the message box or diagnostics text;
  - the run manifests (`box.tas-run.json`, `openstudio-run.json`, `engine-comparison-run.json`), and `comparison.csv` for Both;
  - for the installed cases, `corehost-trace-summary.txt` (.NET host trace: apphost starts, app paths, dotnet root, and the count of references to developer folders).
- `runs/both-summary-*.txt`: dev, installed and S05 case 4 Both summaries.
- `runs/cmp-*.json`: persisted-result comparisons: S05 case 1 against dev Tas, dev Tas against installed Tas, S05 case 2 against dev OpenStudio, and dev OpenStudio against installed OpenStudio.
- `runs/real-appdata-unchanged.txt`: the user's real `%APPDATA%\SAM`, compared before and after the session.

Added 2026-10-20 (genuine installer acceptance, the S06 acceptance run):
- `tools/install-hosted-exe.ps1`: installs (or uninstalls) the unmodified hosted Inno Setup EXE silently into an isolated profile (`USERPROFILE`/`APPDATA`/`LOCALAPPDATA`/`TEMP` redirected). It refuses to run unless a native `SHGetFolderPath` probe resolves into that profile, and lists the owner's real folders before and after.
- `tools/run-s06-case.ps1 -Candidate installer`: the licensed cases from that installed profile. `tools/compare-persisted.ps1` is the persisted-result comparison used for `runs/cmp-*.json`.
- `installer-exe/`:
  - `hosted-run-227.txt`: stamp, producer staging and gate output, H12 and the artifact hash;
  - the install and uninstall console output and log excerpts;
  - `installed-manifest.tsv` (path, size and SHA-256 of every installed `{userappdata}\SAM` file).
- `runs/x1-installer-tas`, `runs/x2-installer-openstudio`, `runs/x3-installer-both-embedded`: the three licensed real-UI cases from the genuine install. For Both the folder also holds the producers' B1a documents, `comparison.md` and `comparison.csv`.
- `runs/cmp-*-x*.json`, `runs/both-summary-installer.txt`: the comparisons against S05 and the mirrored runs.
