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
        [Parameter(Position=1)]
        [string]$Name = '',

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

    if (!$NoDomain.IsPresent)
    {
        $credentials = Get-Credential -UserName "$env:UserDomain\$env:UserName" -Message "Specify your credentials"
        Test-WPADCredentials $credentials
    }

    $defaultNames = @{}
    if ($Name -eq '')
    {
        $defaultNames = Get-WPDefaultServiceName 'Test'
    }

    $image = Get-WPLatestMicrosoftImage $ImageLabel
    if (!$image)
    {
        throw "No OS Image was found matching '$ImageLabel'"
    }

    Write-Verbose "Selected image '$($image.Label)' ($($image.PublishedDate))"

    Write-Output $defaultNames.storageAccountName
    $storageAccount = New-WPStorageAccount -Name $defaultNames.storageAccountName -AffinityGroup 'WPNE'
    Write-Output $storageAccount
    Set-AzureSubscription `
        -SubscriptionName $currentSubscription `
        -CurrentStorageAccountName $storageAccount.storageAccountName

    Write-Output $defaultNames.ServiceName
    $service = New-WPCloudService -Name $defaultNames.ServiceName -AffinityGroup 'WPNE'
    Write-Output $service

    for ($i=1; $i -le $InstanceCount; $i++)
    {
        Write-Output ($defaultNames.VirtualMachineName -f $i)
        New-WPVM `
        -Name $Name `
        -VmIndex $i `
        -ServiceName ($defaultNames.VirtualMachineName -f $i) `
        -AffinityGroup 'WPNE' `
        -VNetName 'WP' `
        -SubnetName $SubnetName `
        -Image $image `
        -InstanceSize $InstanceSize `
        -Credentials $credentials `
    }

    Write-VerboseCompleted $MyInvocation.MyCommand
}
