@echo off
REM Project Monolith - fetches the SDK headers for the build (details: tools\fetch_sdk.ps1).
REM build.bat runs this automatically; you only need it if you build in Visual Studio yourself.
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0tools\fetch_sdk.ps1" %*
echo.
pause
