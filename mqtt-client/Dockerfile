# mqtt-client/Dockerfile
FROM python:3.9-slim

WORKDIR /app

RUN pip install paho-mqtt requests

COPY test-client.py /app/

CMD ["tail", "-f", "/dev/null"]