$src = Resolve-Path (Join-Path (Split-Path -Parent $MyInvocation.MyCommand.Path) '..\src\includes')
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.", ".")
. "$src\$sut"

Describe "New-WPEnvironmentTest" {
    Context "When creating a new test environment" {
        Mock New-WPEnvironmentBase {return}

        It "subnet should be defined" {
            New-WPEnvironmentTest -Name 'Test'

            Assert-MockCalled New-WPEnvironmentBase -Exact 1 -ParameterFilter { $SubnetName -eq 'Test' } -Scope It
        }


    }
}