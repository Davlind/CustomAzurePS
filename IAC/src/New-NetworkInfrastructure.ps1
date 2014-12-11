. .\Helpers.ps1

write-progress -activity 'Authenticating' -percentcomplete 0;

EnsureAuthentication

write-progress -activity 'Creating Virtual Network' -percentcomplete 20;

$networkFile = (Resolve-Path .\..\Config\Networks.netcfg)
Set-AzureVNetConfig -ConfigurationPath $networkFile
Write-Host "Virtual Network configuration has been applied"


$gateway = .\..\Config\gateway.ps1
$gateway | % {$i=1;$len=$gateway.length} {
    New-AzureVNetGateway @_

    $i++
}
write-progress -id 1 -activity 'none' -completed