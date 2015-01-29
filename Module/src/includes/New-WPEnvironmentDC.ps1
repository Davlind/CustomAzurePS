. (join-Path (Split-Path -Parent $MyInvocation.MyCommand.Path) helpers.ps1)
. (join-Path (Split-Path -Parent $MyInvocation.MyCommand.Path) New-WPEnvironmentBase.ps1)


function New-WPEnvironmentDC {
    [CmdletBinding(SupportsShouldProcess=$true)]
    param (
    )

    Write-VerboseBegin $MyInvocation.MyCommand

    $domain = 'waypoint.ifint.biz'
    $credentials = Get-Credential -Message 'Specify a username and password to be used as administrator on the machine. Do not include domain.'
    $domainCredentials = New-Object System.Management.Automation.PSCredential("$domain\$($credentials.UserName)", $credentials.Password)

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
                        Credential = $credentials
                        Domain = $domain
                    }
                    StaticIP = '10.162.1.4'
                    AvailabilitySet = 'avs-domain'
                    Size = 'Small'
                    ImageLabel = 'Windows Server 2012 R2 Datacenter'
                    Credentials = $credentials
                }
                @{
                    Name = 'Sec'
                    Subnet = 'Infrastructure'
                    DscRole = 'DomainControllerSecondary'
                    DscConfig = @{
                        Credential = $credentials
                        DomainCredential = $domainCredentials
                        Domain = $domain
                    }
                    StaticIP = '10.162.1.5'
                    AvailabilitySet = 'avs-domain'
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
