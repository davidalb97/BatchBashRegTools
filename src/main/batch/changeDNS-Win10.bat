@ECHO OFF
SETLOCAL

set "adaptersFound="

CLS
ECHO 1.Automatic
ECHO 2.Google DNS
ECHO 3.CloudFlare DNS
ECHO 4.Open Dns
ECHO.

CHOICE /C 1234 /M "Enter your choice:"

:: Note - list ERRORLEVELS in decreasing order
IF ERRORLEVEL 4 GOTO OpenDns
IF ERRORLEVEL 3 GOTO CloudFlareDns
IF ERRORLEVEL 2 GOTO GoogleDns
IF ERRORLEVEL 1 GOTO ClearDns

:GoogleDns
SET ipv4-1=8.8.8.8
SET ipv4-2=8.8.4.4
SET ipv6-1=2001:4860:4860::8888
SET ipv6-2=2001:4860:4860::8844
GOTO SetDns

:CloudFlareDns
SET ipv4-1=1.1.1.1
SET ipv4-2=1.0.0.1
SET ipv6-1=2606:4700:4700::1111
SET ipv6-2=2606:4700:4700::1001
GOTO SetDns

:OpenDns
SET ipv4-1=208.67.222.222
SET ipv4-2=208.67.220.220
SET ipv6-1=2620:119:35::35
SET ipv6-2=2620:119:53::53
GOTO SetDns

:ClearDns
netsh interface show interface | findstr "Enabled" | findstr "Connected" | findstr "Ethernet" >NUL
if %ERRORLEVEL% equ 0 CALL :ClearAdapterDns "Ethernet"

netsh interface show interface | findstr "Enabled" | findstr "Connected" | findstr "Wi-Fi" >NUL
if %ERRORLEVEL% equ 0 CALL :ClearAdapterDns "Wi-Fi"

GOTO :End

:ClearAdapterDns

SET "adaptersFound=y"

ECHO Setting IPv4 DNS for %~1 adapter to automatic...
netsh interface ipv4 set dns %~1 dhcp

ECHO Setting IPv6 DNS for %~1 adapter to automatic...
netsh interface ipv6 set dns %~1 dhcp

GOTO :EOF

:SetDns
netsh interface show interface | findstr "Enabled" | findstr "Connected" | findstr "Ethernet" >NUL
if %ERRORLEVEL% equ 0 CALL :SetAdapterDns "Ethernet"

netsh interface show interface | findstr "Enabled" | findstr "Connected" | findstr "Wi-Fi" >NUL
if %ERRORLEVEL% equ 0 CALL :SetAdapterDns "Wi-Fi"

GOTO :End

:SetAdapterDns

SET "adaptersFound=y"

ECHO Setting Primary IPv4 DNS for %~1 adapter to %ipv4-1%...
netsh interface ipv4 set dnsservers name= %~1 source= Static address= %ipv4-1%

ECHO Setting Secondary IPv4 DNS for %~1 adapter to %ipv4-2%...
netsh interface ipv4 add dnsservers name= %~1 address= %ipv4-2%
	
ECHO Setting Primary IPv6 DNS for %~1 adapter to %ipv6-1%...
netsh interface ipv6 set dnsservers name= %~1 source= Static address= %ipv6-1%

ECHO Setting Secondary IPv6 DNS for %~1 adapter to %ipv6-1%...
netsh interface ipv6 add dnsservers name= %~1 address= %ipv6-2%


GOTO :EOF

:End

IF DEFINED adaptersFound (ipconfig /flushdns) ELSE (ECHO No network adapters found!)

PAUSE