$src = Resolve-Path (Join-Path (Split-Path -Parent $MyInvocation.MyCommand.Path) '..\src\includes')
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.", ".")
. "$src\$sut"

$img = @{
            Label = "Windows Server 2012"
            PublisherName = 'Microsoft Windows Server Group'
            PublishedDate = Get-Date
        }

Describe "Get-LatestMicrosoftImage" {
    It "gets the latest image published by Microsoft" {
        #Mock Write-VerboseBegin {return 0 }
        Mock Get-AzureVMImage { return @(
                @{
                    Label = "Windows Server 2012"
                    PublisherName = 'Microsoft Windows Server Group'
                    PublishedDate = (Get-Date).AddDays(-1)
                },
                $img,
                @{
                    Label = "Windows 8.1"
                    PublisherName = 'Microsoft Windows Server Group'
                    PublishedDate = (Get-Date).AddDays(1)
                },
                @{
                    Label = "Windows Server 2012"
                    PublisherName = 'Some other publisher'
                    PublishedDate = (Get-Date).AddDays(1)
                }
            )
        }
        Get-WPLatestMicrosoftImage "Windows Server 2012" | Should Be $img
    }
}