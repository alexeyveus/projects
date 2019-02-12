#Login-AzureRMAccount
$subscriptionName = "*"
$ResourceGroupName = "*"
$storageAccountName = "*"
$storageAccountKey = (Get-AzureRmStorageAccountKey -AccountName $storageAccountName -ResourceGroupName $ResourceGroupName).key1
$srcContainerName = "vhds"
$dstContainerName = "vhds"
$srcBlob = "*.vhd"
$dstBlob = "*.vhd"

Select-AzureRmSubscription -SubscriptionName $subscriptionName
$Context = New-AzureStorageContext -StorageAccountName $storageAccountName -StorageAccountKey $storageAccountKey
Start-AzureStorageBlobCopy -SrcContainer $srcContainerName -DestContainer $dstContainerName -SrcBlob $srcBlob -DestBlob $dstBlob -Context $Context -DestContext $Context