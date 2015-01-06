. .\Helpers.ps1

$subscriptionName = Get-AzureSubscription | ? { $_.IsCurrent } | select -ExpandProperty SubscriptionName

$storageAccountName = 'ifwpdsc'

Set-AzureSubscription `
    -SubscriptionName $subscriptionName `
    -CurrentStorageAccountName $storageAccountName

gci ..\dsc\ | % {
    Publish-AzureVMDscConfiguration `
        -ConfigurationPath $_.FullName `
        -Force
}
