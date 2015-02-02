. (join-Path (Split-Path -Parent $MyInvocation.MyCommand.Path) helpers.ps1)
. (join-Path (Split-Path -Parent $MyInvocation.MyCommand.Path) Confirm-WPAzureSubscription.ps1)

function New-WPResourceBase {
    [CmdletBinding(SupportsShouldProcess=$true)]
    param (
        $Configuration
    )

    $ErrorActionPreference = "Stop"

    Write-VerboseBegin $MyInvocation.MyCommand

    $currentSubscription = Confirm-WPAzureSubscription

    $Configuration | % {
        New-WPCloudService -CloudServiceConfiguration $_
    }

    Write-VerboseCompleted $MyInvocation.MyCommand
}

function New-WPCloudService {
    [CmdletBinding(SupportsShouldProcess=$true)]
    param (
        $CloudServiceConfiguration
    )

    $ErrorActionPreference = "Stop"

    Write-VerboseBegin $MyInvocation.MyCommand

    # Find approperiate names
    $availableNames = Get-AvailableNames -Name $CloudServiceConfiguration.Name -ExplicitName:$CloudServiceConfiguration.ExplicitName

    # Create a storage account for the cloud service
    Write-Host ("Creating Storage Account ""{0}"" of type {2} in {1}... " -f `
        $availableNames.StorageAccountName, `
        $CloudServiceConfiguration.Location, `
        $CloudServiceConfiguration.Replication) -NoNewLine
    New-AzureStorageAccount `
        -StorageAccountName $availableNames.StorageAccountName `
        -Location $CloudServiceConfiguration.Location | Write-Status

    # Create the cloud service
    Write-Host ("Creating Cloud Service ""{0}"" in {1}                  " -f `
        $availableNames.ServiceName, `
        $CloudServiceConfiguration.Location) -NoNewLine
    New-AzureService `
        -ServiceName $availableNames.ServiceName `
        -Location $CloudServiceConfiguration.Location | Write-Status

    # Switch to the new Storage Account
    $subscriptionId = Get-AzureSubscription | ? { $_.IsCurrent } | select -ExpandProperty SubscriptionId
    Set-AzureSubscription `
        -SubscriptionId $subscriptionId `
        -CurrentStorageAccountName $availableNames.StorageAccountName

    # Create the Virtual Machines
    $CloudServiceConfiguration.VMs | % {
            New-WPVirtualMachine `
                -VMConfig $_ `
                -NamesCollection $availableNames
    }

    Write-VerboseCompleted $MyInvocation.MyCommand
}

function New-WPVirtualMachine {
    [CmdletBinding(SupportsShouldProcess=$true)]
    param (
        $VMConfig,
        $NamesCollection
    )

    $ErrorActionPreference = "Stop"

    Write-VerboseBegin $MyInvocation.MyCommand

    # Resolving FQN
    $vmName = ("{0}{1}" -f $NamesCollection.ServiceName, $VMConfig.Name)

    Write-Host "Preparing configuration for $vmName"

    # Resolving OS Image
    $image = Get-WPLatestMicrosoftImage $VMConfig.ImageLabel

    Write-VerboseTS "Found image '$($image.Label)' ($($image.PublishedDate))"

    # Basic VM Configuration
    Write-Verbose ("Configuring VM {0} to use a {1} instance size with {2}" -f `
        $vmName, `
        $VMConfig.Size, `
        $VMConfig.ImageLabel)
    $vm = New-AzureVMConfig `
        -Name $vmName `
        -ImageName $image.ImageName `
        -InstanceSize $VMConfig.Size

    # Adding user and potentionally add to domain
    if ($VMConfig.Domain) {
        #$domainCredentials = New-Object System.Management.Automation.PSCredential("$($VMConfig.Domain)\$($VMConfig.Credentials.UserName)", $VMConfig.Credentials.Password)

        $vm = Add-AzureProvisioningConfig `
            -VM $vm `
            -WindowsDomain `
            -JoinDomain $VMConfig.Domain `
            -Domain $VMConfig.Domain `
            -DomainUserName $VMConfig.Credentials.UserName `
            -DomainPassword $VMConfig.Credentials.GetNetworkCredential().Password `
            -AdminUserName $VMConfig.Credentials.UserName `
            -Password $VMConfig.Credentials.GetNetworkCredential().Password
    } else {
        Write-Verbose "No domain was specified. VM will be assigned to default workgroup"
        $vm = Add-AzureProvisioningConfig `
            -VM $vm `
            -Windows `
            -AdminUserName $VMConfig.Credentials.UserName `
            -Password $VMConfig.Credentials.GetNetworkCredential().Password
    }

    if ($VMConfig.DscRole)
    {
        Write-Verbose ("DSC Role {0} was defined. DSC Extension will be applied" -f $VMConfig.DscRole)
        $StorageAccountKey = (Get-AzureStorageKey -StorageAccountName 'ifwpdsc').Primary
        $StorageContext = New-AzureStorageContext -StorageAccountName 'ifwpdsc' -StorageAccountKey $StorageAccountKey

        $vm = Set-AzureVMDSCExtension `
            -VM $vm `
            -ConfigurationArchive ("{0}.ps1.zip" -f $VMConfig.DscRole) `
            -ConfigurationName ("{0}Config" -f $VMConfig.DscRole) `
            -ConfigurationArgument $VMConfig.DscConfig `
            -StorageContext $StorageContext `
            -Force
    }

    # Assigning VM to correct subnet
    Write-Verbose ("Assigning VM to Subnet {0}" -f $VMConfig.Subnet)
    $vm = Set-AzureSubnet `
        -VM $vm `
        -SubnetNames $VMConfig.Subnet

    # Assigning Static IP if specified
    if ($VMConfig.StaticIP)
    {
        Write-Verbose ("Static IP {0} was defined" -f $VMConfig.StaticIP)
        $vm = Set-AzureStaticVNetIP `
            -VM $vm `
            -IPAddress $VMConfig.StaticIP
    }

    # Specify HA Availability Set for VM
    if ($VMConfig.AvailabilitySet)
    {
        Write-Verbose ("Availability Set was set to {0}" -f $VMConfig.AvailabilitySet)
        $vm = Set-AzureAvailabilitySet `
            -VM $vm `
            -AvailabilitySetName $VMConfig.AvailabilitySet
    }

    Write-Host "Provisioning $vmName...                                 "

    New-AzureVM `
        -VMs $vm `
        -ServiceName $NamesCollection.ServiceName `
        -Location 'North Europe' `
        -VNetName 'WP' | Write-Status

    Write-VerboseCompleted $MyInvocation.MyCommand
}


function Get-AvailableNames {
    [CmdletBinding(SupportsShouldProcess=$true)]
    param (
        [string] $Name,

        [switch] $ExplicitName

    )

    $ErrorActionPreference = "Stop"

    Write-VerboseBegin $MyInvocation.MyCommand

    # If the name is explicit, just return it...
    if ($ExplicitName.IsPresent)
    {
        return @{
                ServiceName = $Name
                StorageAccountName = ("{0}stor" -f $Name).ToLower()
            }
    }

    # Optimization in case we are the owners of colliding names
    $existingServices = Get-AzureService        | select -ExpandProperty ServiceName
    $existingStorage  = Get-AzureStorageAccount | select -ExpandProperty StorageAccountName

    for ($i = 1; $i -le 99; $i++)
    {
        $svcName = "ifwp{0}{1:D2}" -f $Name, $i
        $storName = ("ifwp{0}{1:D2}stor" -f $Name, $i).ToLower()

        if (($existingServices -contains $svcName) -or
            ($existingStorage -contains $storName) -or
            (Test-AzureName -Service $svcName) -or
            (Test-AzureName -Storage $storName))
        {
            Write-Verbose "The name $svcName or $storName is already in use. Increasing index..."
        }
        else {
            Write-Verbose "The names $svcName and $storName are available"
            return @{
                ServiceName = $svcName
                StorageAccountName = $storName
            }
        }
    }

    Write-VerboseCompleted $MyInvocation.MyCommand
}

function Get-WPLatestMicrosoftImage
{
    [CmdletBinding(SupportsShouldProcess=$true)]
    param (
        [Parameter(Mandatory=$true,Position=1)]
        [string]$ImageLabel
    )

    Write-VerboseBegin $MyInvocation.MyCommand

    $image = Get-AzureVMImage `
    | ? { $_.Label -like "$ImageLabel*" -and $_.PublisherName -like 'Microsoft Windows Server Group'} `
    | sort PublishedDate -Descending `
    | select -first 1

    Write-VerboseCompleted $MyInvocation.MyCommand

    if (!$image)
    {
        throw "No OS Image was found matching '$($VMConfig.ImageLabel)'"
    }

    return $image
}

function Write-Status {
    [CmdletBinding(SupportsShouldProcess=$true)]
    param (
        [Parameter(Mandatory=$true, Position=1, ValueFromPipeline=$true)]
        $Status
    )

    $color = 'White'
    switch ($Status.OperationStatus)
    {
        "Succeeded" { $color = 'Green'}
        "Failed"    { $color = 'Red'}
        default     { $color = 'Yellow'}
    }

    Write-Host '[' -ForegroundColor 'White' -NoNewLine
    Write-Host $Status.OperationStatus -ForegroundColor $color -NoNewLine
    Write-Host ']' -ForegroundColor 'White'
}