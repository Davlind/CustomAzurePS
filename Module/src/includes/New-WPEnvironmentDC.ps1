. (join-Path (Split-Path -Parent $MyInvocation.MyCommand.Path) helpers.ps1)
. (join-Path (Split-Path -Parent $MyInvocation.MyCommand.Path) New-WPEnvironmentBase.ps1)


function New-WPEnvironmentDC {
    [CmdletBinding(SupportsShouldProcess=$true)]
    param (
    )

    Write-VerboseBegin $MyInvocation.MyCommand

    New-WPEnvironmentBase `
        -SubnetName 'Infrastructure' `
        -Name 'DC' `
        -InstanceSize 'Large' `
        -DscConfig 'DomainController' `
        -StaticIP '10.162.1.5' `
        -NoDomain:$true `

    Write-VerboseCompleted $MyInvocation.MyCommand
}

try {
    Export-ModuleMember -Function New-WPEnvironmentDC -ErrorAction Ignore
}
catch {
    # In case this is ran as a dot-script
}
