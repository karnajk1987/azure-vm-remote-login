Set-Item WSMan:\localhost\Service\Auth\Basic -Value $true
Set-Item WSMan:\localhost\Service\AllowUnencryptedTraffic -Value $true
Set-Item WSMan:\localhost\Client\TrustedHosts -Value ENP0067-USRR17 -Concatenate -Force
