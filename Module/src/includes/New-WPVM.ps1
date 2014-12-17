function New-WPVM {


    [CmdletBinding(SupportsShouldProcess=$true)]
    param (
        [Parameter(Mandatory=$true)]
        [string]$Name,

        [Parameter(Mandatory=$true)]
        [int]$VmIndex,

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

    Write-VerboseTS "Creating virtual machine"
    $vmName = 'ifwp' + $Name + 'vm' + ("{0:D2}" -f $i)
    $adminUserName = $vmName + $env:UserName

    Write-VerboseTS "Virtual Machine Name: $vmName"
    Write-VerboseTS "Virtual Machine Image: $($Image.Label) ($($Image.ImageName))"
    Write-VerboseTS "Virtual Machine Size: $InstanceSize"
    Write-VerboseTS "Virtual Machine Local Admin: $adminUserName"
    Write-VerboseTS "Virtual Machine Local Admin Password: Same as $($Credentials.Username)"
    Write-VerboseTS "Virtual Machine VNet: WP"
    Write-VerboseTS "Virtual Machine Affinity Group: WPNE"

    $vm = New-AzureVMConfig `
    -Name $vmName `
    -ImageName $image.ImageName `
    -InstanceSize $InstanceSize

    # Specify VM local admin and domain join creds
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

    # Specify VNet Subnet for VM
    $vm = Set-AzureSubnet `
    -VM $vm `
    -SubnetNames $SubnetName

    # # Specify HA Availability Set for VM
    # $vm = Set-AzureAvailabilitySet `
    # -VM $vm `
    # -AvailabilitySetName $Using:availabilitySetName

    # Provision new VM with specified configuration
    New-AzureVM `
    -VMs $vm `
    -ServiceName $ServiceName `
    -AffinityGroup $AffinityGroup `
    -VNetName $VNetName `
    -WaitForBoot

    Write-VerboseCompleted $MyInvocation.MyCommand
}