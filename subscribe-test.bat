@echo off
echo Subscribing to topic "test/topic" using mqtt-client...

docker exec -it mqtt-client mosquitto_sub ^
  --cafile /app/certs/ca.crt ^
  --cert /app/certs/client.crt ^
  --key /app/certs/client.key ^
  -h mqtt-broker ^
  -p 8883 ^
  -t test/topic

pause