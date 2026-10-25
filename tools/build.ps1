# build.ps1 - one-click build for Project Monolith (started via build.bat in the repo root).
#
# 1. Fetches the SDK headers if they are missing (tools\fetch_sdk.ps1, checksum-verified).
# 2. Finds Visual Studio 2022 or the "Build Tools for Visual Studio" with the C++ workload.
# 3. Builds ProjectMonolith.sln (configuration v45, platform x64).
# 4. Checks that Server.dll, Client.dll and DXGI.dll were created in x64\v45\.
#
#   -DryRun : only check the SDK status and find MSBuild, print the build command, build nothing

param(
    [switch]$DryRun
)

$ErrorActionPreference = 'Stop'

$Root     = Split-Path -Parent $PSScriptRoot
$Solution = Join-Path $Root 'ProjectMonolith.sln'
$OutDir   = Join-Path $Root 'x64\v45'
$Outputs  = @('Server.dll', 'Client.dll', 'DXGI.dll')

function Fail([string]$msg) {
    Write-Host ""
    Write-Host "BUILD FAILED: $msg" -ForegroundColor Red
    exit 1
}

Write-Host "=== Project Monolith build ==="

# --- 1. SDK -------------------------------------------------------------------------------
$fetch = Join-Path $PSScriptRoot 'fetch_sdk.ps1'
if ($DryRun) {
    & $fetch -CheckOnly
} else {
    try { & $fetch -Quiet } catch { Fail ("SDK step: " + $_.Exception.Message) }
}

# --- 2. MSBuild ---------------------------------------------------------------------------
$vswhere = Join-Path ${env:ProgramFiles(x86)} 'Microsoft Visual Studio\Installer\vswhere.exe'
if (-not (Test-Path -LiteralPath $vswhere)) {
    Fail ("Visual Studio was not found. Install Visual Studio 2022 or the free " +
          "'Build Tools for Visual Studio 2022' with the workload 'Desktop development with C++' " +
          "(https://visualstudio.microsoft.com/downloads/), then run build.bat again.")
}
$msbuild = & $vswhere -latest -products * -version '[17.0,' `
    -requires Microsoft.Component.MSBuild Microsoft.VisualStudio.Component.VC.Tools.x86.x64 `
    -find 'MSBuild\**\Bin\MSBuild.exe' | Select-Object -First 1
if (-not $msbuild) {
    Fail ("No Visual Studio 2022 (or newer) installation with the C++ tools was found. Open the " +
          "Visual Studio Installer and add the workload 'Desktop development with C++'.")
}
Write-Host "MSBuild: $msbuild"

$buildArgs = @($Solution, '/m', '/nologo', '/verbosity:minimal', '/p:Configuration=v45', '/p:Platform=x64')
if ($DryRun) {
    Write-Host "Dry run - would run:"
    Write-Host ("  `"$msbuild`" " + ($buildArgs -join ' '))
    return
}

# --- 3. Build -----------------------------------------------------------------------------
Write-Host "Building (this takes a few minutes the first time) ..."
& $msbuild @buildArgs
if ($LASTEXITCODE -ne 0) {
    Fail ("MSBuild exited with code $LASTEXITCODE. Scroll up for the first error. If it mentions " +
          "toolset 'v143', add the 'MSVC v143' build tools in the Visual Studio Installer.")
}

# --- 4. Check outputs ---------------------------------------------------------------------
$missing = @()
foreach ($o in $Outputs) { if (-not (Test-Path -LiteralPath (Join-Path $OutDir $o))) { $missing += $o } }
if ($missing.Count -gt 0) { Fail ("Build finished, but these files are missing in ${OutDir}: " + ($missing -join ', ')) }

Write-Host ""
Write-Host "BUILD SUCCEEDED. Your files are in:" -ForegroundColor Green
Write-Host "  $OutDir"
foreach ($o in $Outputs) { Write-Host "    $o" }
Write-Host "Next step: copy them into the game folder, see HOW_TO_PLAY.md (section 2)."
