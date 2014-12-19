. (join-Path (Split-Path -Parent $MyInvocation.MyCommand.Path) helpers.ps1)

function New-WPStorageAccount {
    [CmdletBinding(SupportsShouldProcess=$true)]
    param (
        [Parameter(Position=1, Mandatory=$true)]
        [string]$Name,

        [Parameter(Position=2, Mandatory=$true)]
        [string]$AffinityGroup
    )

    Write-VerboseBegin $MyInvocation.MyCommand

        # Create Storage account
    $storageAccount = Get-AzureStorageAccount -StorageAccountName $Name -ErrorAction SilentlyContinue
    if (!$storageAccount)
    {
        Write-Host "Creating Storage Account: $Name"
        $storageAccount = New-AzureStorageAccount `
        -StorageAccountName $Name `
        -AffinityGroup $AffinityGroup
    }

    Write-VerboseCompleted $MyInvocation.MyCommand

    return $storageAccount
}