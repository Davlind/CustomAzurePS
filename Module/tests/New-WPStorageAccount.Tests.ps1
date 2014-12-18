$src = Resolve-Path (Join-Path (Split-Path -Parent $MyInvocation.MyCommand.Path) '..\src\includes')
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.", ".")
. "$src\$sut"

Describe "New-WPStorageAccount" {

    $existingStorageAccount = @{ ServiceName = 'ExistingStorageAccount'}
    Mock Get-AzureStorageAccount { return $existingStorageAccount }
    Mock New-AzureStorageAccount { return @{} }

    It "doesn't create new storage account if it already exists" {
        New-WPStorageAccount -Name 'Name' -AffinityGroup 'TestAG' | Should Be $existingStorageAccount
        Assert-MockCalled Get-AzureStorageAccount -Times 1
        Assert-MockCalled New-AzureStorageAccount -Times 0
    }

    $newStorageAccount = @{ ServiceName = 'NewService'}
    Mock Get-AzureStorageAccount { return $null }
    Mock New-AzureStorageAccount { return $newStorageAccount }

    It "creates new storage account if it doesnt exists" {
        New-WPStorageAccount -Name 'Name' -AffinityGroup 'TestAG' | Should Be $newStorageAccount
        Assert-MockCalled Get-AzureStorageAccount -Times 1
        Assert-MockCalled New-AzureStorageAccount -Times 1
    }
}
