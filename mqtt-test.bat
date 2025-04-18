@echo off
echo MQTT Client Test Script
echo ---------------------
echo.

if "%1"=="sub" (
    echo Subscribing to test topic...
    docker-compose exec mqtt-client python /app/test-client.py --mode sub --topic smartreader/test
) else if "%1"=="pub" (
    echo Publishing test message...
    docker-compose exec mqtt-client python /app/test-client.py --mode pub --topic smartreader/test --message "Certificate auth works!"
) else (
    echo Usage options:
    echo   mqtt-test.bat sub    - Subscribe to test topic
    echo   mqtt-test.bat pub    - Publish test message
    echo.
    echo Note: You need to run the subscriber in one command prompt
    echo       and the publisher in another command prompt.
)

pause