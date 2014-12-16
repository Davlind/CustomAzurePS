Get-ChildItem -Path $PSScriptRoot\includes\*.ps1 | Foreach-Object{ . $_.FullName }
