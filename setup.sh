#!/bin/bash
set -e

# Create required directories
mkdir -p mosquitto/config cert-generator mqtt-client

# Create mosquitto.conf
cat > mosquitto/config/mosquitto.conf << 'EOF'
# Basic configuration
persistence true
persistence_location /mosquitto/data/
log_dest file /mosquitto/log/mosquitto.log
log_type all

# Port configurations
listener 1883
protocol mqtt

# TLS listener
listener 8883
protocol mqtt
cafile /mosquitto/certs/ca/ca.crt
certfile /mosquitto/certs/server/server.crt
keyfile /mosquitto/certs/server/server.key

# Enable client certificate authentication
require_certificate true
use_identity_as_username true
EOF

# Create cert-generator Dockerfile
cat > cert-generator/Dockerfile << 'EOF'
FROM alpine:latest

RUN apk add --no-cache openssl

WORKDIR /certs

COPY generate-certs.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/generate-certs.sh

CMD ["generate-certs.sh"]
EOF

# Create certificate generation script
cat > cert-generator/generate-certs.sh << 'EOF'
#!/bin/sh
set -e

# Set paths and variables
CERTS_DIR="/certs"
CA_DIR="${CERTS_DIR}/ca"
SERVER_DIR="${CERTS_DIR}/server"
CLIENT_DIR="${CERTS_DIR}/client"
PFX_PASSWORD="smartreader"

# Create necessary directories
mkdir -p ${CA_DIR} ${SERVER_DIR} ${CLIENT_DIR}

echo "=== Creating Certificate Authority (CA) ==="
# Generate CA private key
openssl genrsa -out ${CA_DIR}/ca.key 2048

# Generate CA certificate
openssl req -new -x509 -days 365 -key ${CA_DIR}/ca.key -out ${CA_DIR}/ca.crt \
  -subj "/C=BR/ST=Sao Paulo/L=Campinas/O=SmartReader/OU=IoT/CN=MQTT-CA"

echo "=== Creating Server Certificate ==="
# Generate server private key
openssl genrsa -out ${SERVER_DIR}/server.key 2048

# Generate server CSR
openssl req -new -key ${SERVER_DIR}/server.key -out ${SERVER_DIR}/server.csr \
  -subj "/C=BR/ST=Sao Paulo/L=Campinas/O=SmartReader/OU=IoT/CN=mqtt-broker"

# Sign server certificate with CA
openssl x509 -req -days 365 -in ${SERVER_DIR}/server.csr \
  -CA ${CA_DIR}/ca.crt -CAkey ${CA_DIR}/ca.key -CAcreateserial \
  -out ${SERVER_DIR}/server.crt

echo "=== Creating Client Certificate ==="
# Generate client private key
openssl genrsa -out ${CLIENT_DIR}/client.key 2048

# Generate client CSR
openssl req -new -key ${CLIENT_DIR}/client.key -out ${CLIENT_DIR}/client.csr \
  -subj "/C=BR/ST=Sao Paulo/L=Campinas/O=SmartReader/OU=IoT/CN=mqtt-client"

# Sign client certificate with CA
openssl x509 -req -days 365 -in ${CLIENT_DIR}/client.csr \
  -CA ${CA_DIR}/ca.crt -CAkey ${CA_DIR}/ca.key -CAcreateserial \
  -out ${CLIENT_DIR}/client.crt

echo "=== Creating PFX for Client ==="
# Create PKCS#12 (PFX) file from client certificate and key
openssl pkcs12 -export -out ${CLIENT_DIR}/client.pfx \
  -inkey ${CLIENT_DIR}/client.key -in ${CLIENT_DIR}/client.crt \
  -certfile ${CA_DIR}/ca.crt -passout pass:${PFX_PASSWORD}

# Create a file with the password for reference
echo "${PFX_PASSWORD}" > ${CLIENT_DIR}/pfx-password.txt

