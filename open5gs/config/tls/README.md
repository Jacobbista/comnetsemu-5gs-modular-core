# TLS Certificates for Open5GS freeDiameter

This directory contains TLS certificates required for freeDiameter to function properly in Open5GS.

## 🔐 What is this for?

**freeDiameter** is used by Open5GS SMF to communicate with PCF (Policy Control Function) via the **Gx interface**. This enables:
- Dynamic policy control
- QoS management
- Traffic charging and accounting
- Advanced 5G features

## 📋 Quick Setup

### 1. Generate certificates:
```bash
cd /path/to/comnetsemu-5gs-modular-core/open5gs/scripts
./generate_tls_certs.sh
```

### 2. Start the 5G core:
```bash
cd /path/to/comnetsemu-5gs-modular-core
sudo python3 topology.py
```

## 📄 Generated Files

After running the script, you'll have:
- `ca.crt` - Certificate Authority certificate
- `ca.key` - Certificate Authority private key
- `smf.crt` - SMF certificate for freeDiameter
- `smf.key` - SMF private key
- `pcf.crt` - PCF certificate (if needed)
- `pcf.key` - PCF private key

## 🔄 Automatic Mounting

The `topology.py` file automatically mounts this directory to:
```
/open5gs/install/etc/open5gs/tls
```
inside all containers.

## 🛠️ Troubleshooting

### Problem: SMF fails to start with freeDiameter error
**Solution**: Make sure certificates are generated and this directory is properly mounted.

### Problem: Permission denied errors
**Solution**: Check that certificates have correct permissions (600 for .key files, 644 for .crt files).

### Problem: Certificate verification fails
**Solution**: Regenerate certificates with correct domain names matching your configuration.

## 🏃‍♂️ Running without freeDiameter

If you don't need advanced policy control, you can disable freeDiameter by commenting out the line in `smf.yaml`:
```yaml
#  freeDiameter: /open5gs/install/etc/freeDiameter/smf.conf
```

## 🔗 More Information

- [Open5GS Documentation](https://open5gs.org/open5gs/docs/)
- [freeDiameter Project](https://www.freediameter.net/)
- [3GPP Gx Interface Specification](https://www.3gpp.org/DynaReport/29212.htm) 