# SAM_Deploy

This is the managed release repository for SAM.

To find out more about SAM visit:
- https://github.com/SAM-BIM/SAM

## CI status (GitHub Actions)

[![Build & Release SAM-BIM Installer](https://github.com/SAM-BIM/SAM_Deploy/actions/workflows/installer.yml/badge.svg?branch=master)](https://github.com/SAM-BIM/SAM_Deploy/actions/workflows/installer.yml)
[![Latest Release](https://img.shields.io/github/v/release/SAM-BIM/SAM_Deploy?label=latest%20release)](https://github.com/SAM-BIM/SAM_Deploy/releases/latest)


## Installing

Download the latest release from:
- https://github.com/SAM-BIM/SAM_Deploy/releases/latest

(Assets are named like `SAM_Install_<version>.exe`.)

## Add new repository to deploy

```bash
git submodule add https://github.com/SAM-BIM/SAM_OpenStudio.git
```

## Debugging or building it yourself

Each repository is included as a submodule which means they only point to a set commit with detached head, see:
- https://git-scm.com/book/en/v2/Git-Tools-Submodules
- https://blog.tech-fellow.net/2019/05/09/effectively-work-with-git-submodules/

To clone with all submodules included do:

```bash
git clone --recurse-submodules https://github.com/SAM-BIM/SAM_Deploy.git
```

or, if you've already cloned it:

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

# 3) Push the tag (this is what triggers the installer build)
git push origin v20260107.1
```

Why `git push origin v20260107.1` (and not just `git push`)?

- `git push` pushes your current branch commits, **but it does not push new tags by default**.
- To push **all** local tags, use: `git push --tags`
- If you want to push commits *and* any annotated tags you created in the same go, you can also use: `git push --follow-tags`
