configuration TestApplicationServerConfig
{
    param
    (
    )

    Node localhost {

        # Install the Web Server role
        WindowsFeature IIS
        {
            Ensure = "Present"
            Name = "Web-Server"
        }

        # Install the MSMQ Server role
        WindowsFeature MSMQ
        {
            Ensure = "Present"
            Name = "MSMQ-Server"
        }
    }
}