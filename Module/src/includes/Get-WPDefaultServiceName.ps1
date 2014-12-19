function Get-WPDefaultServiceName {
    [CmdletBinding(SupportsShouldProcess=$true)]
    param (
        [Parameter(Position=1)]
        [string]$Name
    )

    $services = Get-AzureService | select -ExpandProperty ServiceName

    $nextIndex = -1

    for ($i=1; $i -le 999; $i++)
    {
        $serviceName = "ifwp{0}{1:D3}svc" -f $Name, $i

        if ($services -notcontains $serviceName)
        {
            
            return @{
                ServiceName = $serviceName
                StorageAccountName = ("ifwp{0}{1:D3}stor" -f $Name, $i).ToLower()
                VirtualMachineName = "ifwp{0}{1:D3}vm{{0:D2}}" -f $Name, $i
            }
        }
    }

    throw "A service name could not be generated as there is already 999 in use. Why U have so many?"
}