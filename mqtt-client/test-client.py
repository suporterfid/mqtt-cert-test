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
client.tls_insecure_set(True)  # Disable hostname verification
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