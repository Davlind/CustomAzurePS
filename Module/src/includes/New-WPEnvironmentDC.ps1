. (join-Path (Split-Path -Parent $MyInvocation.MyCommand.Path) helpers.ps1)
. (join-Path (Split-Path -Parent $MyInvocation.MyCommand.Path) New-WPEnvironmentBase.ps1)


function New-WPEnvironmentDC {
    [CmdletBinding(SupportsShouldProcess=$true)]
    param (
    )

    Write-VerboseBegin $MyInvocation.MyCommand

    $credentials = Get-Credential -Message 'Specify a username and password to be used as administrator on the machine'

    $Configuration = @(
        @{
            Type = 'Cloud Service'
            Name = 'ifwpDomain'
            ExplicitName = $true
            Location = 'North Europe'
            Replication = 'Standard_ZRS'
            VMs = @(
                @{
                    Name = 'Pri'
                    Subnet = 'Infrastructure'
                    DscRole = 'DomainControllerPrimary'
                    DscConfig = @{
                        Credential = $Credentials
                        Domain = 'waypoint.ifint.biz'
                    }
                    StaticIP = '10.162.1.4'
                    Size = 'Small'
                    ImageLabel = 'Windows Server 2012 R2 Datacenter'
                    Credentials = $credentials
                }
                @{
                    Name = 'Sec'
                    Subnet = 'Infrastructure'
                    DscRole = 'DomainControllerSecondary'
                    DscConfig = @{
                        Credential = $Credentials
                        Domain = 'waypoint.ifint.biz'
                    }
                    StaticIP = '10.162.1.5'
                    Size = 'Small'
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
    Export-ModuleMember -Function New-WPEnvironmentDC -ErrorAction Ignore
}
catch {
    # In case this is ran as a dot-script
}
