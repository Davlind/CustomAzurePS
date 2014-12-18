. (join-Path (Split-Path -Parent $MyInvocation.MyCommand.Path) helpers.ps1)

function Test-WPADCredentials {
    [CmdletBinding(SupportsShouldProcess=$true)]
    param (
        [Parameter(Mandatory=$true,Position=1)]
        [PSCredential]$Credentials
    )

    Write-VerboseBegin $MyInvocation.MyCommand

    $username = $Credentials.username
    $password = $Credentials.GetNetworkCredential().password

    # Get current domain using logged-on user's credentials
     $CurrentDomain = "LDAP://" + ([ADSI]"").distinguishedName
     $domain = New-Object System.DirectoryServices.DirectoryEntry($CurrentDomain,$UserName,$Password)

    if ($domain.name -eq $null)
    {
        throw "Authentication failed - please verify your username and password."
    }
    else
    {
        Write-VerboseTS "Successfully authenticated as $username"
    }

    Write-VerboseCompleted $MyInvocation.MyCommand
}