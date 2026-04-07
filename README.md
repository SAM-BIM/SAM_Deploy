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

## Releasing a new installer (tagging)

The **installer workflow runs automatically when you push a Git tag that starts with `v`** (for example `v20260107.1`), and it can also be run manually via GitHub Actions (“Run workflow”). 

Typical release flow:

```bash
# 1) Update submodules + commit on master/main
git pull
git submodule update --remote
git add .
git commit -m "Update submodules"
git push

# 2) Create a release tag (annotated tag recommended)

git tag -a v20260107.1 -m "Release v20260107.1"

# 3) Push the tag (this triggers the installer build + GitHub Release)

git push origin v20260107.1
```

Why `git push origin v20260107.1` (and not just `git push`)?

- `git push` pushes your current branch commits, **but it does not push new tags by default**.
- To push **all** local tags, use: `git push --tags`
- To push commits *and* annotated tags created locally in the same go, use: `git push --follow-tags`

## Running the workflow manually

You can also run the installer workflow manually:
1. Go to **Actions → Build & Release SAM-BIM Installer**
2. Click **Run workflow**
3. Optionally provide a version (e.g. `v20260107.1`). If you leave it blank, the workflow will generate one.