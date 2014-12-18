. (join-Path (Split-Path -Parent $MyInvocation.MyCommand.Path) helpers.ps1)
. (join-Path (Split-Path -Parent $MyInvocation.MyCommand.Path) New-WPEnvironmentBase.ps1)
. (join-Path (Split-Path -Parent $MyInvocation.MyCommand.Path) Get-WPDefaultServiceName.ps1)

function New-WPEnvironmentTest {
    [CmdletBinding(SupportsShouldProcess=$true)]
    param (
        [Parameter(Position=1)]
        [string]$Name
    )

    Write-VerboseBegin $MyInvocation.MyCommand

    if (!$Name)
    {
        $Name = Get-WPDefaultServiceName 'Test'
    }

    New-WPEnvironmentBase `
        -SubnetName 'Test' `
        -Name $Name

    Write-VerboseCompleted $MyInvocation.MyCommand
}
try {
    Export-ModuleMember -Function New-WPEnvironmentTest -ErrorAction Ignore
}
catch {
    #ignore...
}
