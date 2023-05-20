
$RGName = "webapp-prod-p01"
$SubID = "58f58984-c7ec-4128-9dcf-9b5d77697c3d"
Set-AzContext -Subscription $SubID


$vmNames = @(
    "AZ-VM-00-0",
    "AZ-VM-00-1"
)

$nicNames = @(
    "AZ-VM-00-NIC-0",
    "AZ-VM-00-NIC-1"
)

Write-Host -ForegroundColor Cyan 'Stop the VM To be Removed...'
foreach ($vmName in $vmNames) {
    $vm = Get-AzVm -Name $vmName
    Write-Host -ForegroundColor Cyan 'Stop Virtual Machine-' $vmName 'in Resource Group-'$RGName '...'
    Stop-AzVM -Name $vmName -ResourceGroupName $RGName -Force
    }

Write-Host -ForegroundColor Cyan 'Remove the VM ...'
foreach ($vmName in $vmNames) {
    $vm = Get-AzVm -Name $vmName
    Write-Host -ForegroundColor Cyan 'Removing Virtual Machine-' $vmName 'in Resource Group-'$RGName '...'
    $null = $vm | Remove-AzVM -Force
}

Write-Host -ForegroundColor Cyan 'Removing Network Interface Cards, used by the VM...'
foreach ($nicName in $nicNames)  {
    $resource = Get-AzResource -Name $nicName
    Write-Host "NIC_RG_Name: $($resource.ResourceGroupName)"
    Write-Host "NicName: $($nicName)"
    Remove-AzNetworkInterface -Name $nicName -ResourceGroupName $resource.ResourceGroupName -Force
}







