. (join-Path (Split-Path -Parent $MyInvocation.MyCommand.Path) helpers.ps1)

function Confirm-WPAzureSubscription
{
    [CmdletBinding(SupportsShouldProcess=$true)]
    param ()

    Write-VerboseBegin $MyInvocation.MyCommand

    $account = Get-AzureAccount

    # Authenticate to Azure
    if (!$account)
    {
        Add-AzureAccount
    }

    # Select Subscription

    $subscriptions = Get-AzureSubscription

    $subscriptionName = $subscriptions `
        | ? {$_.IsCurrent} `
        | select -ExpandProperty SubscriptionName

    $result = Invoke-Prompt `
        -Title "Current Subscription" `
        -Message "Your current subscription is $subscriptionName." `
        -FirstChoice "&Use $subscriptionName" `
        -FirstChoiceHelp "Uses $subscriptionName for all further operations." `
        -SecondChoice "&Change subscription" `
        -SecondChoiceHelp "Select another subscription for further operations."

    switch ($result)
        {
            0 {
                Write-VerboseCompleted $MyInvocation.MyCommand
                return $subscriptionName
            }
            1 {
                $subscription =  $subscriptions `
                    | Out-GridView -PassThru -Title "Select Azure Subscription"

                Select-AzureSubscription -SubscriptionName $subscription.SubscriptionName

                Write-VerboseCompleted $MyInvocation.MyCommand
                return $subscription.SubscriptionName
            }
        }
}