Connect-AzureRmAccount
$resourceGroup = "*"
$vmName = "*"
$vm = Get-AzureRmVM -ResourceGroupName $resourceGroup -VMName $vmName 
$vm.HardwareProfile.VmSize = "Standard_D12_v2"
Update-AzureRmVM -VM $vm -ResourceGroupName $resourceGroup