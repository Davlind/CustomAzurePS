. (join-Path (Split-Path -Parent $MyInvocation.MyCommand.Path) helpers.ps1)

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
    $service = Get-AzureService -ServiceName $Name -ErrorAction SilentlyContinue
    if (!$service)
    {
        Write-Verbose "Creating Cloud Service: $serviceName in affinity group $AffinityGroup"
        $service = New-AzureService -ServiceName $Name -AffinityGroup $AffinityGroup
    }

    Write-VerboseCompleted $MyInvocation.MyCommand
    return $service
}