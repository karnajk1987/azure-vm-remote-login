Select-AzSubscription -SubscriptionId "dc0f47c5-3e96-400c-b001-f355e41f6eea"

#Provide the subscription Id of the subscription where snapshot is created
$subscriptionId = "dc0f47c5-3e96-400c-b001-f355e41f6eea"

#Provide the name of your resource group where snapshot is created
$resourceGroupName = "MAHSPRBC-RGP-0047-END0126-SMART_AUTOMATION"

#Provide the snapshot name 
$snapshotName = "ENP0067-FORR42_Snapshot_9-3-23"

#Provide Shared Access Signature (SAS) expiry duration in seconds e.g. 3600.
#Know more about SAS here: https://docs.microsoft.com/en-us/Az.Storage/storage-dotnet-shared-access-signature-part-1
$sasExpiryDuration = "96000"

#Provide storage account name where you want to copy the snapshot. 
$storageAccountName = "migrationmahs"

#Name of the storage container where the downloaded snapshot will be stored
$storageContainerName = "vhds"

#Provide the key of the storage account where you want to copy snapshot. 
$storageAccountKey = '57Ly9M5owBe6qGCueu0vkn2JfmTuFNiuVOv0+VHLHCpZmqu7BT1r247zk1EBLLZIGDxYUiEm2o7D+AStsSD4Dw=='

#Provide the name of the VHD file to which snapshot will be copied.
$destinationVHDFileName = "ENP0067-FORR42.vhd"

# Set the context to the subscription Id where Snapshot is created
Select-AzSubscription -SubscriptionId $SubscriptionId

#Generate the SAS for the snapshot 
$sas = Grant-AzSnapshotAccess -ResourceGroupName $ResourceGroupName -SnapshotName $SnapshotName  -DurationInSecond $sasExpiryDuration -Access Read
#Create the context for the storage account which will be used to copy snapshot to the storage account 
$destinationContext = New-AzStorageContext -StorageAccountName $storageAccountName -StorageAccountKey $storageAccountKey

#Copy the snapshot to the storage account 
Start-AzStorageBlobCopy -AbsoluteUri $sas.AccessSAS -DestContainer $storageContainerName -DestContext $destinationContext -DestBlob $destinationVHDFileName

#Use this for Copy Job Monitoring – replace X accordingly – use the largest disk for reference

$percentage = 0
do {
    Start-Sleep -s 15
    $status = Get-AzStorageBlobCopyState -Context $destinationContext -Container $storageContainerName -Blob $destinationVHDFileName
    $percentage = $status.BytesCopied / $status.TotalBytes * 100
    #$percentage = "{0:N2}" -f $percentage
    Write-Progress -Activity "Copy in progress" -Status "$percentage% Complete:" -PercentComplete $percentage;

} while ($percentage -lt 100)