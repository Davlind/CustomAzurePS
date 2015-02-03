function New-WPRemoteDesktopManagerFile {
    [CmdletBinding(SupportsShouldProcess=$true)]
    param (
        [string] $Path
    )

    [xml]$xml = Get-DummyXml

    if ($Path) {
        [xml]$xml = Get-Content $Path
    } else {
        $Path = ([System.IO.Path]::GetTempFileName() + '.rdg')
    }

    

    $azureGroup = $xml.RDCMan.file.group | ? { $_.properties.name -eq 'Azure' }
    if (!$azureGroup) {
        Write-Host "No Azure group found. Add a group called ""Azure"" at the root."

        return
    }

    Write-Host "Gathering data. This might take several minutes..."

    $azureGroup = $azureGroup | ? { $_.properties }

    foreach($server in $azureGroup.server) {
        $azureGroup.RemoveChild($server) | out-null
    }
    foreach($group in $azureGroup.group) {
        $azureGroup.RemoveChild($group)  | out-null
    }
    Create-SubscriptionGroups $azureGroup

    [xml]$xml.Save($Path)
    Start-Process $Path

   # $tmp = [xml]$xml.OuterXml
   # Format-Xml -InputObject $tmp
}

function Create-ResourceGroups {
    [CmdletBinding(SupportsShouldProcess=$true)]
    param (
        [System.Xml.XmlElement] $RootNode,
        [string] $Subnet,
        $Resources
    )

    $Resources | ? { $_.Subnet -eq $Subnet } | group ResourceGroup | % {
        $currentRootNode = $RootNode

        if ($_.Count -gt 1) {
            Write-Host "        Creating Resource Group: $($_.Name)"
            $currentRootNode = Create-GroupNode -RootNode $currentRootNode -Name $_.Name
        }

        $_.Group | % {
            if ($currentRootNode -ne $RootNode) {
                Write-Host "    " -NoNewline
            }

            Write-Host "        Creating Server: $($_.Name)"
            Create-ServerNode -VM $_ -RootNode $currentRootNode
        }
    }
}

function Create-Subnet {
    [CmdletBinding(SupportsShouldProcess=$true)]
    param (
        [System.Xml.XmlElement] $RootNode,
        [string] $Subscription
    )

    Select-AzureSubscription -SubscriptionName $Subscription


    Switch-AzureMode AzureResourceManager -Verbose:$false
    $resourceGroups = @{}
    Get-AzureResource | ? { $_.ResourceType -eq 'Microsoft.ClassicCompute/virtualMachines'} | % {
        $resourceGroups.Add($_.Name, $_.ResourceGroupName)
    }

    Switch-AzureMode AzureServiceManagement -Verbose:$false
    $resources = Get-AzureVM
    $resources | % {
        $_ | Add-Member -NotePropertyName SubNet -NotePropertyValue (Get-AzureSubnet -VM $_)
        $_ | Add-Member -NotePropertyName ResourceGroup -NotePropertyValue $resourceGroups[$_.Name]
    }

    $subnets = $resources | group SubNet -NoElement | select -ExpandProperty Name

    $subnets | % {
        Write-Host "    Creating Group for Subnet: $_"
        $subnetNode = Create-GroupNode -RootNode $RootNode -Name $_

        Create-ResourceGroups -RootNode $subnetNode -Resources $resources -Subnet $_
    }
}

function Create-SubscriptionGroups {
    [CmdletBinding(SupportsShouldProcess=$true)]
    param (
        [System.Xml.XmlElement] $AzureGroup
    )

    $subscriptions = Get-AzureSubscription | ? { $_.SubscriptionName -like "Waypoint*" }

    $subscriptions | % {

        Write-Host "Creating Group for Subscription: $($_.SubscriptionName)"
        $subscriptionNode = Create-GroupNode -RootNode $azureGroup -Name $_.SubscriptionName

        Create-Subnet -RootNode $subscriptionNode -Subscription $_.SubscriptionName
    }

}

