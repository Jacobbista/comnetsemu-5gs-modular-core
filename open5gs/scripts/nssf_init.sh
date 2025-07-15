#!/bin/bash

export DB_URI="mongodb://mongo/open5gs"

LOG=/open5gs/install/var/log/open5gs/nssf.log

if [ -z "$STATIC_IP" ]; then
    echo "[NSSF][init][WARNING] STATIC_IP environment variable not set. Using default IP 192.168.0.218." >> $LOG
    STATIC_IP="192.168.0.218"
else
    STATIC_IP="$STATIC_IP"
fi

echo "[NSSF][init] Waiting for AMF SBI…" >> $LOG
while ! nc -z amf 7777; do
  echo "[NSSF][init] Still waiting for AMF…" >> $LOG
  sleep 2
done

echo "[NSSF][init] Waiting for IP address to be assigned..." >> $LOG
while ! ip addr show | grep -q "$STATIC_IP"; do
    sleep 1
done

echo "[NSSF][init] IP address assigned, starting NSSF daemon..." >> $LOG

echo "[NSSF][init] Starting NSSF now…" >> $LOG
./install/bin/open5gs-nssfd