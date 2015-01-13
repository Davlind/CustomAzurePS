. (join-Path (Split-Path -Parent $MyInvocation.MyCommand.Path) helpers.ps1)
. (join-Path (Split-Path -Parent $MyInvocation.MyCommand.Path) Confirm-WPAzureSubscription.ps1)
. (join-Path (Split-Path -Parent $MyInvocation.MyCommand.Path) Test-WPADCredentials.ps1)
. (join-Path (Split-Path -Parent $MyInvocation.MyCommand.Path) Get-WPLatestMicrosoftImage.ps1)
. (join-Path (Split-Path -Parent $MyInvocation.MyCommand.Path) New-WPVM.ps1)
. (join-Path (Split-Path -Parent $MyInvocation.MyCommand.Path) New-WPStorageAccount.ps1)
. (join-Path (Split-Path -Parent $MyInvocation.MyCommand.Path) New-WPCloudService.ps1)
. (join-Path (Split-Path -Parent $MyInvocation.MyCommand.Path) Get-WPDefaultServiceName.ps1)

function New-WPEnvironmentBase {
    [CmdletBinding(SupportsShouldProcess=$true)]
    param (
        [Parameter(Mandatory=$true, ParameterSetName = "NamingConvention")]
        [string]$Name,

        [Parameter(Mandatory=$true, ParameterSetName = "NamingExplicit")]
        [string]$StorageName,

        [Parameter(Mandatory=$true, ParameterSetName = "NamingExplicit")]
        [string]$ServiceName,

        [Parameter(Mandatory=$true, ParameterSetName = "NamingExplicit")]
        [string]$VirtualMachineName,

        [Parameter(Position=2)]
        [string]$SubnetName='Dev',

        [Parameter(Position=3)]
        [string]$InstanceSize='ExtraSmall',

        [Parameter(Position=4)]
        [string]$InstanceCount=1,

        [Parameter(Position=5)]
        [string]$Domain="waypoint.dev.ifint.biz",

        [Parameter(Position=6)]
        [string]$DomainNetBIOS="waypoint",

        [Parameter(Position=7)]
        [string]$ImageLabel = "Windows Server 2012 R2 Datacenter",

        [switch]$NoDomain = $false
    )

    $ErrorActionPreference = "Stop"

    Write-VerboseBegin $MyInvocation.MyCommand

    $currentSubscription = Confirm-WPAzureSubscription

    if ($NoDomain.IsPresent)
    {
        $credentials = Get-Credential -UserName "$env:UserName" -Message "Specify your credentials"
    }    
    else {
        $credentials = Get-Credential -UserName "$env:UserDomain\$env:UserName" -Message "Specify your credentials"
        Test-WPADCredentials $credentials
    
    }


    if ($PSCmdlet.ParameterSetName -eq 'NamingConvention')
    {
        $names = Get-WPDefaultServiceName $Name
        $StorageName = $names.storageAccountName
        $ServiceName = $names.serviceName
        $VirtualMachineName = $names.VirtualMachineName
    }

    $image = Get-WPLatestMicrosoftImage $ImageLabel
    if (!$image)
    {
        throw "No OS Image was found matching '$ImageLabel'"
    }

    Write-VerboseTS "Selected image '$($image.Label)' ($($image.PublishedDate))"

    $storageAccount = New-WPStorageAccount -Name $StorageName -AffinityGroup 'WPNE'

    Set-AzureSubscription `
        -SubscriptionName $currentSubscription `
        -CurrentStorageAccountName $StorageName

    $service = New-WPCloudService -Name $ServiceName -AffinityGroup 'WPNE'

    for ($i=1; $i -le $InstanceCount; $i++)
    {
        New-WPVM `
        -Name ($VirtualMachineName -f $i) `
        -ServiceName $ServiceName `
        -AffinityGroup 'WPNE' `
        -VNetName 'WP' `
        -SubnetName $SubnetName `
        -Image $image `
        -InstanceSize $InstanceSize `
        -Credentials $credentials `
    }

    Write-VerboseCompleted $MyInvocation.MyCommand
}
