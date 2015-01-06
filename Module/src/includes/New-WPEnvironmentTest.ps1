. (join-Path (Split-Path -Parent $MyInvocation.MyCommand.Path) helpers.ps1)
. (join-Path (Split-Path -Parent $MyInvocation.MyCommand.Path) New-WPEnvironmentBase.ps1)


function New-WPEnvironmentTest {
    [CmdletBinding(SupportsShouldProcess=$true)]
    param (
        [switch]$NoDomain
    )

    Write-VerboseBegin $MyInvocation.MyCommand

    New-WPEnvironmentBase `
        -SubnetName 'Test' `
        -Name 'Test' `
        -NoDomain:$NoDomain.IsPresent

    Write-VerboseCompleted $MyInvocation.MyCommand
}

try {
    Export-ModuleMember -Function New-WPEnvironmentTest -ErrorAction Ignore
}
catch {
    # In case this is ran as a dot-script
}
