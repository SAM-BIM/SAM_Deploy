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

Added after review (2026-10-20):
- `tools/map-subsurface-refs.ps1` and `runs/os-subsurface-mapping.txt`. The four `runs/cmp-os-*.json` comparisons are kept as measured (`exactMatch: false`). This check shows that each of their 24 differences belongs to one of 4 run-generated OpenStudio subsurface names. Each result's reference is the GUID of the host Panel, not of the aperture: SAM_OpenStudio `Modify/AddResults.cs` attaches a subsurface result to the panel hosting it. The script checks, on the actual `Panel` objects of the input model `box-aperture.json` (`99ba2ab9`), that each of the 4 references is exactly one panel (a `WallExternal` with exactly one aperture). Through that reference each name maps 1:1 to one name on the other side, and the mapped values are exactly equal. It fails on a missing or ambiguous mapping; it was checked against a copy with two apertures on one panel and a copy with a panel GUID removed. The scope is these four comparisons only.
- `git diff --check` reports four whitespace findings, all in verbatim captures, which are left unmodified:
  - trailing whitespace on `installer-exe/hosted-run-227.txt` line 16 (an empty log line from the CI log) and on `runs/x1-installer-tas/message-box.txt` line 1 (the message box's empty title);
  - a trailing blank line at the end of `runs/x2-installer-openstudio/summary-dialog.txt` and of `runs/x3-installer-both-embedded/comparison.md`.

Added at the repin (2026-10-20):
- `repin/installer-run-228.txt`: installer run #228 at `b3b8e9e`, the repinned head. It records the stamp, the 24 checked-out pins, the producer Stage/Assert output, H12, and the artifact hashes.
- `repin/payload-227.tsv` and `repin/payload-228.tsv`: full inventories of the genuinely installed #227 and #228 payloads, made with `tools/payload-inventory.ps1`. Each row is path, length, SHA-256, FileVersion, ProductVersion and the stamp-normalised text hash.
- `repin/payload-equivalence-227-228.txt`: the output of `tools/compare-payloads.ps1`, with result PASS and 0 drift.
- `repin/install-uninstall-227.txt` and `repin/install-uninstall-228.txt`: the isolated install and uninstall consoles. They show the owner's real folders unchanged.
