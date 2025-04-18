FROM alpine:latest

WORKDIR /app

# Install mosquitto-clients, Python, and virtualenv
RUN apk add --no-cache mosquitto-clients python3 py3-pip && \
    ln -sf python3 /usr/bin/python && \
    python3 -m venv /app/venv && \
    /app/venv/bin/pip install --no-cache-dir --upgrade pip && \
    /app/venv/bin/pip install paho-mqtt requests

# Copy the test client script
COPY test-client.py /app/

# Set the virtual environment as the default Python environment
ENV PATH="/app/venv/bin:$PATH"

# Keep the container running
CMD ["tail", "-f", "/dev/null"]