# # Enable Windows VM
# Enable-AzVMPSRemoting -Name 'vm-win-01' -ResourceGroupName 'azure-cloudshell-demo' -Protocol https -OsType Windows

# Invoke-AzVMCommand -Name 'vm-win-01' -ResourceGroupName 'azure-cloudshell-demo' -ScriptBlock { get-service win* } -Credential (get-credential)

# Enter-AzVM -name 'vm-win-01' -ResourceGroupName 'azure-cloudshell-demo' -Credential (get-credential)
# Disable-AzVMPSRemoting -Name vm-win-02 -ResourceGroupName azure-cloudshell-demo



### Detailed script

# $vmName = "ENP0067-USRR17"
# $vmUsername = $env:VM_USERNAME
# $vmPassword = $env:VM_PASSWORD
# $newUsername = $env:NEW_USERNAME
# $newPassword = $env:NEW_PASSWORD

# $vmName = "ENP0067-USRR17"
$vmName = "20.120.33.54"
$vmUsername = "TECHADMIN"
$vmPassword = "QWERTYasdfg12345"
$newUsername = "techadmin"
$newPassword = "KAMISAMA@123@@"
$resource_group = "webapp-dev"

# Create a credential object
$credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $vmUsername, (ConvertTo-SecureString -String $vmPassword -AsPlainText -Force)

if (-not (Get-Module -ListAvailable -Name Az)) {
    # Install the Az module
    Write-Host "Installing Azure PowerShell module..."
    Install-Module -Name Az -AllowClobber -Scope CurrentUser -Force
}

# Import the Az module
Write-Host "Importing Azure PowerShell module..."
Import-Module -Name Az

# Update teh Az module
Update-Module -Name Az

# Check if the Invoke-AzVmRunCommand cmdlet is available
if (-not (Get-Command -Name Invoke-AzVmRunCommand -ErrorAction SilentlyContinue)) {
    throw "The 'Invoke-AzVmRunCommand' cmdlet is not available. Make sure you have the latest version of the Azure PowerShell module installed."
}

# # Enable Windows VM
# Enable-AzVMPSRemoting -Name $vmName -ResourceGroupName $resource_group -Protocol https -OsType Windows
Get-Service -Name WinRM
Start-Service -Name WinRM

Set-Item WSMan:\localhost\Client\TrustedHosts -Value "20.120.33.54" -Concatenate -Force

Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope LocalMachine

Enable-AzVMPSRemoting -Name $vmName -ResourceGroupName $resource_group -Protocol https -OsType Windows 

# Enable-PSRemoting -Force

# Invoke-AzVMCommand
# Invoke-AzVMCommand -Name $vmName -ResourceGroupName $resource_group -ScriptBlock { get-service win* } -Credential $credential

# # Enter-AzVM
# Enter-AzVM -name $vmName -ResourceGroupName $resource_group -Credential $credential
# # Establish a remote session to the VM
$session = New-PSSession -ComputerName $vmName -Credential $credential

# # Enter the remote session
Enter-PSSession -Session $session

# Create a new local user account
Invoke-Command -Session $session -ScriptBlock {
    $newUserParams = @{
        Name                 = $using:newUsername
        Password             = (ConvertTo-SecureString -String $using:newPassword -AsPlainText -Force)
        PasswordNeverExpires = $true
    }
    New-LocalUser @newUserParams
}

# Invoke the snapshot script
Write-Host "Invoke the snapshot script to take the snapshot and move it to RG"
$result = Invoke-AzVmRunCommand `
    -ResourceGroupName $resource_group `
    -VMName $vmName `
    -CommandId "RunPowerShellScript" `
    -ScriptPath "Powershell_Scripts/01_create_snapshot_to_mahs_rg.ps1"

Write-Host $($result.value.Message)




