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
        -SubnetName 'Test'

    Write-VerboseCompleted $MyInvocation.MyCommand
}

Export-ModuleMember -Function New-WPEnvironmentTest