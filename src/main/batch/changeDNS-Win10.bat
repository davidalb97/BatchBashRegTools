@ECHO OFF
CALL :RequestAdminElevation "%~dpfs0" %* || goto:eof
GOTO :ChangeDns
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:RequestAdminElevation FilePath %* || goto:eof
:: 
:: By:   Cyberponk,     v1.5 - 10/06/2016 - Changed the admin rights test method from cacls to fltmc
::          v1.4 - 17/05/2016 - Added instructions for arguments with ! char
::          v1.3 - 01/08/2015 - Fixed not returning to original folder after elevation successful
::          v1.2 - 30/07/2015 - Added error message when running from mapped drive
::          v1.1 - 01/06/2015
:: 
:: Func: opens an admin elevation prompt. If elevated, runs everything after the function call, with elevated rights.
:: Returns: -1 if elevation was requested
::           0 if elevation was successful
::           1 if an error occured
:: 
:: USAGE:
:: If function is copied to a batch file:
::     call :RequestAdminElevation "%~dpf0" %* || goto:eof
::
:: If called as an external library (from a separate batch file):
::     set "_DeleteOnExit=0" on Options
::     (call :RequestAdminElevation "%~dpf0" %* || goto:eof) && CD /D %CD%
::
:: If called from inside another CALL, you must set "_ThisFile=%~dpf0" at the beginning of the file
::     call :RequestAdminElevation "%_ThisFile%" %* || goto:eof
::
:: If you need to use the ! char in the arguments, the calling must be done like this, and afterwards you must use %args% to get the correct arguments:
::      set "args=%* "
::      call :RequestAdminElevation .....   use one of the above but replace the %* with %args:!={a)%
::      set "args=%args:{a)=!%" 
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
setlocal ENABLEDELAYEDEXPANSION & set "_FilePath=%~1"
  if NOT EXIST "!_FilePath!" (echo/Read RequestAdminElevation usage information)
  :: UAC.ShellExecute only works with 8.3 filename, so use %~s1
  set "_FN=_%~ns1" & echo/%TEMP%| findstr /C:"(" >nul && (echo/ERROR: %%TEMP%% path can not contain parenthesis &pause &endlocal &fc;: 2>nul & goto:eof)
  :: Remove parenthesis from the temp filename
  set _FN=%_FN:(=%
  set _vbspath="%temp:~%\%_FN:)=%.vbs" & set "_batpath=%temp:~%\%_FN:)=%.bat"

  :: Test if we gave admin rights
  fltmc >nul 2>&1 || goto :_getElevation

  :: Elevation successful
  (if exist %_vbspath% ( del %_vbspath% )) & (if exist %_batpath% ( del %_batpath% )) 
  :: Set ERRORLEVEL 0, set original folder and exit
  endlocal & CD /D "%~dp1" & ver >nul & goto:eof

  :_getElevation
  echo/Requesting elevation...
  :: Try to create %_vbspath% file. If failed, exit with ERRORLEVEL 1
  echo/Set UAC = CreateObject^("Shell.Application"^) > %_vbspath% || (echo/&echo/Unable to create %_vbspath% & endlocal &md; 2>nul &goto:eof) 
  echo/UAC.ShellExecute "%_batpath%", "", "", "runas", 1 >> %_vbspath% & echo/wscript.Quit(1)>> %_vbspath%
  :: Try to create %_batpath% file. If failed, exit with ERRORLEVEL 1
  echo/@%* > "%_batpath%" || (echo/&echo/Unable to create %_batpath% & endlocal &md; 2>nul &goto:eof)
  echo/@if %%errorlevel%%==9009 (echo/^&echo/Admin user could not read the batch file. If running from a mapped drive or UNC path, check if Admin user can read it.)^&echo/^& @if %%errorlevel%% NEQ 0 pause >> "%_batpath%"

  :: Run %_vbspath%, that calls %_batpath%, that calls the original file
  %_vbspath% && (echo/&echo/Failed to run VBscript %_vbspath% &endlocal &md; 2>nul & goto:eof)

  :: Vbscript has been run, exit with ERRORLEVEL -1
  echo/&echo/Elevation was requested on a new CMD window &endlocal &fc;: 2>nul & goto:eof
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:ChangeDns
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
For /f "tokens=1,2,3*" %%a In ('netsh interface show interface ^| findstr "Enabled" ^| findstr "Connected" ^| findstr "Ethernet Wi-Fi"') Do (
	CALL :ClearAdapterDns "%%d"
)

GOTO :End

:ClearAdapterDns

SET "adaptersFound=y"

ECHO Setting IPv4 DNS for %1 adapter to automatic...
netsh interface ipv4 set dns %1 dhcp

ECHO Setting IPv6 DNS for %1 adapter to automatic...
netsh interface ipv6 set dns %1 dhcp

GOTO :EOF

:SetDns
For /f "tokens=1,2,3*" %%a In ('netsh interface show interface ^| findstr "Enabled" ^| findstr "Connected" ^| findstr "Ethernet Wi-Fi"') Do (
	CALL :SetAdapterDns "%%d"
)

GOTO :End

:SetAdapterDns

SET "adaptersFound=y"

ECHO Setting Primary IPv4 DNS for %1 adapter to %ipv4-1%...
netsh interface ipv4 set dnsservers name= %1 source= Static address= %ipv4-1%

ECHO Setting Secondary IPv4 DNS for %1 adapter to %ipv4-2%...
netsh interface ipv4 add dnsservers name= %1 address= %ipv4-2%
	
ECHO Setting Primary IPv6 DNS for %1 adapter to %ipv6-1%...
netsh interface ipv6 set dnsservers name= %1 source= Static address= %ipv6-1%

ECHO Setting Secondary IPv6 DNS for %1 adapter to %ipv6-1%...
netsh interface ipv6 add dnsservers name= %1 address= %ipv6-2%


GOTO :EOF

:End

IF DEFINED adaptersFound (ipconfig /flushdns) ELSE (ECHO No network adapters found!)

PAUSE