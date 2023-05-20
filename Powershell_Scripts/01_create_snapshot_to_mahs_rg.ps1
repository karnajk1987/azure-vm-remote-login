#Connect to Azure account and select subscription
Connect-AzAccount
Select-AzSubscription -SubscriptionId "58f58984-c7ec-4128-9dcf-9b5d77697c3d"

#Set variables
$resourceGroupName = 'webapp-dev'
$location = 'eastus'
$vmName = 'ENP0067-USRR17'
$snapshotName = 'ENP0067-USRR17.vhd'
$resourceGroupName2 = 'webapp-qa'

#Get the virtual machine object
$vm = Get-AzVM `
    -ResourceGroupName $resourceGroupName `
    -Name $vmName

#Create a snapshot configuration object
$snapshot = New-AzSnapshotConfig `
    -AccountType Standard_LRS `
    -SourceUri $vm.StorageProfile.OsDisk.ManagedDisk.Id `
    -Location $location `
    -CreateOption copy

#Create a new snapshot
New-AzSnapshot `
    -Snapshot $snapshot `
    -SnapshotName $snapshotName `
    -ResourceGroupName $resourceGroupName2
