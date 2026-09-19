# Agent guidelines for Whisper Transcriber

## Read first
- Read `README.md` for supported behaviour, architecture and dependency caveats.
- Read `docs/RELEASING.md` for dependency, repository-policy or release work.
- Use `.github/workflows/ci.yml` and `ruff.toml` as the source of truth for automated checks. Read the relevant implementation before changing it.

## Privacy and offline operation
- Keep recordings and transcripts local. Never commit client audio, transcript contents, tokens or other private data, including files under `extracted/`. Use non-sensitive fixtures for testing.
- Preserve offline-by-default transcription. Set Hugging Face offline/cache configuration before model-library imports; use the existing `allow_network()` boundary for deliberate runtime downloads and restore offline state even on failure.
- Preserve the documented installer and deliberate download/update network behaviour. Do not introduce background network calls, telemetry or remote transcription.
- Do not log or expose `HF_TOKEN`. Preserve gated-model download support; do not set `HF_HUB_DISABLE_IMPLICIT_TOKEN`.

## Windows installation and dependencies
- Preserve CPython 3.12, CPU-only Windows support, per-user installation without administrator rights, and the double-click `install.cmd` / `whisper-ui.cmd` workflows.
- Keep `requirements.txt` fully pinned and installable with Windows wheels only. Validate dependency changes as a compatible set, especially torch, torchaudio, pyannote.audio and huggingface_hub.
- Keep the managed environment and model caches in their existing local, non-OneDrive locations. Do not modify unrelated Python installations or the user's environment as a side effect of verification.
- Preserve decoding through PyAV and the decoded waveform input to pyannote; do not add a requirement for separately installed FFmpeg DLLs. Preserve handling of pyannote's `speaker_diarization` result wrapper.

## Architecture and behaviour to preserve
- Keep `transcriber_core.py` independent of tkinter. Run model loading and transcription outside the UI thread; send worker events through the existing queue and update tkinter on its owning thread.
- Preserve queue locking and pause/stop coordination. Options are captured when Start queue is clicked and apply to that run.
- Preserve collision-safe filenames for new transcripts, partial transcript saving on Stop, remaining queued files after Stop, and continuation after an individual file fails. Preserve intentional speaker-renaming behaviour.
- Keep heavy models lazy-loaded, with only one Whisper model held in memory at a time. Preserve optional speaker identification and plain transcription without a Hugging Face token.

## Validation
- Scale validation to changed behaviour. For documentation-only changes, check accuracy, referenced paths and the diff; model execution is unnecessary.
- For Python changes, compile the tracked Python sources and run `ruff check .` using the project Python environment. In PowerShell, use `git ls-files '*.py' | ForEach-Object { python -m py_compile $_; if ($LASTEXITCODE -ne 0) { throw "Syntax check failed: $_" } }`; this avoids traversing private output folders or virtual environments.
- For installer changes, run the PowerShell parser and PSScriptAnalyzer with the same severity and exclusions as `.github/workflows/ci.yml`.
- For dependency changes, verify strict pins and run the CI-equivalent Windows Python 3.12 resolution check: `python -m pip install --dry-run --ignore-installed --only-binary=:all: --disable-pip-version-check -r requirements.txt`.
- For changes to transcription, diarisation, output handling or queue controls, verify the affected behaviour with a non-sensitive recording and relevant UI checks. Dependency upgrades also require the end-to-end speaker-identification check described in the README.
- `test_diarization.py` is a manual integration script: run `python test_diarization.py "path/to/non-sensitive-recording.wav"` with the installed dependencies and model access. It may download missing models and prints transcript text; it is not a conventional unit-test suite or proof that offline mode works.
- CI checks syntax, lint and dependency resolution; it does not execute the models. Before release, run a real recording through the app with speaker identification enabled using the pinned dependencies, inspect the transcript, and verify cached-model transcription offline.
- Report checks actually run and their results. If models, fixtures or Windows tooling are unavailable, state precisely what remains unverified; never equate green CI with a successful real-audio test.

## Documentation, review and delivery
- Update relevant README guidance and documentation alongside behaviour or setup changes; add changelog entries for release-worthy changes. Keep screenshots current when changed UI makes them misleading.
- Review substantive changes for concrete regressions, verify fixes, and inspect the final diff for unrelated edits, private material and generated noise. Scale review to risk; routine work does not require multiple agents or fixed reviewer counts.
- Follow the PR and linear-history policy documented in `docs/RELEASING.md`; do not import a merge-commit-only policy. Check actual repository settings before an authorised merge rather than assuming the setup guide proves enforcement.
- Keep PR validation evidence and remaining limitations clear. When PR delivery is in scope, inspect required CI results and resolve attributable failures before declaring the change ready.
- Release publication is separate from completing code. Follow `docs/RELEASING.md` and `.github/workflows/release.yml` only when release publication is authorised: pushing a `v*` tag or dispatching the Release workflow publishes a release.
- These instructions do not grant automatic authority to push, merge, publish, comment on or close issues. Use the scope and authority established by the user for the task.
