@echo off
echo Extracting certificates from Docker containers...

:: Create directory for extracted certificates
mkdir extracted-certs 2>nul
if %ERRORLEVEL% NEQ 0 echo Directory already exists, continuing...

:: Get cert-generator container ID
for /f "tokens=*" %%i in ('docker-compose ps -q cert-generator') do set CERT_GEN_ID=%%i
echo Cert Generator Container ID: %CERT_GEN_ID%

:: Extract CA certificate
echo Extracting CA certificate...
docker cp %CERT_GEN_ID%:/certs/ca/ca.crt ./extracted-certs/

:: Extract client PFX certificate
echo Extracting client PFX file...
docker cp %CERT_GEN_ID%:/certs/client/client.pfx ./extracted-certs/

:: Display PFX password
echo Retrieving PFX password...
docker-compose exec cert-generator cat /certs/client/pfx-password.txt

echo.
echo All certificates extracted to the 'extracted-certs' directory.
echo.

dir /b extracted-certs

pause