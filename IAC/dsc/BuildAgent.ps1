Configuration BuildAgentConfig
{

    # Import DSC WebAdmin Module from DSC Resource Kit
    Import-DscResource -ModuleName xWebAdministration

    Node ("localhost")
    {

        # Install the Web Server role
        WindowsFeature IIS
        {
            Ensure = "Present"
            Name = "Web-Server"
        }
    }
}