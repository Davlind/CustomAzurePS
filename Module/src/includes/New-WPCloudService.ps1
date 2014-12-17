

function New-WPCloudService {
    [CmdletBinding(SupportsShouldProcess=$true)]
    param (
        [Parameter(Position=1, Mandatory=$true)]
        [string]$Name,

        [Parameter(Position=2, Mandatory=$true)]
        [string]$AffinityGroup
    )

    Write-VerboseBegin $MyInvocation.MyCommand

    # Create Cloud Service
    $serviceName = 'ifwp' + $Name + 'svc'
    $service = Get-AzureService -ServiceName $serviceName -ErrorAction SilentlyContinue
    if (!$service)
    {
        Write-Verbose "Creating Cloud Service: $serviceName in affinity group $AffinityGroup"
        $service = New-AzureService -ServiceName $serviceName -AffinityGroup $AffinityGroup
    }

    Write-VerboseCompleted $MyInvocation.MyCommand
    return $service
}