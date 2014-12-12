. .\Helpers.ps1

write-progress -activity 'Authenticating' -percentcomplete 0;

EnsureAuthentication

# Create Affinity group
write-progress -activity 'Creating Affinity Groups' -percentcomplete 10;

$ag = .\..\Config\affinityGroup.ps1
$existingAg = Get-AzureAffinityGroup | Select -ExpandProperty Name
$ag | % {$i=1;$len=$ag.length} {

    write-progress -id 1 -activity "Affinity group $i of $len" -percentcomplete ($i/$len*100)
    Start-Sleep 3
    if ($existingAg -notcontains $_.Name) {

        Write-Host ("Affinity group {0} does not exist. Creating..." -f $_.Name)

        New-AzureAffinityGroup @_
    }
    else {
        Write-Host ("Affinity group {0} already exist. Skipping..." -f $_.Name)
    }
    $i++
}
write-progress -id 1 -activity 'none' -completed

#Create Storage accounts
write-progress -activity 'Creating Storage' -percentcomplete 50;

$storage = .\..\Config\storage.ps1
$existingStorage = Get-AzureStorageAccount | Select -ExpandProperty StorageAccountName
$storage | % {$i=1;$len=$storage.length} {

    write-progress -id 1 -activity "Storage Account $i of $len" -percentcomplete ($i/$len*100)
    Start-Sleep 3
    if ($existingStorage -notcontains $_.StorageAccountName) {

        Write-Host ("Storage Account {0} does not exist. Creating..." -f $_.StorageAccountName)

        New-AzureStorageAccount @_
    }
    else {
        Write-Host ("Storage Account {0} already exist. Skipping..." -f $_.StorageAccountName)
    }
    $i++
}
write-progress -id 1 -activity 'none' -completed
