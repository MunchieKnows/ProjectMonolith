@echo off
REM Project Monolith - one-click build.
REM Fetches the SDK headers if needed, then builds Server.dll, Client.dll and DXGI.dll into x64\v45\.
REM Requires Visual Studio 2022 or "Build Tools for Visual Studio 2022" with "Desktop development with C++".
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0tools\build.ps1" %*
echo.
pause
