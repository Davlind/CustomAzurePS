$ErrorActionPreference = "Stop"

function EnsureAuthentication {
    if ($global:IsAzureAuthenticated) {
        return
    }

    Add-AzureAccount

    $subscription = Get-AzureSubscription | Out-GridView -Title SelectSubscription -PassThru

    Select-AzureSubscription -SubscriptionName $subscription.SubscriptionName

    $global:IsAzureAuthenticated = $true
}