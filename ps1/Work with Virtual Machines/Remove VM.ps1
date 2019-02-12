Login-AzureRMAccount

function removeVM($vmName)
{
    $rgName = '*'
    $vm = Get-AzureRMVM –Name $vmName –ResourceGroupName $rgName
 
    #Getting the VM ID. This is required to find the associated boot diagnostics container.
    $AzureRMResourceParams = @{
    'ResourceName' = $vmName
    'ResourceType' = 'Microsoft.Compute/virtualMachines'
    'ResourceGroupName' = $rgName
    }
    $vmResource = Get-AzureRMResource @AzureRMResourceParams
    $vmId = $vmResource.Properties.VmId

    write-host "Removing the boot diagnostics storage container..."
    $diagSa = [regex]::match($vm.DiagnosticsProfile.bootDiagnostics.storageUri, '^http[s]?://(.+?)\.').groups[1].value
    $diagContainerName = ('bootdiagnostics-{0}-{1}' -f $vm.Name.ToLower().Substring(0, 9), $vmId)
    $diagSaRg = (Get-AzureRMStorageAccount | where { $_.StorageAccountName -eq $diagSa }).ResourceGroupName
    $saParams = @{
        'ResourceGroupName' = $diagSaRg
        'Name' = $diagSa
    }            
    Get-AzureRMStorageAccount @saParams | Get-AzureRMStorageContainer | where { $_.Name-eq $diagContainerName } | Remove-AzureRMStorageContainer –Force

    write-host 'Removing the VM'$vmName' ...'
    $vm | Remove-AzureRMVM –Force

    $NIC = $vm.NetworkProfile.NetworkInterfaces[0].Id -replace '.*\/'
    $NI = Get-AzureRmNetworkInterface -Name $NIC -ResourceGroupName $rgName
    $NIIC = Get-AzureRmNetworkInterfaceIpConfig -NetworkInterface $NI
    $PIP = $NIIC.PublicIpAddress.Id -replace '.*\/'
 
    write-host "Removing the VM network interface $NIC ..."
    Remove-AzureRmNetworkInterface -Name $NIC -ResourceGroup $rgName -Force
    write-host "Removing the PublicIpAddress $PIP ..."
    Remove-AzureRmPublicIpAddress -Name $PIP -ResourceGroupName $rgName -Force
  			
    $osDiskUri = $vm.StorageProfile.OSDisk.Vhd.Uri
    $osDiskContainerName = $osDiskUri.Split('/')[-2]

    $str=$osDiskUri.Split('/')[-1]
    write-host "Removing the Operating System VHD-disk $str ..."
    $osDiskStorageAcct = Get-AzureRMStorageAccount | where { $_.StorageAccountName -eq $osDiskUri.Split('/')[2].Split('.')[0] }
    $osDiskStorageAcct | Remove-AzureStorageBlob -Container $osDiskContainerName -Blob $osDiskUri.Split('/')[-1]
    Write-Host 'VM removing complete.'
}

for($i=1;$i -le 1;$i++)
{
    Write-Host "-----------------------------------------------------"
    $vmNamef='*'+$i+'*'
    removeVM($vmNamef)
}