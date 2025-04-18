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