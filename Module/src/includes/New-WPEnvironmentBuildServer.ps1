. (join-Path (Split-Path -Parent $MyInvocation.MyCommand.Path) helpers.ps1)
. (join-Path (Split-Path -Parent $MyInvocation.MyCommand.Path) New-WPEnvironmentBase.ps1)


function New-WPEnvironmentBuildServer {
    [CmdletBinding(SupportsShouldProcess=$true)]
    param (
    )
    Write-VerboseBegin $MyInvocation.MyCommand

    $domain = 'waypoint.ifint.biz'
    $credentials = Get-Credential -Message 'Specify a username and password that has permission to add machines to the domain'

    $Configuration = @(
        @{
            Type = 'Cloud Service'
            Name = 'ifwpBldSrv'
            ExplicitName = $true
            Location = 'North Europe'
            Replication = 'Standard_ZRS'
            VMs = @(
                @{
                    Name = '1'
                    Subnet = 'Infrastructure'
                    DscRole = 'BuildServer'
                    DscConfig = @{
                        Credential = $credentials
                        Domain = $domain
                    }
                    Size = 'Large'
                    StaticIP = '10.162.1.10'
                    ImageLabel = 'Windows Server 2012 R2 Datacenter'
                    Credentials = $credentials
                    Domain = $domain
                }
            )
        }
    )

    New-WPResourceBase -Configuration $Configuration

    Write-VerboseCompleted $MyInvocation.MyCommand
}

try {
    Export-ModuleMember -Function New-WPEnvironmentBuildServer -ErrorAction Ignore
}
catch {
    # In case this is ran as a dot-script
}
