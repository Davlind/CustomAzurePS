$src = Resolve-Path (Join-Path (Split-Path -Parent $MyInvocation.MyCommand.Path) '..\src\includes')
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.", ".")
. "$src\$sut"

Describe "Confirm-WPAzureSubscription" {
    Context "When Azure Account doesnt exists" {
        Mock Get-AzureAccount {return $null}
        Mock Add-AzureAccount {return}
        Mock Invoke-Prompt { return 0 }
        Mock Get-AzureSubscription { return New-Object PSObject -Property @{ IsCurrent = $true; SubscriptionName = "ExistingSubscription" } }

        It "adds a new account" {
            Confirm-WPAzureSubscription | Should Be "ExistingSubscription"
            Assert-MockCalled Add-AzureAccount -Times 1
        }
    }

    Context "When Azure Account exists" {
        Mock Get-AzureAccount {return "ExistingAccount"}
        Mock Add-AzureAccount {return}
        Mock Invoke-Prompt { return 0 }
        Mock Get-AzureSubscription { return New-Object PSObject -Property @{ IsCurrent = $true; SubscriptionName = "ExistingSubscription" } }

        It "doesn't add a new account" {
            Confirm-WPAzureSubscription | Should Be "ExistingSubscription"
            Assert-MockCalled Add-AzureAccount -Times 0
        }
    }

    Context "When current subscription should not be changed" {
        Mock Get-AzureAccount {return "ExistingAccount"}
        Mock Add-AzureAccount {return}
        Mock Invoke-Prompt { return 0 }
        Mock Get-AzureSubscription { return New-Object PSObject -Property @{ IsCurrent = $true; SubscriptionName = "ExistingSubscription" } }
        Mock Select-AzureSubscription {return}

        It "should not select subscription" {
            Confirm-WPAzureSubscription | Should Be "ExistingSubscription"
            Assert-MockCalled Select-AzureSubscription -Times 0
        }
    }

    Context "When current subscription should be changed" {
        Mock Get-AzureAccount {return "ExistingAccount"}
        Mock Add-AzureAccount {return}
        Mock Invoke-Prompt { return 1 }
        Mock Get-AzureSubscription { return New-Object PSObject -Property @{ IsCurrent = $true; SubscriptionName = "ExistingSubscription" } }
        Mock Select-AzureSubscription {return}
        Mock Out-Gridview { return New-Object PSObject -Property @{ IsCurrent = $true; SubscriptionName = "AnotherSubscription" }}

        It "should select another subscription" {
            Confirm-WPAzureSubscription | Should Be "AnotherSubscription"
            Assert-MockCalled Select-AzureSubscription -Times 1
        }
    }
}