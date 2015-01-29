configuration DomainControllerPrimaryConfig
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

        xADDomain FirstDS
        {
            DomainName = $Domain
            DomainAdministratorCredential = $Credential
            SafemodeAdministratorPassword = $Credential
            DependsOn = "[WindowsFeature]ADDSInstall"
        }

        xWaitForADDomain DscForestWait
        {
            DomainName = $Domain
            DomainUserCredential = $Credential
            RetryCount = 30
            RetryIntervalSec = 30
            DependsOn = "[xADDomain]FirstDS"
        }

        xADUser FirstUser
        {
            DomainName = $Domain
            DomainAdministratorCredential = $Credential
            UserName = "WaypointDA"
            Password = $Credential
            Ensure = "Present"
            DependsOn = "[xWaitForADDomain]DscForestWait"
        }
    }
}