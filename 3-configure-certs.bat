@echo off
echo Configuring certificate settings on SmartReader...
echo.

set SMARTREADER_IP=your-smartreader-ip
set USERNAME=admin
set PASSWORD=admin

echo Using SmartReader at: %SMARTREADER_IP%
echo.

curl -X POST -u %USERNAME%:%PASSWORD% -k ^
  -H "Content-Type: application/json" ^
  -d "{\"Enabled\": true, \"CertificatePath\": \"/customer/config/certificate/client.pfx\", \"CaCertificatePath\": \"/customer/config/ca/ca.crt\", \"Password\": \"smartreader\"}" ^
  https://%SMARTREADER_IP%:8443/api/mqtt/certificate/config

echo.
pause