configuration BuildServerConfig
{
    param
    (
    )

    Import-DscResource -ModuleName xPSDesiredStateConfiguration

    Node localhost {

        xRemoteFile DownloadTeamCity
        {
            Uri = "https://ifwpdsc.blob.core.windows.net/files/TeamCity-9.0.2.exe?sv=2014-02-14&sr=b&sig=FQbwDhbXxLMHdFN7pMZLd4h7FlLlaLEHnC%2FUbz2y3G0%3D&se=2035-02-02T14%3A55%3A32Z&sp=r"
            DestinationPath = "C:\download\TeamCity-9.0.2.exe"
        }
    }
}