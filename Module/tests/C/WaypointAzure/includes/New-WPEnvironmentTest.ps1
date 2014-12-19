. (join-Path (Split-Path -Parent $MyInvocation.MyCommand.Path) helpers.ps1)
. (join-Path (Split-Path -Parent $MyInvocation.MyCommand.Path) New-WPEnvironmentBase.ps1)


function New-WPEnvironmentTest {
    [CmdletBinding(SupportsShouldProcess=$true)]
    param (
        [Parameter(Position=1)]
        [string]$Name,

        [switch]$NoDomain
    )

    Write-VerboseBegin $MyInvocation.MyCommand
    Write-Output $NoDomain

    New-WPEnvironmentBase `
        -SubnetName 'Test' `
        -Name $Name `
        -NoDomain:$NoDomain.IsPresent

    Write-VerboseCompleted $MyInvocation.MyCommand
}
try {
    Export-ModuleMember -Function New-WPEnvironmentTest -ErrorAction Ignore
}
catch {
    # In case this is ran as a dot-script
}
