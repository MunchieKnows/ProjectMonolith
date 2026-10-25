# fetch_sdk.ps1 - fetches the generated SDK headers needed for the build.
#
# This repository does NOT ship the SDK. The headers (Dumper-7 output, derived from the game)
# are already public in the base project SyST3MDeV/ProjectLegacy. This script downloads exactly
# the state this project is based on (fixed commit), extracts ONLY the needed files into Server\
# and Client\ and verifies them by checksum. build.bat calls it automatically.
#
# Usage: double-click fetch_sdk.bat in the repo root (or run this script directly).
#   -Target <folder> : other target directory (default: repo root)
#   -Force           : download again even if a matching SDK is already present
#   -CheckOnly       : only report whether a matching SDK is present, download nothing
#   -Quiet           : no "next step" hint at the end (used by build.ps1)
#   -Generate        : maintainers only - prints the checksums of an existing SDK

param(
    [string]$Target = (Split-Path -Parent $PSScriptRoot),
    [switch]$Force,
    [switch]$CheckOnly,
    [switch]$Quiet,
    [switch]$Generate
)

$ErrorActionPreference = 'Stop'

$Commit = '52a3e0626f6207ff90ab51d94b597a31a56a38d1'
$Url    = "https://codeload.github.com/SyST3MDeV/ProjectLegacy/zip/$Commit"

# What each side (Server/Client) needs. Folders end with '/'.
$Items  = @('SDKv45/', 'SDKv45.hpp', 'PropertyFixup.hpp', 'NameCollisions.inl', 'UnrealContainers.h')
$Sides  = @('Server', 'Client')

# Expected checksums (see Get-SdkDigest). Recompute with -Generate.
$Expected = @{
    'Server' = @{ Files = 3414; Digest = '402beb3e10ac1c37f45d4e2de771c3f20dd7e15f551739f450f7adeb352bfa3c' }
    'Client' = @{ Files = 3414; Digest = 'e61eb84b78a188e87c4c5a156084d673c344eaf68622ec463bd243e7c80f85c8' }
}

