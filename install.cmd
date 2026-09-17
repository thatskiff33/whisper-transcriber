@echo off
rem One-click setup for the local Whisper transcriber. No admin rights needed.
rem Runs install.ps1 with a process-scoped execution policy bypass (allowed
rem on locked-down machines because nothing system-wide changes).
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0install.ps1" %*
echo.
pause
