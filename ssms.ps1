#Download SSMS
Start-BitsTransfer https://download.microsoft.com/download/8/a/8/8a8073d2-2e00-472b-9a18-88361d105915/SSMS-Setup-ENU.exe -Destination C:\Temp\
#Instalace SSMS
Start-Process -FilePath 'C:\Temp\SSMS-Setup-ENU.exe' -ArgumentList '/install','/passive' -Wait