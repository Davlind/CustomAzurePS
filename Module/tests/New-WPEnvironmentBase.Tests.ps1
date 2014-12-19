$src = Resolve-Path (Join-Path (Split-Path -Parent $MyInvocation.MyCommand.Path) '..\src\includes')
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.", ".")
. "$src\$sut"

Describe "New-WPEnvironmentBase" {
    Context "When image is retrived" {
        Mock Confirm-WPAzureSubscription {return "subscriptionName"}
        Mock Get-Credential {return New-Object System.Management.Automation.PSCredential("user", (ConvertTo-SecureString "PlainTextPassword" -AsPlainText -Force))}
        Mock Test-WPADCredentials {return}
        Mock New-WPVM {return}
        Mock New-WPStorageAccount {return @{storageAccountName = "storage"}}
        Mock New-WPCloudService {return @{serviceName = "service"}}
        Mock Set-AzureSubscription {return}
        Mock Get-WPDefaultServiceName { return "SomeName"}
        
        It "should throw exception if no image is found" {
            Mock Get-WPLatestMicrosoftImage { return $null }
            { New-WPEnvironmentBase -Name 'Name' } | Should Throw
        }

        It "should not throw exception if image is found" {
            Mock Get-WPLatestMicrosoftImage { return "someImage" }
            { New-WPEnvironmentBase -Name 'Name' } | Should Not Throw
        }
    }

    Context "When instance count is" {
        Mock Confirm-WPAzureSubscription {return "subscriptionName"}
        Mock Get-Credential {return New-Object System.Management.Automation.PSCredential("user", (ConvertTo-SecureString "PlainTextPassword" -AsPlainText -Force))}
        Mock Test-WPADCredentials {return}
        Mock New-WPVM {return}
        Mock New-WPStorageAccount {return @{storageAccountName = "storage"}}
        Mock New-WPCloudService {return @{serviceName = "service"}}
        Mock Set-AzureSubscription {return}
        Mock Get-WPLatestMicrosoftImage { return "someImage" }
        Mock Get-WPDefaultServiceName { return "SomeName"}
    
        It "11, virtual machines should have 11 instances" {
            Mock Get-WPLatestMicrosoftImage { return "someImage" }
            New-WPEnvironmentBase -Name 'Name' -InstanceCount 11
            Assert-MockCalled New-WPVM -Times 11
        }
    }

    Context "When creating a new base environment" {
        Mock Confirm-WPAzureSubscription {return "subscriptionName"}
        Mock Get-Credential {return New-Object System.Management.Automation.PSCredential("user", (ConvertTo-SecureString "PlainTextPassword" -AsPlainText -Force))}
        Mock Test-WPADCredentials {return}
        Mock New-WPVM {return}
        Mock New-WPStorageAccount {return @{storageAccountName = "storage"}}
        Mock New-WPCloudService {return @{serviceName = "service"}}
        Mock Set-AzureSubscription {return}
        Mock Get-WPLatestMicrosoftImage { return "someImage" }
        Mock Get-WPDefaultServiceName { return "SomeName"}

        It "name should be used if it is defined" {
            New-WPEnvironmentBase -Name 'Test'
            Assert-MockCalled Get-WPDefaultServiceName -Exact 0           
        }

        It "default name should be used if no explicit name is defined" {
            New-WPEnvironmentBase
            Assert-MockCalled Get-WPDefaultServiceName -Exact 1
        }
    }
}