```markdown
# MQTT SSL Test Environment

This project sets up a complete MQTT environment with SSL/TLS certificate authentication using Docker Compose. It includes a certificate generator, an MQTT broker (Mosquitto), and an MQTT client for testing.

## Project Structure

- **`cert-generator/`**: Generates SSL/TLS certificates for the broker and client.
- **`mosquitto/`**: Contains the Mosquitto broker configuration.
- **`mqtt-client/`**: Contains the MQTT client setup and test scripts.
- **`docker-compose.yml`**: Defines the services and their relationships.
- **`*.bat`**: Batch scripts for automating tasks like uploading certificates, configuring the broker, and testing.

---

## Prerequisites

- Docker and Docker Compose installed on your system.
- Basic knowledge of MQTT and SSL/TLS.

---

## Setup Instructions

1. **Clone the Repository**
   ```sh
   git clone <repository-url>
   cd mqtt-ssl-test
   ```

2. **Run the Setup Script**
   The `setup.sh` script creates the necessary directories, configuration files, and certificates.
   ```sh
   ./setup.sh
   ```

3. **Start the Services**
   Use Docker Compose to build and start the services:
   ```sh
   docker-compose up -d
   ```

4. **Verify the Setup**
   Check the logs to ensure all services are running correctly:
   ```sh
   docker-compose logs
   ```

---

## Components

### 1. Certificate Generator
The `cert-generator` service generates the following certificates:
- **CA Certificate**: `ca.crt`
- **Server Certificate**: `server.crt`, `server.key`
- **Client Certificate**: `client.crt`, `client.key`, `client.pfx`

Certificates are stored in the `certs-volume` Docker volume and shared with the Mosquitto broker and MQTT client.

### 2. Mosquitto Broker
The Mosquitto broker is configured to:
- Listen on port `1883` for non-TLS connections.
- Listen on port `8883` for TLS connections.
- Require client certificate authentication for TLS connections.

Configuration file: `mosquitto/config/mosquitto.conf`

### 3. MQTT Client
The `mqtt-client` service includes:
- A Python script (`test-client.py`) for publishing and subscribing to topics.
- Batch scripts for testing MQTT communication.

---

## Usage

### Extract Certificates
Run the following script to extract the generated certificates:
```sh
extract-certs.bat
```

### Upload Certificates to SmartReader
1. Upload the client certificate:
   ```sh
   1-upload-client-cert.bat
   ```
2. Upload the CA certificate:
   ```sh
   2-upload-ca-cert.bat
   ```

### Configure SmartReader
1. Configure certificate settings:
   ```sh
   3-configure-certs.bat
   ```
2. Test certificate loading:
   ```sh
   4-test-cert-loading.bat
   ```
3. Configure MQTT settings:
   ```sh
   5-configure-mqtt.bat
   ```

### Test MQTT Communication
1. **Subscribe to a Topic**:
   ```sh
   mqtt-test.bat sub
   ```
2. **Publish a Message**:
   ```sh
   mqtt-test.bat pub
   ```

---

## Troubleshooting

Use the `troubleshoot.bat` script to diagnose issues:
```sh
troubleshoot.bat
```

This script checks:
- Certificate generation logs.
- Mosquitto broker logs.
- Certificate paths.
- TLS configuration.
- Client certificate validity.

---

## Notes

- Ensure the hostname in the broker's certificate matches the hostname used by the client (`mqtt-broker`).
- For testing purposes, hostname verification is disabled in the client (`tls_insecure_set(True)`).

---

## Cleanup

To stop and remove all containers and volumes:
```sh
docker-compose down -v
```

---

## License

This project is licensed under the MIT License.
```
