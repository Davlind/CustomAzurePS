. (join-Path (Split-Path -Parent $MyInvocation.MyCommand.Path) helpers.ps1)
. (join-Path (Split-Path -Parent $MyInvocation.MyCommand.Path) Confirm-WPAzureSubscription.ps1)
. (join-Path (Split-Path -Parent $MyInvocation.MyCommand.Path) Test-WPADCredentials.ps1)
. (join-Path (Split-Path -Parent $MyInvocation.MyCommand.Path) Get-WPLatestMicrosoftImage.ps1)
. (join-Path (Split-Path -Parent $MyInvocation.MyCommand.Path) New-WPVM.ps1)
. (join-Path (Split-Path -Parent $MyInvocation.MyCommand.Path) New-WPStorageAccount.ps1)
. (join-Path (Split-Path -Parent $MyInvocation.MyCommand.Path) New-WPCloudService.ps1)

function New-WPEnvironmentBase {
    [CmdletBinding(SupportsShouldProcess=$true)]
    param (
        [Parameter(Position=1, Mandatory=$true)]
        [string]$Name,

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
        [string]$ImageLabel = "Windows Server 2012 R2 Datacenter"
    )

    Write-VerboseBegin $MyInvocation.MyCommand

    $currentSubscription = Confirm-WPAzureSubscription

    $credentials = Get-Credential -UserName "$env:UserDomain\$env:UserName" -Message "Specify your credentials"
    Test-WPADCredentials $credentials

    $image = Get-WPLatestMicrosoftImage $ImageLabel
    if (!$image)
    {
        throw "No OS Image was found matching '$ImageLabel'"
    }

    Write-Output $image
    Write-Verbose "Selected image '$($image.Label)' ($($image.PublishedDate))"

    $storageAccount = New-WPStorageAccount -Name $Name -AffinityGroup 'WPNE'
    Write-Output $storageAccount
    Set-AzureSubscription `
        -SubscriptionName $currentSubscription `
        -CurrentStorageAccountName $storageAccount.storageAccountName


    $service = New-WPCloudService -Name $Name -AffinityGroup 'WPNE'
    Write-Output $service

    for ($i=1; $i -le $InstanceCount; $i++)
    {

        New-WPVM `
        -Name $Name `
        -VmIndex $i `
        -ServiceName $service.ServiceName `
        -AffinityGroup 'WPNE' `
        -VNetName 'WP' `
        -SubnetName $SubnetName `
        -Image $image `
        -InstanceSize $InstanceSize `
        -Credentials $credentials `
    }

    Write-VerboseCompleted $MyInvocation.MyCommand
}
