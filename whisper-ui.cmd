@echo off
rem Launch the local Whisper transcriber UI without a console window.
rem Uses the venv's pythonw.exe directly - no activation, no admin needed.
if not exist "%LOCALAPPDATA%\whisper\.venv\Scripts\pythonw.exe" (
    echo The transcriber is not installed yet.
    echo Double-click install.cmd in this folder first.
    pause
    exit /b 1
)
start "" "%LOCALAPPDATA%\whisper\.venv\Scripts\pythonw.exe" "%~dp0transcribe_ui.py"
