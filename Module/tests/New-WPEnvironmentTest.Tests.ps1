$src = Resolve-Path (Join-Path (Split-Path -Parent $MyInvocation.MyCommand.Path) '..\src\includes')
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.", ".")
. "$src\$sut"

Describe "New-WPEnvironmentTest" {
    Context "When creating a new test environment" {
        Mock New-WPEnvironmentBase {return}
        Mock Get-WPDefaultServiceName { return "SomeName"}

        It "subnet should be defined" {
            New-WPEnvironmentTest -Name 'Test'

            Assert-MockCalled New-WPEnvironmentBase -Exact 1 -ParameterFilter { $SubnetName -eq 'Test' } -Scope It
        }

        It "name should be used if it is defined" {
            New-WPEnvironmentTest -Name 'Test'
            Assert-MockCalled Get-WPDefaultServiceName -Exact 0
            Assert-MockCalled New-WPEnvironmentBase -Exact 1 -ParameterFilter { $Name -eq 'Test' } -Scope It
        }

        It "default name should be used if no explicit name is defined" {
            New-WPEnvironmentTest
            Assert-MockCalled Get-WPDefaultServiceName -Exact 1
            Assert-MockCalled New-WPEnvironmentBase -Exact 1 -ParameterFilter { $Name -eq 'SomeName' } -Scope It
        }
    }
}