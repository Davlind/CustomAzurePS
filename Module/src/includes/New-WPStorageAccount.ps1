
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
    $storageAccountName = ('ifwp' + $Name + 'stor').ToLower()
    $storageAccount = Get-AzureStorageAccount -StorageAccountName $storageAccountName -ErrorAction SilentlyContinue
    if (!$storageAccount)
    {
        $storageAccount = New-AzureStorageAccount `
        -StorageAccountName $storageAccountName `
        -AffinityGroup $AffinityGroup
    }

    Write-VerboseCompleted $MyInvocation.MyCommand

    return $storageAccount
}