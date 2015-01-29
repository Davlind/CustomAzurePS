. (join-Path (Split-Path -Parent $MyInvocation.MyCommand.Path) helpers.ps1)
. (join-Path (Split-Path -Parent $MyInvocation.MyCommand.Path) New-WPEnvironmentBase.ps1)


function New-WPEnvironmentSolR {
    [CmdletBinding(SupportsShouldProcess=$true)]
    param (
    )

    Write-VerboseBegin $MyInvocation.MyCommand

    $credentials = Get-Credential -Message 'Specify a username and password to be used as administrator on the machine'

    $Configuration = @(
        @{
            Type = 'Cloud Service'
            Name = 'SolR'
            Location = 'North Europe'
            Replication = 'Standard_ZRS'
            VMs = @(
                @{
                    Name = '1'
                    Subnet = 'Test'
                    Size = 'ExtraLarge'
                    ImageLabel = 'Windows Server 2012 R2 Datacenter'
                    Credentials = $credentials
                }
            )
        }
    )

    New-WPResourceBase -Configuration $Configuration

    Write-VerboseCompleted $MyInvocation.MyCommand
}

try {
    Export-ModuleMember -Function New-WPEnvironmentSolR -ErrorAction Ignore
}
catch {
    # In case this is ran as a dot-script
}
