configuration DomainControllerConfig
{
   param
    (
        [Parameter(Mandatory)]
        [pscredential]$cred
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
            DomainName = 'waypoint.ifint.biz'
            DomainAdministratorCredential = $cred
            SafemodeAdministratorPassword = $cred
            DnsDelegationCredential = $cred
            DependsOn = "[WindowsFeature]ADDSInstall"
        }

        xWaitForADDomain DscForestWait
        {
            DomainName = 'waypoint.ifint.biz'
            DomainUserCredential = $cred
            RetryCount = 30
            RetryIntervalSec = 30
            DependsOn = "[xADDomain]FirstDS"
        }

        xADUser FirstUser
        {
            DomainName = 'waypoint.ifint.biz'
            DomainAdministratorCredential = $cred
            UserName = "daviddcadm"
            Password = $cred
            Ensure = "Present"
            DependsOn = "[xWaitForADDomain]DscForestWait"
        }
    }
}