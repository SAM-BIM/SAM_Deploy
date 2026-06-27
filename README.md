# SAM_Deploy

This is the managed release repository for **SAM** (submodule-based “all-in-one” build + installer packaging).


To find out more about SAM visit:
- https://github.com/SAM-BIM/SAM

## CI status (GitHub Actions)

[![Build & Release SAM-BIM Installer](https://github.com/SAM-BIM/SAM_Deploy/actions/workflows/installer.yml/badge.svg?branch=master)](https://github.com/SAM-BIM/SAM_Deploy/actions/workflows/installer.yml)
[![Latest Release](https://img.shields.io/github/v/release/SAM-BIM/SAM_Deploy?label=latest%20release)](https://github.com/SAM-BIM/SAM_Deploy/releases/latest)

Note:
- the badge above shows the `master` workflow status
- branch and PR testing should be checked from the **Actions** tab or from PR checks

## Installing

Download the latest release from:
- https://github.com/SAM-BIM/SAM_Deploy/releases/latest

Assets are named like:
- `SAM_Install_<version>.exe`

## What the installer sets up

The installer stages SAM so it can be used from:
- **Grasshopper in Rhino**
- **Grasshopper inside Revit via Rhino.Inside.Revit**
- **Rhino** (Rhino plugin `.rhp`)

Primary install locations:
- `%APPDATA%\SAM\` (core payload)
- `%APPDATA%\McNeel\Rhinoceros\packages\8.0\SAM\1.0.0\` 8.0(Rhino package payload for 7.0, 8.0 and 9.0 )
- `%APPDATA%\Grasshopper\Libraries*` and `*.ghlink` (Grasshopper discovery)

## Versioning & stamping

There are **two independent version identifiers** every installer carries — they describe different things:

| Identifier | Where it appears | Driven by | Example |
|---|---|---|---|
| **Installer filename + Release tag** | `SAM_Install_<x>.exe` filename and the GitHub Releases page | `Version` input you type when dispatching the workflow (or the tag you push) | `SAM_Install_v2026.Q2.exe`, tag `v2026.Q2` |
| **DLL FileVersion** | Right-click any installed `SAM.*.dll` → Properties → Details. Also reported in crash dumps and Revit add-in load logs. | Auto-derived from the branch + SAM_Deploy CI run number: `YYYY.Q.<run>.0` | `2026.2.161.0` |

The two intentionally don't have to match. The filename is your **customer-facing label** (`BSA2026.Q2`, `customer-acme-demo`, `v2026.Q2-hotfix1` — anything that makes sense). The DLL FileVersion is the **build identity** and always traces back to a single SAM_Deploy workflow run: a customer at `2026.2.161.0` → `gh run view 161 --repo SAM-BIM/SAM_Deploy` → the exact submodule SHAs that shipped.

On branches matching `sow/yyyy-Qx` the SAMVersion is derived directly from the branch name; on `master`/feature branches it falls back to the current UTC year + quarter. Local developer builds (anyone running msbuild without SAM_Deploy/CI) get the default `1.0.0.0` — the stamping mechanism only kicks in when CI sets `SAMVersion` in the environment.

## Add a new repository to deploy

```bash
git submodule add https://github.com/SAM-BIM/SAM_OpenStudio.git
```

## Debugging / building locally

This repository uses **git submodules** (detached HEAD). Useful references:
- https://git-scm.com/book/en/v2/Git-Tools-Submodules
- https://blog.tech-fellow.net/2019/05/09/effectively-work-with-git-submodules/

Clone with all submodules:

```bash
git clone --recurse-submodules https://github.com/SAM-BIM/SAM_Deploy.git
```

or, if already cloned:

```bash
git submodule update --init --recursive
```

## Updating the submodules to latest commits

First enable full commit history for git diff (only needs to be done once):

```bash
git config --global diff.submodule log
git config --global status.submoduleSummary true
```

Then each time you want update:

```bash
git pull
git submodule update --remote
git add .
git commit
git push
```

**About `git submodule update --remote`:** this command follows the `branch = ...` setting per submodule in `.gitmodules` — NOT the parent repo's current branch. Every SAM-BIM submodule in this repo is configured with `branch = sow/2026-Q3`, so `--remote` correctly pulls each submodule's `sow/2026-Q3` HEAD. Without those entries the command would silently pull each submodule's default branch (`master` = last-shipped state) instead.

**Quarterly transitions:** when a new sow branch is cut (e.g. `sow/2026-Q3`), the `branch =` entries in `.gitmodules` must be updated to match. One-liner that does all 22 submodules at once:

```bash
for sm in $(git config --file .gitmodules --get-regexp 'submodule\..*\.url' | grep 'SAM-BIM' | awk '{print $1}' | sed 's|submodule\.\(.*\)\.url|\1|'); do
  git config --file .gitmodules "submodule.$sm.branch" "sow/2026-Q3"
done
git submodule sync
git submodule update --remote --recursive
git add .gitmodules <all-submodule-paths>
git commit -m "chore: track sow/2026-Q3 in submodules"
```

## Why the sow branch makes testing easier

Because `sow/2026-Q3`'s `.gitmodules` says `branch = sow/2026-Q3`, you can re-bump and
test-build the in-progress quarter without touching `master` (the last-shipped,
reproducible release):

```bash
git submodule update --remote          # pulls the latest sow/2026-Q3 tip of all 23 repos
git commit -am "bump"
git push origin sow/2026-Q3
# then trigger a test build from the sow branch:
gh workflow run installer.yml --ref sow/2026-Q3
```

Doing these iterative bumps on `sow/2026-Q3` keeps `master` pristine — rebuilding
`master` (or its release tag) always reproduces exactly what was shipped. When the
quarter is done, fast-forward `sow/2026-Q3` into `master` and tag the release.

## Releasing a new installer (tagging)

The **installer workflow runs automatically when you push a Git tag that starts with `v`** (for example `v2026.Q2.1`), and it can also be run manually via GitHub Actions ("Run workflow").

Typical release flow:

```bash
# 1) Update submodules + commit on master/main
git pull
git submodule update --remote
git add .
git commit -m "Update submodules"
git push

# 2) Create a release tag (annotated tag recommended)

git tag -a v2026.Q2.1 -m "Release v2026.Q2.1"

# 3) Push the tag (this triggers the installer build + GitHub Release)

git push origin v2026.Q2.1
```

Why `git push origin v2026.Q2.1` (and not just `git push`)?

- `git push` pushes your current branch commits, **but it does not push new tags by default**.
- To push **all** local tags, use: `git push --tags`
- To push commits *and* annotated tags created locally in the same go, use: `git push --follow-tags`

## Running the workflow manually

You can also run the installer workflow manually — useful for **test builds, customer-specific snapshots, and pre-release verification**:

1. Go to **Actions → Build & Release SAM-BIM Installer**
2. Pick the **branch** to build from (typically `sow/2026-Q3`; can also be `master` or a feature branch)
3. Click **Run workflow**
4. Fill in the inputs:
   - **Version** (optional): the label baked into the installer filename and (if released) the GitHub Release tag. Allowed characters: letters, digits, `.`, `_`, `-`. Anything else is replaced with `-`. Examples:
     - `v2026.Q2` — standard quarterly release naming
     - `BSA2026.Q2`, `customer-acme-demo` — customer-specific build labels
     - `v2026.Q2-hotfix-tas`, `BSA2026.Q2-rev2` — hotfix / revision markers
     - `2026-05-20-test` — date-based snapshot
     - *(blank)* — auto-generates `v<YYYYMMDD>.<run>` from today's date
   - **Create GitHub Release on manual run** (checkbox):
     - **Tick** for an official release — publishes to the Releases page where customers can download
     - **Leave unticked** for internal/test/verification builds — the installer is still built and uploaded as a workflow artifact you can download from the run page, but no Release is created

The **DLLs inside the installer** are stamped independently as `YYYY.Q.<run>.0` regardless of the Version input — see [Versioning & stamping](#versioning--stamping) above. So a custom installer named `SAM_Install_BSA2026.Q2.exe` still has DLLs reporting e.g. `2026.2.161.0`, and customer crash dumps will match a specific SAM_Deploy workflow run.