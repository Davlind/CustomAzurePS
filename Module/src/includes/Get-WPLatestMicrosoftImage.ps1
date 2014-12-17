. (join-Path (Split-Path -Parent $MyInvocation.MyCommand.Path) helpers.ps1)

function Get-WPLatestMicrosoftImage
{
    [CmdletBinding(SupportsShouldProcess=$true)]
    param (
        [Parameter(Mandatory=$true,Position=1)]
        [string]$ImageLabel
    )

    Write-VerboseBegin $MyInvocation.MyCommand

    $image = Get-AzureVMImage `
    | ? { $_.Label -like "$ImageLabel*" -and $_.PublisherName -like 'Microsoft Windows Server Group'} `
    | sort PublishedDate -Descending `
    | select -first 1

    Write-VerboseCompleted $MyInvocation.MyCommand

    return $image
}