function Create-GroupNode {
    [CmdletBinding(SupportsShouldProcess=$true)]
    param (
        [System.Xml.XmlElement] $RootNode,
        [string] $Name
    )

        [xml] $node = "<group>
            <properties>
                <name>$Name</name>
                <expanded>True</expanded>
                <comment />
                <logonCredentials inherit=""FromParent"" />
                <connectionSettings inherit=""FromParent"" />
                <gatewaySettings inherit=""FromParent"" />
                <remoteDesktop inherit=""FromParent"" />
                <localResources inherit=""FromParent"" />
                <securitySettings inherit=""FromParent"" />
                <displaySettings inherit=""FromParent"" />
            </properties>
        </group>"

        $importNode = $rootNode.OwnerDocument.ImportNode($node.DocumentElement, $true);

        $newNode = $rootNode.AppendChild($importNode)

        return $newNode
}

function Create-ServerNode {
    [CmdletBinding(SupportsShouldProcess=$true)]
    param (
        [System.Xml.XmlElement] $RootNode,
        $VM
    )

        $name = $VM.IPaddress
        if (!$name) { $name = $VM.Name }

        [xml] $node = "<server>
                <name>$name</name>
                <displayName>$($VM.Name) - ($($VM.IpAddress))</displayName>
                <comment />
                <logonCredentials inherit=""FromParent"" />
                <connectionSettings inherit=""FromParent"" />
                <gatewaySettings inherit=""FromParent"" />
                <remoteDesktop inherit=""FromParent"" />
                <localResources inherit=""FromParent"" />
                <securitySettings inherit=""FromParent"" />
                <displaySettings inherit=""FromParent"" />
            </server>"

        $importNode = $rootNode.OwnerDocument.ImportNode($node.DocumentElement, $true);

        $null = $rootNode.AppendChild($importNode)
}

function Get-DummyXml {
    return [xml]"<?xml version=""1.0"" encoding=""utf-8""?>
<RDCMan schemaVersion=""1"">
  <version>2.2</version>
  <file>
    <properties>
      <name>RDC</name>
      <expanded>True</expanded>
      <comment />
      <logonCredentials inherit=""FromParent"" />
      <connectionSettings inherit=""FromParent"" />
      <gatewaySettings inherit=""FromParent"" />
      <remoteDesktop inherit=""None"">
        <size>1024 x 768</size>
        <sameSizeAsClientArea>True</sameSizeAsClientArea>
        <fullScreen>False</fullScreen>
        <colorDepth>32</colorDepth>
      </remoteDesktop>
      <localResources inherit=""None"">
        <audioRedirection>0</audioRedirection>
        <audioRedirectionQuality>0</audioRedirectionQuality>
        <audioCaptureRedirection>0</audioCaptureRedirection>
        <keyboardHook>2</keyboardHook>
        <redirectClipboard>True</redirectClipboard>
        <redirectDrives>True</redirectDrives>
        <redirectPorts>False</redirectPorts>
        <redirectPrinters>False</redirectPrinters>
        <redirectSmartCards>False</redirectSmartCards>
      </localResources>
      <securitySettings inherit=""FromParent"" />
      <displaySettings inherit=""FromParent"" />
    </properties>
    <group>
      <properties>
        <name>Azure</name>
        <expanded>True</expanded>
        <comment />
        <logonCredentials inherit=""FromParent"" />
        <connectionSettings inherit=""FromParent"" />
        <gatewaySettings inherit=""FromParent"" />
        <remoteDesktop inherit=""FromParent"" />
        <localResources inherit=""FromParent"" />
        <securitySettings inherit=""FromParent"" />
        <displaySettings inherit=""FromParent"" />
      </properties>
    </group>
  </file>
</RDCMan>"    
}

try {
    Export-ModuleMember -Function New-WPRemoteDesktopManagerFile -ErrorAction Ignore
}
catch {
    # In case this is ran as a dot-script
}
