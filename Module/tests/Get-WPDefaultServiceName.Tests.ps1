# $src = Resolve-Path (Join-Path (Split-Path -Parent $MyInvocation.MyCommand.Path) '..\src\includes')
# $sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.", ".")
# . "$src\$sut"

# Describe "Get-WPDefaultServiceName" {

#     It "starts on 001 if no services is found" {
#         Mock Get-AzureService { return $null }
#         Get-WPDefaultServiceName 'Test' | Should Be 'ifwpTest001svc'
#     }

#     It "should pick the first available name" {
#         $list = @()
#         $list += New-Object PSObject -Property @{ ServiceName = 'ifwpTest001svc' }
#         $list += New-Object PSObject -Property @{ ServiceName = 'ifwpTest002svc' }
#         $list += New-Object PSObject -Property @{ ServiceName = 'ifwpTest004svc' }
#         Mock Get-AzureService {return $list}

#         Get-WPDefaultServiceName 'Test' | Should Be 'ifwpTest003svc'
#     }

#     It "should throw exception if there is no available name" {
#         $list = @()
#         1..999 | % { $list += New-Object PSObject -Property @{ ServiceName = ("ifwpTest{0:D3}svc" -f $_) }}

#         Mock Get-AzureService {return $list}

#         { Get-WPDefaultServiceName 'Test' } | Should Throw
#     }
# }
