@echo off
echo Uploading client certificate (PFX file) to SmartReader...
echo.

set SMARTREADER_IP=your-smartreader-ip
set USERNAME=admin
set PASSWORD=admin

echo Using SmartReader at: %SMARTREADER_IP%
echo.

curl -X POST -u %USERNAME%:%PASSWORD% -k ^
  -F "file=@./extracted-certs/client.pfx" ^
  https://%SMARTREADER_IP%:8443/upload/mqtt/certificate

echo.
pause