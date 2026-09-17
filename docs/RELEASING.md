# Releasing and repository settings

This page covers the repository housekeeping that is not code: protecting `main`, cutting a release and the decision not to publish a package.

## Protecting main

These settings cannot be applied from a script that only has push access, so set them once in the GitHub UI.

1. Open https://github.com/thatskiff33/whisper-transcriber/settings/rules and click New ruleset, then New branch ruleset.
2. Name it `Protect main`. Set Enforcement status to Active.
3. Under Target branches, click Add target and choose Include default branch.
4. Tick these rules:
   - Restrict deletions
   - Block force pushes
   - Require linear history
   - Require a pull request before merging. Leave Required approvals at 0 (a solo maintainer cannot approve their own pull request), tick Dismiss stale pull request approvals when new commits are pushed, and tick Require conversation resolution before merging.
   - Require status checks to pass. Add `Syntax check` (the job in `.github/workflows/ci.yml`). It only appears in the picker after the CI workflow has run once, so add it after the first pull request goes green.
5. Leave Bypass list empty. Admins are then held to the same rules, which is the point.
6. Click Create.

From then on, all changes reach `main` through a pull request, and nobody can force-push or delete the branch.

## Cutting a release

Releases are cut by the Release workflow in `.github/workflows/release.yml`.

1. Add a `## vX.Y.Z` section to `CHANGELOG.md` on a branch and merge it to `main`.
2. Open https://github.com/thatskiff33/whisper-transcriber/actions/workflows/release.yml and click Run workflow.
3. Enter the version without the leading v, for example `0.1.0`, and run it against `main`.

The workflow tags the current `main` commit, builds the release notes from the changelog section, and publishes the release. GitHub attaches the source zip and tarball automatically. If the changelog section is missing the workflow fails before anything is tagged.

Pushing a `vX.Y.Z` tag by hand also triggers the workflow and publishes the release for that tag.

## Why there is no PyPI package or installer executable

The decision for v0.1.0 is to ship source only. Reasons:

- The audience is non-technical staff on locked-down Windows laptops. They double-click `install.cmd`. A `pip install` step would be a regression for them.
- `requirements.txt` is a full 120-package freeze including torch, CTranslate2 and pyannote.audio, chosen because specific combinations break on CPU-only Windows without FFmpeg. A PyPI package would need loose version ranges or a hard pin on torch, and neither works well in someone else's environment.
- The installer does things a package cannot: finds or installs Python per user, sets `HF_TOKEN`, downloads gated models, creates a Start Menu shortcut, warns about OneDrive paths.
- A PyInstaller or MSIX executable would be several GB with torch and models bundled, would need code signing to pass Intune and antivirus cleanly, and would still need the Hugging Face token step.

Revisit this if people outside the office start using it. The natural first step would be a small `pyproject.toml` with a console entry point so developers can `pip install -e .`, without changing the double-click path for everyone else.
