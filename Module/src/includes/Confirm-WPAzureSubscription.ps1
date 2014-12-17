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

    $subscriptionName = Get-AzureSubscription `
        | ? {$_.IsCurrent} `
        | select -ExpandProperty SubscriptionName

    $title = "Current Subscription"
    $message = "Your current subscription is $subscriptionName."

    $yes = New-Object System.Management.Automation.Host.ChoiceDescription "&Use $subscriptionName", `
        "Uses $subscriptionName for all further operations."

    $no = New-Object System.Management.Automation.Host.ChoiceDescription "&Change subscription", `
        "Select another subscription for further operations."

    $options = [System.Management.Automation.Host.ChoiceDescription[]]($yes, $no)

    $result = $host.ui.PromptForChoice($title, $message, $options, 0)

    switch ($result)
        {
            0 {
                Write-VerboseCompleted $MyInvocation.MyCommand
                return $subscriptionName
            }
            1 {
                $subscription =  Get-AzureSubscription `
                    | Out-GridView -PassThru -Title "Select Azure Subscription"

                Select-AzureSubscription -SubscriptionName $subscription.SubscriptionName

                Write-VerboseCompleted $MyInvocation.MyCommand
                return $subscription.SubscriptionName
            }
        }
}