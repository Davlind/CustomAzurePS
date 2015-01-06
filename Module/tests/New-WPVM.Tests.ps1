$src = Resolve-Path (Join-Path (Split-Path -Parent $MyInvocation.MyCommand.Path) '..\src\includes')
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.", ".")
. "$src\$sut"

Describe "New-WPWM" {

    Mock New-AzureVMConfig {return New-Object Microsoft.WindowsAzure.Commands.ServiceManagement.Model.PersistentVM}
    Mock Add-AzureProvisioningConfig {return New-Object Microsoft.WindowsAzure.Commands.ServiceManagement.Model.PersistentVM}
    Mock Set-AzureSubnet {return New-Object Microsoft.WindowsAzure.Commands.ServiceManagement.Model.PersistentVM}
    Mock Set-AzureVMDSCExtension {return New-Object Microsoft.WindowsAzure.Commands.ServiceManagement.Model.PersistentVM}
    Mock New-AzureVM {return}

    It "virtual machine config should be set" {
        New-WPVM `
            -Name 'Name' `
            -ServiceName 'serviceName' `
            -AffinityGroup 'ag' `
            -VNetName 'vnet' `
            -SubnetName 'subnet' `
            -Image @{ImageName = "imageName"} `
            -InstanceSize 'size' `
            -Credentials (New-Object System.Management.Automation.PSCredential("user", (ConvertTo-SecureString "PlainTextPassword" -AsPlainText -Force))) `

        Assert-MockCalled New-AzureVMConfig -Exact 1 -ParameterFilter { $ImageName -eq 'imageName' -and $InstanceSize -eq 'size' -and $Name -eq 'Name' } -Scope It
    }

    It "provisioning config should be set" {
        New-WPVM `
            -Name 'Name' `
            -ServiceName 'serviceName' `
            -AffinityGroup 'ag' `
            -VNetName 'vnet' `
            -SubnetName 'subnet' `
            -Image @{ImageName = "imageName"} `
            -InstanceSize 'size' `
            -Credentials (New-Object System.Management.Automation.PSCredential("user", (ConvertTo-SecureString "PlainTextPassword" -AsPlainText -Force))) `

        Assert-MockCalled Add-AzureProvisioningConfig -Exact 1 -ParameterFilter { $Windows -eq $true -and $AdminUserName -eq ('Name' + $env:username) } -Scope It
    }

    It "subnet config should be set" {
        New-WPVM `
            -Name 'Name' `
            -ServiceName 'serviceName' `
            -AffinityGroup 'ag' `
            -VNetName 'vnet' `
            -SubnetName 'subnet' `
            -Image @{ImageName = "imageName"} `
            -InstanceSize 'size' `
            -Credentials (New-Object System.Management.Automation.PSCredential("user", (ConvertTo-SecureString "PlainTextPassword" -AsPlainText -Force))) `

        Assert-MockCalled Set-AzureSubnet -Exact 1 -ParameterFilter { $SubnetNames -eq 'subnet' } -Scope It
    }

    It "creates a new vm" {
        New-WPVM `
            -Name 'Name' `
            -ServiceName 'serviceName' `
            -AffinityGroup 'ag' `
            -VNetName 'vnet' `
            -SubnetName 'subnet' `
            -Image @{ImageName = "imageName"} `
            -InstanceSize 'size' `
            -Credentials (New-Object System.Management.Automation.PSCredential("user", (ConvertTo-SecureString "PlainTextPassword" -AsPlainText -Force))) `

        Assert-MockCalled New-AzureVM -Exact 1 -ParameterFilter { $ServiceName -eq 'serviceName' -and $AffinityGroup -eq 'ag' -and $VNetName -eq 'vnet' -and $WaitForBoot -eq $true } -Scope It
    }


}