# Checksum over all SDK files of one side. Line endings are normalised first (CR removed), so
# CRLF/LF differences between the Git export and the file system do not matter.
function Get-SdkDigest([string]$sideDir) {
    if (-not (Test-Path -LiteralPath $sideDir -PathType Container)) { return $null }
    $sideDir = (Resolve-Path -LiteralPath $sideDir).Path.TrimEnd('\')
    $sha   = [System.Security.Cryptography.SHA256]::Create()
    $files = New-Object System.Collections.Generic.List[string]
    foreach ($item in $Items) {
        $p = Join-Path $sideDir $item.TrimEnd('/')
        if ($item.EndsWith('/')) {
            if (-not (Test-Path -LiteralPath $p -PathType Container)) { return $null }
            foreach ($fi in Get-ChildItem -LiteralPath $p -File -Recurse) {
                $rel = $fi.FullName.Substring($sideDir.Length + 1).Replace('\', '/')
                $files.Add($rel)
            }
        } else {
            if (-not (Test-Path -LiteralPath $p -PathType Leaf)) { return $null }
            $files.Add($item)
        }
    }
    $sorted = $files.ToArray()
    [Array]::Sort($sorted, [StringComparer]::Ordinal)
    $sb = New-Object System.Text.StringBuilder
    $latin1 = [Text.Encoding]::GetEncoding(28591)   # 1 byte = 1 char, lossless
    foreach ($rel in $sorted) {
        $bytes = [System.IO.File]::ReadAllBytes((Join-Path $sideDir $rel))
        $norm  = $latin1.GetBytes($latin1.GetString($bytes).Replace("`r", ''))
        $h = [BitConverter]::ToString($sha.ComputeHash($norm)).Replace('-', '').ToLowerInvariant()
        [void]$sb.Append("$h  $rel`n")
    }
    $all = [BitConverter]::ToString($sha.ComputeHash([Text.Encoding]::UTF8.GetBytes($sb.ToString()))).Replace('-', '').ToLowerInvariant()
    return @{ Files = $sorted.Length; Digest = $all }
}

function Test-Side([string]$side) {
    $d = Get-SdkDigest (Join-Path $Target $side)
    if ($null -eq $d) { return $false }
    return ($d.Files -eq $Expected[$side].Files -and $d.Digest -eq $Expected[$side].Digest)
}

function Test-AllSides {
    foreach ($side in $Sides) { if (-not (Test-Side $side)) { return $false } }
    return $true
}

if ($Generate) {
    foreach ($side in $Sides) {
        $d = Get-SdkDigest (Join-Path $Target $side)
        if ($null -eq $d) { Write-Host "$side : SDK incomplete"; continue }
        Write-Host ("    '{0}' = @{{ Files = {1}; Digest = '{2}' }}" -f $side, $d.Files, $d.Digest)
    }
    return
}

Write-Host "SDK headers (ProjectLegacy @ $($Commit.Substring(0,7)))"

if ($CheckOnly) {
    if (Test-AllSides) { Write-Host "SDK present and verified." }
    else { Write-Host "SDK missing or not matching - it would be downloaded." }
    return
}

if (-not $Force -and (Test-AllSides)) {
    Write-Host "SDK already present and verified - nothing to do."
    return
}

$tmp = Join-Path ([System.IO.Path]::GetTempPath()) ("sdk_fetch_" + [Guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Path $tmp | Out-Null
$zipPath = Join-Path $tmp 'projectlegacy.zip'

try {
    Write-Host "Downloading archive (a few dozen MB, may take a moment) ..."
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    $old = $ProgressPreference; $ProgressPreference = 'SilentlyContinue'
    try { Invoke-WebRequest -Uri $Url -OutFile $zipPath -UseBasicParsing }
    finally { $ProgressPreference = $old }

    Add-Type -AssemblyName System.IO.Compression.FileSystem
    $zip = [System.IO.Compression.ZipFile]::OpenRead($zipPath)
    try {
        $count = 0
        foreach ($side in $Sides) {
            # Remove old content so that stray files cannot affect the check
            $sdkDir = Join-Path $Target "$side\SDKv45"
            if (Test-Path -LiteralPath $sdkDir) { Remove-Item -LiteralPath $sdkDir -Recurse -Force }
        }
        foreach ($entry in $zip.Entries) {
            if ($entry.FullName.EndsWith('/')) { continue }
            $slash = $entry.FullName.IndexOf('/')
            if ($slash -lt 0) { continue }
            $rel = $entry.FullName.Substring($slash + 1)          # without "ProjectLegacy-<sha>/"
            $parts = $rel.Split('/', 2)
            if ($parts.Length -ne 2 -or $Sides -notcontains $parts[0]) { continue }
            $sub = $parts[1]
            $wanted = $false
            foreach ($item in $Items) {
                if ($item.EndsWith('/')) { if ($sub.StartsWith($item)) { $wanted = $true } }
                elseif ($sub -eq $item) { $wanted = $true }
            }
            if (-not $wanted) { continue }
            $dest = Join-Path $Target ($rel -replace '/', '\')
            $destDir = Split-Path -Parent $dest
            if (-not (Test-Path -LiteralPath $destDir)) { New-Item -ItemType Directory -Path $destDir -Force | Out-Null }
            [System.IO.Compression.ZipFileExtensions]::ExtractToFile($entry, $dest, $true)
            $count++
        }
        Write-Host "$count files extracted."
    } finally { $zip.Dispose() }

    $bad = @()
    foreach ($side in $Sides) { if (-not (Test-Side $side)) { $bad += $side } }
    if ($bad.Count -gt 0) {
        throw ("Checksum mismatch for: " + ($bad -join ', ') +
               ". The downloaded SDK does not match the expected state - do not build, please report an issue.")
    }
    Write-Host "SDK verified and ready."
    if (-not $Quiet) { Write-Host "Next step: run build.bat (or open ProjectMonolith.sln in Visual Studio and build)." }
}
finally {
    if (Test-Path -LiteralPath $tmp) { Remove-Item -LiteralPath $tmp -Recurse -Force }
}
