$src = Resolve-Path (Join-Path (Split-Path -Parent $MyInvocation.MyCommand.Path) '..\src\includes')
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.", ".")
. "$src\$sut"

Describe "New-WPCloudService" {

    $existingCloudService = @{ ServiceName = 'ExistingService'}
    Mock Get-AzureService { return $existingCloudService }
    Mock New-AzureService { return @{} }

    It "doesn't create new cloud service if it already exists" {
        New-WPCloudService -Name 'Name' -AffinityGroup 'TestAG' | Should Be $existingCloudService
        Assert-MockCalled Get-AzureService -Times 1
        Assert-MockCalled New-AzureService -Times 0
    }

    $newCloudService = @{ ServiceName = 'NewService'}
    Mock Get-AzureService { return $null }
    Mock New-AzureService { return $newCloudService }

    It "creates new cloud service if it doesnt exists" {
        New-WPCloudService -Name 'Name' -AffinityGroup 'TestAG' | Should Be $newCloudService
        Assert-MockCalled Get-AzureService -Times 1
        Assert-MockCalled New-AzureService -Times 1
    }
}
