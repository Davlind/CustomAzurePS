. .\Helpers.ps1

EnsureAuthentication

$subscriptionName = Get-AzureSubscription | ? { $_.IsCurrent } | select -ExpandProperty SubscriptionName

$storageAccountName = 'ifwpdsc'

Set-AzureSubscription `
    -SubscriptionName $subscriptionName `
    -CurrentStorageAccountName $storageAccountName `
    -Verbose

gci ..\dsc\ | % {
    Publish-AzureVMDscConfiguration `
        -ConfigurationPath $_.FullName `
        -Force `
        -Verbose
}
