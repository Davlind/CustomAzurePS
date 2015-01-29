configuration DomainControllerSecondaryConfig
{
    param
    (
        [Parameter(Mandatory)]
        [pscredential]$Credential,

        [Parameter(Mandatory)]
        [pscredential]$DomainCredential,

        [Parameter(Mandatory)]
        [string]$Domain
    )

    Import-DscResource -ModuleName xActiveDirectory

    Node localhost {

        WindowsFeature ADDSInstall
        {
            Ensure = "Present"
            Name = "AD-Domain-Services"
        }

        xWaitForADDomain DscForestWait
        {
            DomainName = $Domain
            DomainUserCredential = $Credential
            RetryCount = 120
            RetryIntervalSec = 30
            DependsOn = "[WindowsFeature]ADDSInstall"
        }

        xADDomainController SecondDC
        {
            DomainName = $Domain
            DomainAdministratorCredential = $DomainCredential
            SafemodeAdministratorPassword = $Credential
            DependsOn = "[xWaitForADDomain]DscForestWait"
        }
    }
}