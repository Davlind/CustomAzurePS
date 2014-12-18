$src = Resolve-Path (Join-Path (Split-Path -Parent $MyInvocation.MyCommand.Path) '..\src\includes')
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.", ".")
. "$src\$sut"

$wrongPassword = "a password" | ConvertTo-SecureString -asPlainText -Force
$wrongUsername = 'nonexisting'
$wrongCredential = New-Object System.Management.Automation.PSCredential($wrongUsername,$wrongPassword)

Describe "Test-WPADCredentials" {
    It "throws exception if credentials is incorrect" {
        { Test-WPADCredentials $wrongCredential } | Should Throw
    }
}
