@echo off
echo ===== MQTT Certificate Authentication Troubleshooting =====

echo.
echo === Certificate Generator Status ===
docker-compose logs cert-generator | findstr /n .* | findstr /b ".*[0-9][0-9][0-9][0-9]:" 

echo.
echo === Mosquitto Broker Status ===
docker-compose logs mosquitto | findstr /n .* | findstr /b ".*[0-9][0-9][0-9][0-9]:"

echo.
echo === Certificate Paths ===
docker-compose exec mosquitto ls -la /mosquitto/certs

echo.
echo === Testing Mosquitto TLS Configuration ===
docker-compose exec mqtt-client openssl s_client -connect mosquitto:8883 -showcerts

echo.
echo === Testing Client Certificate ===
docker-compose exec mqtt-client openssl verify -CAfile /app/certs/ca/ca.crt /app/certs/client/client.crt

echo.
echo === PFX Certificate Info ===
docker-compose exec mqtt-client openssl pkcs12 -info -in /app/certs/client/client.pfx -noout -passin pass:smartreader

echo.
echo ===== Troubleshooting Complete =====
pause