net localgroup "Remote Desktop Users" /add "AzureAD\artur.kraina@aaaauto.cz"
﻿net localgroup "Remote Desktop Users" /add "AzureAD\tomas.graffe@aaaauto.cz"
﻿net localgroup "Remote Desktop Users" /add "AzureAD\dusan.prochazka@aaaauto.cz"
﻿net localgroup "Remote Desktop Users" /add "AzureAD\ondrej.hrudnik@aaaauto.cz"
net localgroup "Remote Desktop Users" /add "AzureAD\ladislav.fiser@aaaauto.cz"
net localgroup "Remote Desktop Users" /add "AzureAD\lukas.cernoch@aaaauto.cz"

$path = 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp'
Set-ItemProperty -Path $path -Name UserAuthentication -Type DWord -Value 0
