@echo off

set ROOT=%~dp0

rem Apache Path
set ApachePath=%ROOT:~0,-6%

rem OutputPath
set OutputPath=%ApachePath%\conf\ssl

rem RootCA file name
set RootCAName=rsrootca

rem ###################################################################################
rem Make directory
mkdir C:\Windows\Temp\DassaultSystemes

rem Copy RootCA certificate
copy %ApachePath%\conf\ssl\%RootCAName%.crt C:\Windows\Temp\DassaultSystemes
