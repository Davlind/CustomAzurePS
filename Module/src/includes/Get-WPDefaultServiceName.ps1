function Get-WPDefaultServiceName {
    [CmdletBinding(SupportsShouldProcess=$true)]
    param (
        [Parameter(Position=1)]
        [string]$Name
    )

    $services = Get-AzureService | select -ExpandProperty ServiceName

    for ($i=1; $i -le 999; $i++)
    {
        $serviceName = "ifwp{0}{1:D3}svc" -f $Name, $i

        if ($services -notcontains $serviceName)
        {
            return $serviceName
        }
    }

    throw "A service name could not be generated as there is already 999 in use. Why U have so many?"
}