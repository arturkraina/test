net localgroup "Remote Desktop Users" /add "AzureAD\artur.kraina@aaaauto.cz"

$path = 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp'
Set-ItemProperty -Path $path -Name UserAuthentication -Type DWord -Value 0