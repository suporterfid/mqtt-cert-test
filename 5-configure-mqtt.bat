@echo off
echo Configuring MQTT settings on SmartReader...
echo.

set SMARTREADER_IP=your-smartreader-ip
set DOCKER_HOST_IP=your-docker-host-ip
set USERNAME=admin
set PASSWORD=admin

echo Using SmartReader at: %SMARTREADER_IP%
echo Using Docker host at: %DOCKER_HOST_IP%
echo.

curl -X POST -u %USERNAME%:%PASSWORD% -k ^
  -H "Content-Type: application/json" ^
  -d "{\"mqttEnabled\": \"1\", \"mqttBrokerAddress\": \"%DOCKER_HOST_IP%\", \"mqttBrokerPort\": \"8883\", \"mqttBrokerProtocol\": \"mqtts\", \"mqttClientCertificateEnabled\": \"1\", \"mqttTagEventsTopic\": \"smartreader/events/tags\", \"mqttTagEventsQoS\": \"1\"}" ^
  https://%SMARTREADER_IP%:8443/api/settings

echo.
pause