@echo off
rem ============================================================================================
rem =Change server IP addresses for lan and mdc in EXPRESSCLUSTER configuration file (clp.conf)=
rem ============================================================================================

if "%~1"=="" goto usage
if "%~2"=="" goto usage
if "%~3"=="" goto usage

pushd "C:\Program Files\EXPRESSCLUSTER\etc"

rem backup config file (clp.conf)
for /f "delims=" %%a in ('wmic OS Get localdatetime ^| find "."') do set DateTime=%%a
copy clp.conf clp%DateTime:~0,14%.conf

:continue

clpcfset add device "%~1" lan "%~2" "%~3"
clpcfset add device "%~1" mdc "%~2" "%~3"

popd

goto end

:usage
echo Usage: cfset.bat ^<server name^> ^<lan and mdc #^> ^<ip address^>
echo e.g. cfset.bat server1 0 192.168.1.1

:end
