@echo off
echo Uploading CA certificate to SmartReader...
echo.

set SMARTREADER_IP=your-smartreader-ip
set USERNAME=admin
set PASSWORD=admin

echo Using SmartReader at: %SMARTREADER_IP%
echo.

curl -X POST -u %USERNAME%:%PASSWORD% -k ^
  -F "file=@./extracted-certs/ca.crt" ^
  https://%SMARTREADER_IP%:8443/upload/mqtt/ca

echo.
pause