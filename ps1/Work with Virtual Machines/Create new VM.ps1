#Login-AzureRMAccount
$vmSizeTypeSmall = "Standard_DS11_v2"
$vmSizeTypeMedium = "Standard_DS12_v2"

function createNewVM
{
    param ($vmName, $vmSize) 
    $subscriptionName = "*"
    $rgNameVM = "*"
    $storageAccountName = "*"
    $storageAccountKey = (Get-AzureRmStorageAccountKey -name $storageAccountName -ResourceGroupName $rgNameVM).Value[0]
    $srcContainerName = "vhds"
    $dstContainerName = "vhds"

    $vmSizeType = $vmSize

    $srcBlob = "*.vhd"
    $dstBlob = $vmName+'.vhd'
    
    Select-AzureRmSubscription -SubscriptionName $subscriptionName
    $Context = New-AzureStorageContext -StorageAccountName $storageAccountName -StorageAccountKey $storageAccountKey
    
    Write-Host "Coping source vhd: $srcBlob to destination vhd: $dstBlob ..."
    Start-AzureStorageBlobCopy -SrcContainer $srcContainerName -DestContainer $dstContainerName -SrcBlob $srcBlob -DestBlob $dstBlob -Context $Context -DestContext $Context
    write-host "Done"

    $rgNamevNet = "*"
    $location = "*"
    $vNetName = "*"
    $vNetsubnet = "*"
    $nsgName = "*"
    $subcriptionID = "*"
    $ipName = $vmName+'-ip'
    $nicName = $vmName+'-nic'

    $Vnet = Get-AzureRmVirtualNetwork -Name $vNetName -ResourceGroupName $rgNamevNet
    $backEnd = $Vnet.Subnets|?{$_.Name -eq $vNetsubnet}

    write-host "Creating new virtual Public IP: $ipName ..."
    $pip = New-AzureRmPublicIpAddress -Name $ipName -ResourceGroupName $rgNameVM -Location $location -AllocationMethod Dynamic
    write-host "Done"

    write-host "Creating new virtual NIC: $nicName ..."
    $newNic = New-AzureRmNetworkInterface -ResourceGroupName $rgNameVM -Name $nicName -Location $location -SubnetId $backEnd.Id -PublicIpAddressId $pip.Id
    $nsg = Get-AzureRmNetworkSecurityGroup -ResourceGroupName $rgNameVM -Name $nsgName
    $newNic.NetworkSecurityGroup = $nsg
    Set-AzureRmNetworkInterface -NetworkInterface $newNic
    write-host "Done"

    write-host "Creating new VM: $vmName ..."
    $vmConfig = New-AzureRmVMConfig -VMName $vmName -VMSize $vmSizeType
    $vm = Add-AzureRmVMNetworkInterface -VM $vmConfig -Id $newNic.Id
    $osDiskUri = 'https://'+$storageAccountName+'.blob.core.windows.net/vhds/'+$vmName+'.vhd'
    $osDiskName = $vmName + "osDisk"
    $vm = Set-AzureRmVMOSDisk -VM $vm -Name $osDiskName -VhdUri $osDiskUri -CreateOption attach -Windows
    New-AzureRmVM -ResourceGroupName $rgNameVM -Location $location -VM $vm
    write-host "Done"
}

for($i=1;$i -le 1;$i++)
{
    Write-Host "---------------------------------------------------"
    $vmNamef= '*'+$i+'*'
    $vmSizef = $vmSizeTypeSmall
    createNewVM $vmNamef $vmSizef
}