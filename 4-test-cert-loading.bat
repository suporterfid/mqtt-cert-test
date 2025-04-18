@echo off
echo Testing certificate loading on SmartReader...
echo.

set SMARTREADER_IP=your-smartreader-ip
set USERNAME=admin
set PASSWORD=admin

echo Using SmartReader at: %SMARTREADER_IP%
echo.

curl -X GET -u %USERNAME%:%PASSWORD% -k ^
  https://%SMARTREADER_IP%:8443/api/mqtt/certificate/test

echo.
pause