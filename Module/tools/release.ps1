<#
.SYNOPSIS
	Generates a manifest for the module
	and bundles all of the module source files
	and manifest into a distributable ZIP file.
#>

$ErrorActionPreference = "Stop"

$testResult = . "$PSScriptRoot\runtests.ps1"

if ($testResult.TotalCount -gt $testResult.PassedCount) {

    Write-Error "Aborting build due to $($testResult.TotalCount - $testResult.PassedCount) test(s) not passing"
    return
}


$scriptPath = Split-Path -LiteralPath $(if ($PSVersionTable.PSVersion.Major -ge 3) { $PSCommandPath } else { & { $MyInvocation.ScriptName } })

$src = (Join-Path (Split-Path $scriptPath) 'src')
$dist = (Join-Path (Split-Path $scriptPath) 'dist')
if (Test-Path $dist) {
    Write-Output 'Deleting old version'
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

Write-Output 'Creating zip-file'
[System.IO.Compression.ZipFile]::CreateFromDirectory("$dist\WaypointAzure", $zipFileName, $compressionLevel, $includeBaseDirectory)

Move-Item $zipFileName $dist -Force

$modulePaths = [Environment]::GetEnvironmentVariable("PSModulePath", "User")
$modulePath = (Split-String -input $modulePaths -separator ';')[0]

Write-Output "Copying module to user module path"
if (Test-Path $modulePath)
{
    Remove-Item $modulePath\WaypointAzure -Force -Recurse
}

Copy-Item -Path $dist\WaypointAzure `
          -Destination $modulePath\WaypointAzure `
          -Recurse

Write-Output "Importing module"
Remove-Module WaypointAzure -ErrorAction SilentlyContinue
Import-Module WaypointAzure