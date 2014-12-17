﻿<#
.SYNOPSIS
	Generates a manifest for the module
	and bundles all of the module source files
	and manifest into a distributable ZIP file.
#>

$ErrorActionPreference = "Stop"

$scriptPath = Split-Path -LiteralPath $(if ($PSVersionTable.PSVersion.Major -ge 3) { $PSCommandPath } else { & { $MyInvocation.ScriptName } })

$src = (Join-Path (Split-Path $scriptPath) 'src')
$dist = (Join-Path (Split-Path $scriptPath) 'dist')
if (Test-Path $dist) {
    Remove-Item $dist -Force -Recurse
}
New-Item $dist -ItemType Directory | Out-Null

# Copy the distributable files to the dist folder.
Copy-Item -Path $src `
          -Destination $dist\WaypointAzure `
          -Recurse

# Requires .NET 4.5
[Reflection.Assembly]::LoadWithPartialName("System.IO.Compression.FileSystem") | Out-Null

$zipFileName = Join-Path ([System.IO.Path]::GetDirectoryName($dist)) "WaypointAzure.zip"

# Overwrite the ZIP if it already already exists.
if (Test-Path $zipFileName) {
    Remove-Item $zipFileName -Force
}

$compressionLevel = [System.IO.Compression.CompressionLevel]::Optimal
$includeBaseDirectory = $false
[System.IO.Compression.ZipFile]::CreateFromDirectory("$dist\WaypointAzure", $zipFileName, $compressionLevel, $includeBaseDirectory)

Move-Item $zipFileName $dist -Force

Remove-Module WaypointAzure -ErrorAction SilentlyContinue
Import-Module WaypointAzure