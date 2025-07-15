#!/bin/bash

# Script to generate TLS certificates for Open5GS freeDiameter
# This ensures freeDiameter can start without TLS certificate errors

set -e

echo "🔐 Generating TLS certificates for Open5GS freeDiameter..."

# Generate CA certificate (self-signed)
echo "📋 Generating CA certificate..."
openssl req -new -x509 -days 3650 -nodes -out "ca.crt" -keyout "ca.key" -subj "/CN=Open5GS-CA/O=Open5GS/C=IT"

# Generate SMF certificate signed by CA
echo "📋 Generating SMF certificate..."
openssl req -new -nodes -out "smf.csr" -keyout "smf.key" -subj "/CN=smf.localdomain/O=Open5GS/C=IT"
openssl x509 -req -in "smf.csr" -CA "ca.crt" -CAkey "ca.key" -CAcreateserial -out "smf.crt" -days 365

# Generate PCF certificate signed by CA
echo "📋 Generating PCF certificate..."
openssl req -new -nodes -out "pcf.csr" -keyout "pcf.key" -subj "/CN=pcf.localdomain/O=Open5GS/C=IT"
openssl x509 -req -in "pcf.csr" -CA "ca.crt" -CAkey "ca.key" -CAcreateserial -out "pcf.crt" -days 365

# Clean up CSR files
rm -f *.csr

# Set appropriate permissions
chmod 600 *.key
chmod 644 *.crt

echo "✅ TLS certificates generated successfully!"
echo "📁 Location: $(pwd)"
echo "📄 Files created:"
ls -la *.crt *.key
