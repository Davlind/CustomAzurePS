function Test-Credentials {
    [CmdletBinding(SupportsShouldProcess=$true)]
    param (
        [Parameter(Mandatory=$true,Position=1)]
        [PSCredential]$Credentials
    )

    $username = $Credentials.username
    $password = $Credentials.GetNetworkCredential().password

    # Get current domain using logged-on user's credentials
     $CurrentDomain = "LDAP://" + ([ADSI]"").distinguishedName
     $domain = New-Object System.DirectoryServices.DirectoryEntry($CurrentDomain,$UserName,$Password)

    if ($domain.name -eq $null)
    {
        throw "Authentication failed - please verify your username and password."
    }
    else
    {
        Write-Verbose "Successfully authenticated as $username"
    }
}

function Get-NewestMicrosoftImage
{
    [CmdletBinding(SupportsShouldProcess=$true)]
    param (
        [Parameter(Mandatory=$true,Position=1)]
        [string]$ImageLabel
    )

    return Get-AzureVMImage `
    | ? { $_.Label -like "$ImageLabel*" -and $_.PublisherName -like 'Microsoft Windows Server Group'} `
    | sort PublishedDate -Descending `
    | select -first 1
}

function New-WPVMBase {
    [CmdletBinding(SupportsShouldProcess=$true)]
    param (
        [Parameter(Position=1, Mandatory=$true)]
        [string]$Name,

        [Parameter(Position=2)]
        [string]$subnetName='Dev',

        [Parameter(Position=3)]
        [string]$InstanceSize='ExtraSmall',

        [Parameter(Position=4)]
        [string]$InstanceCount=1,

        [Parameter(Position=5)]
        [string]$Domain="waypoint.dev.ifint.biz",

        [Parameter(Position=6)]
        [string]$DomainNetBIOS="waypoint",

        [Parameter(Position=7)]
        [string]$ImageLabel = "Windows Server 2012 R2 Datacenter"
    )

    # Auth Azure
    # Add-AzureAccount
    # $subscription = Get-AzureSubscription | Out-GridView -Title SelectSubscription -PassThru

    # Select-AzureSubscription -SubscriptionName $subscription.SubscriptionName

    # Auth Domain
    $currentSubscription = Get-AzureSubscription | ? { $_.IsCurrent -eq $true} | select -ExpandProperty SubscriptionName
    $credentials = Get-Credential -UserName "$env:UserDomain\$env:UserName" -Message "Specify your credentials"
    Test-Credentials $credentials

    $image = Get-NewestMicrosoftImage $ImageLabel
    if (!$image)
    {
        throw "No OS Image was found matching '$ImageLabel'"
    }
    Write-Output $image
    Write-Verbose "Selected image '$($image.Label)' ($($image.PublishedDate))"

    # Create Storage account
    $storageAccountName = 'ifwp' + $Name + 'stor'
    $storageAccount = Get-AzureStorageAccount -StorageAccountName $storageAccountName -ErrorAction SilentlyContinue
    if (!$storageAccount)
    {
        New-AzureStorageAccount `
        -StorageAccountName $storageAccountName `
        -AffinityGroup 'WPNE'
    }
    Set-AzureSubscription -SubscriptionName $currentSubscription -CurrentStorageAccountName $storageAccountName

    # Create Cloud Service
    $serviceName = 'ifwp' + $Name + 'svc'
    $service = Get-AzureService -ServiceName $serviceName -ErrorAction SilentlyContinue
    if (!$service)
    {
        New-AzureService -ServiceName $serviceName -AffinityGroup 'WPNE'
    }

    for ($i=1; $i -le $InstanceCount; $i++)
    {
        $vmName = $Name + 'vm' + ("{0:D2}" -f $i)

        # Virtual Machine configuration
        $vm = New-AzureVMConfig `
        -Name $vmName `
        -ImageName $image.ImageName `
        -InstanceSize $InstanceSize

        # Specify VM local admin and domain join creds
        $vm = Add-AzureProvisioningConfig `
        -VM $vm `
        -Windows `
        -AdminUserName $credentials.Username `
        -Password $credentials.GetNetworkCredential().Password `
        # -WindowsDomain `
        # -JoinDomain $Domain `
        # -Domain $DomainNetBIOS `
        # -DomainUserName $credentials.Username `
        # -DomainPassword ` $credentials.GetNetworkCredential().Password

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
        # $vm = Set-AzureSubnet `
        # -VM $vm `
        # -SubnetNames $subnetName

        # # Specify HA Availability Set for VM
        # $vm = Set-AzureAvailabilitySet `
        # -VM $vm `
        # -AvailabilitySetName $Using:availabilitySetName

        # Provision new VM with specified configuration
        New-AzureVM `
        -VMs $vm `
        -ServiceName $serviceName `
        -AffinityGroup 'WPNE' `
        -VNetName 'WP' `
        -WaitForBoot
    }
}

#Export-ModuleMember *