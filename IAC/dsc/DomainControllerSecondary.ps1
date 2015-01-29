configuration DomainControllerSecondaryConfig
{
    param
    (
        [Parameter(Mandatory)]
        [pscredential]$Credential,

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
            RetryCount = 30
            RetryIntervalSec = 30
            DependsOn = "[WindowsFeature]ADDSInstall"
        }

        xADDomainController SecondDC
        {
            DomainName = $Domain
            DomainAdministratorCredential = $Credential
            SafemodeAdministratorPassword = $Credential
            DependsOn = "[xWaitForADDomain]DscForestWait"
        }
    }
}