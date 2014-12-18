$result = Invoke-Pester `
    -Path (Resolve-Path "$PSScriptRoot\..\tests") `
    -CodeCoverage (Resolve-Path "$PSScriptRoot\..\src\includes\*") `
    -PassThru

return $result