echo "=== Setting Permissions ==="
# Set permissions
chmod 644 ${CA_DIR}/*.crt ${SERVER_DIR}/*.crt ${CLIENT_DIR}/*.crt ${CLIENT_DIR}/*.pfx
chmod 600 ${CA_DIR}/*.key ${SERVER_DIR}/*.key ${CLIENT_DIR}/*.key

echo "=== Certificate Generation Complete ==="
echo "PFX Password: ${PFX_PASSWORD}"
echo "All certificates have been generated successfully!"

# List generated files
find ${CERTS_DIR} -type f | sort
EOF

# Create MQTT client Dockerfile
cat > mqtt-client/Dockerfile << 'EOF'
FROM python:3.9-slim

WORKDIR /app

RUN pip install paho-mqtt requests

CMD ["tail", "-f", "/dev/null"]
EOF

# Create test client script
cat > test-client.py << 'EOF'
#!/usr/bin/env python3
import paho.mqtt.client as mqtt
import time
import ssl
import argparse
import os

# Parse command line arguments
parser = argparse.ArgumentParser(description='MQTT client with TLS certificate authentication')
parser.add_argument('--mode', choices=['pub', 'sub'], required=True, help='Publish or subscribe mode')
parser.add_argument('--topic', default='smartreader/test', help='MQTT topic')
parser.add_argument('--message', default='Hello, SmartReader!', help='Message to publish (for pub mode)')
args = parser.parse_args()

# Certificate paths
ca_cert = "/app/certs/ca/ca.crt"
client_cert = "/app/certs/client/client.crt"
client_key = "/app/certs/client/client.key"

# Check if certificates exist
for cert_file in [ca_cert, client_cert, client_key]:
    if not os.path.exists(cert_file):
        print(f"ERROR: Certificate file not found: {cert_file}")
        exit(1)

# Callback functions
def on_connect(client, userdata, flags, rc):
    print(f"Connected with result code {rc}")
    if args.mode == 'sub':
        client.subscribe(args.topic)
        print(f"Subscribed to topic: {args.topic}")

def on_message(client, userdata, msg):
    print(f"Received message on topic {msg.topic}: {msg.payload.decode()}")

def on_publish(client, userdata, mid):
    print(f"Message published successfully with id: {mid}")

# Create MQTT client
client = mqtt.Client()
client.on_connect = on_connect
client.on_message = on_message
client.on_publish = on_publish

# Configure TLS/SSL
client.tls_set(
    ca_certs=ca_cert,
    certfile=client_cert,
    keyfile=client_key,
    cert_reqs=ssl.CERT_REQUIRED,
    tls_version=ssl.PROTOCOL_TLS,
    ciphers=None
)

# Connect to broker
print("Connecting to MQTT broker...")
client.connect("mosquitto", 8883, 60)

# Start the loop
client.loop_start()

# Operate based on mode
if args.mode == 'pub':
    time.sleep(1)  # Give time for connection to establish
    print(f"Publishing message to {args.topic}: {args.message}")
    client.publish(args.topic, args.message)
    time.sleep(2)  # Wait for publish confirmation
elif args.mode == 'sub':
    print(f"Listening for messages on {args.topic}...")
    while True:
        time.sleep(1)

# Clean up
client.loop_stop()
client.disconnect()
EOF

# Create docker-compose.yml
cat > docker-compose.yml << 'EOF'
version: '3'

services:
  cert-generator:
    build:
      context: ./cert-generator
    volumes:
      - certs-volume:/certs
    networks:
      - mqtt-network

  mosquitto:
    image: eclipse-mosquitto:latest
    container_name: mqtt-broker
    ports:
      - "1883:1883"  # Standard MQTT port
      - "8883:8883"  # MQTT over TLS
    volumes:
      - ./mosquitto/config:/mosquitto/config
      - certs-volume:/mosquitto/certs
      - mosquitto-data:/mosquitto/data
      - mosquitto-log:/mosquitto/log
    networks:
      - mqtt-network
    depends_on:
      - cert-generator
    restart: unless-stopped

  mqtt-client:
    build:
      context: ./mqtt-client
    container_name: mqtt-client
    volumes:
      - certs-volume:/app/certs
      - ./test-client.py:/app/test-client.py
    networks:
      - mqtt-network
    depends_on:
      - mosquitto

networks:
  mqtt-network:
    driver: bridge

volumes:
  certs-volume:
  mosquitto-data:
  mosquitto-log:
EOF

# Make the script executable
chmod +x cert-generator/generate-certs.sh

echo "Setup complete! You can now run 'docker-compose up -d'"