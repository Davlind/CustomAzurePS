. (join-Path (Split-Path -Parent $MyInvocation.MyCommand.Path) helpers.ps1)

function New-WPVM {
    [CmdletBinding(SupportsShouldProcess=$true)]
    param (
        [Parameter(Mandatory=$true)]
        [string]$Name,

        [Parameter(Mandatory=$true)]
        [string]$ServiceName,

        [Parameter(Mandatory=$true)]
        [string]$AffinityGroup,

        [Parameter(Mandatory=$true)]
        [string]$VNetName,

        [Parameter(Mandatory=$true)]
        [string]$SubnetName,

        [Parameter(Mandatory=$true)]
        $Image,

        [Parameter(Mandatory=$true)]
        [string]$InstanceSize,

        [Parameter(Mandatory=$true)]
        [PSCredential]$Credentials
    )

    Write-VerboseBegin $MyInvocation.MyCommand

    $adminUserName = $Name + $env:UserName

    Write-Host "Preparing VM Configuration for $Name"
    $vm = New-AzureVMConfig `
    -Name $Name `
    -ImageName $image.ImageName `
    -InstanceSize $InstanceSize

    # Specify VM local admin and domain join creds
    Write-Host "Preparing VM Provisioning Configuration for $Name"
    $vm = Add-AzureProvisioningConfig `
    -VM $vm `
    -Windows `
    -AdminUserName $adminUserName `
    -Password $Credentials.GetNetworkCredential().Password `
    # -WindowsDomain `
    # -JoinDomain $Domain `
    # -Domain $DomainNetBIOS `
    # -DomainUserName $Credentials.Username `
    # -DomainPassword ` $Credentials.GetNetworkCredential().Password

    # # Specify load-balanced firewall endpoint for HTTPS
    # $vm = Add-AzureEndpoint `
    # -VM $vm `
    # -Name 'WebHTTPS' `
    # -LBSetName 'LBWebHTTPS' `
    # -DefaultProbe `
    # -Protocol tcp `
    # -LocalPort 443 `
    # -PublicPort 443

    Write-Host "Preparing VM Desired State Configuration for $Name"
    $vm = Set-AzureVMDSCExtension `
    -VM $vm `
    -ConfigurationArchive 'Test.ps1.zip' `
    -ConfigurationName 'TestConfig'


    # Specify VNet Subnet for VM
    Write-Host "Preparing VM Subnet Configuration for $Name"
    $vm = Set-AzureSubnet `
    -VM $vm `
    -SubnetNames $SubnetName

    # # Specify HA Availability Set for VM
    # $vm = Set-AzureAvailabilitySet `
    # -VM $vm `
    # -AvailabilitySetName $Using:availabilitySetName

    # Provision new VM with specified configuration
    Write-Host "Creating VM: $Name"
    New-AzureVM `
    -VMs $vm `
    -ServiceName $ServiceName `
    -AffinityGroup $AffinityGroup `
    -VNetName $VNetName `
    -WaitForBoot

    Write-VerboseCompleted $MyInvocation.MyCommand
}