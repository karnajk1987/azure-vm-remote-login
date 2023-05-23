
$vmName = "ENP0067-USRR17"
$vmUsername = "TECHADMIN"
$vmPassword = "QWERTYasdfg12345"
$newUsername = "techadmin"
$newPassword = "KAMISAMA@123@@"
$resource_group = "mahsprbc-rgp-0047-enp0067-smart_automation"
$trustedHost = "ENP0067-USRR17"
$RemoteDeviceName = "ENP0067-USRR17"
$IPRemoteDeviceName = "52.150.13.114"


# Create a credential object
$credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $vmUsername, (ConvertTo-SecureString -String $vmPassword -AsPlainText -Force)


#region WinRM

#verify that WinRM is setup and configured locally
Test-WSMan

# Set-Item WSMan:\localhost\Client\TrustedHosts -Value $trustedHost -Concatenate -Force

# check winrm settings
winrm get winrm/config/client
winrm get winrm/config/service

winrm enumerate winrm/config/listener


#verify that WinRM is setup and responding on a remote device
#you must specify the authentication type when testing a remote device.
#if you are unsure about the authentication, set it to Negotiate
# $credential = Get-Credential
Test-WSMan $RemoteDeviceName -Authentication Negotiate -Credential $credential

#verify local device is listening on WinRM port
Get-NetTCPConnection -LocalPort 5985

#verify a remote device is listening on WinRM port
Test-NetConnection -Computername $IPRemoteDeviceName -Port 5985

#establish an interactive remote session
# $credential = Get-Credential
# Enter-PSSession -ComputerName RemoteDeviceName -Credential $credential

#basic session opened to remote device
$sessions = New-PSSession -ComputerName $RemoteDeviceName -Credential $credential

#endRegion

#region Invoke-Command examples

#get the number of CPUs for each remote device
Invoke-Command -Session $sessions -ScriptBlock { (Get-CimInstance Win32_ComputerSystem).NumberOfLogicalProcessors }

#get the amount of free space on the C: drive for each remote device
Invoke-Command -Session $sessions -ScriptBlock {
    Invoke-Expression -Command "Powershell_Scripts/01_create_snapshot_to_mahs_rg.ps1"
}

# $invokeSplat = @{
#     ComputerName  = $servers
#     Credential    = $creds
#     ErrorVariable = 'connectErrors'
#     ErrorAction   = 'SilentlyContinue'
# }
# #capture any connection errors
# $remoteFailures = $connectErrors.CategoryInfo `
# | Where-Object { $_.Reason -eq 'PSRemotingTransportException' } `
# | Select-Object TargetName, @{n = 'ErrorInfo'; E = { $_.Reason } }

#endregion
