#Retrieve windows server core + IIS + asp.net with .NET Framework 4.8 image
FROM mcr.microsoft.com/dotnet/framework/aspnet:4.8-windowsservercore-ltsc2019
#Copy binaries to folder
ARG source
WORKDIR /inetpub/OrderingApi
COPY ${source} .
#Configure IIS : remove default WebSite, Add new OrderingApi WebSite, Add new OrderingApi AppPool, 
SHELL [ "powershell" ]
RUN Remove-WebSite -Name 'Default Web Site'; \
New-WebAppPool -Name OrderingApi; \
Set-ItemProperty -Path IIS:\AppPools\OrderingApi managedRuntimeVersion "v4.0"; \
New-WebSite -Name "OrderingApi" -Port 80 -PhysicalPath "$Env:systemdrive\inetpub\OrderingApi" -ApplicationPool OrderingApi;
#Install IIS URL Rewrite
ADD http://download.microsoft.com/download/D/D/E/DDE57C26-C62C-4C59-A1BB-31D58B36ADA2/rewrite_amd64_en-US.msi c:/inetpub/rewrite_amd64_en-US.msi
RUN Start-Process c:/inetpub/rewrite_amd64_en-US.msi -ArgumentList "/qn" -Wait
#Enable IIS root detailed errors remotely
RUN Set-WebConfiguration -Filter '/system.webServer/httpErrors' -PSPath 'IIS:\\' -Value @{errorMode='Detailed'};

# #Install Remote IIS management
# RUN Install-WindowsFeature Web-Mgmt-Service; \
# New-ItemProperty -Path HKLM:\software\microsoft\WebManagement\Server -Name EnableRemoteManagement -Value 1 -Force; \
# Set-Service -Name wmsvc -StartupType automatic;
# #Add user for Remote IIS Manager Login
# RUN net user iisadmin Password~1234 /ADD; \
# net localgroup administrators iisadmin /add;\ 
# net localgroup 'Event Log Readers' iisadmin /add;