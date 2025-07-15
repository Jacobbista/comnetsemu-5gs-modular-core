#!/bin/bash

export DB_URI="mongodb://mongo/open5gs"

LOG=/open5gs/install/var/log/open5gs/ausf.log

if [ -z "$STATIC_IP" ]; then
    echo "[AUSF][init][WARNING] STATIC_IP environment variable not set. Using default IP 192.168.0.213." >> $LOG
    STATIC_IP="192.168.0.213"
else
    STATIC_IP="$STATIC_IP"
fi

echo "[AUSF][init] Waiting for AMF SBI…" >> $LOG
while ! nc -z amf 7777; do
  echo "[AUSF][init] Still waiting for AMF…" >> $LOG
  sleep 2
done

echo "[AUSF][init] Waiting for IP address to be assigned..." >> $LOG
while ! ip addr show | grep -q "$STATIC_IP"; do
    sleep 1
done

echo "[AUSF][init] IP address assigned, starting AUSF daemon..." >> $LOG

echo "[AUSF][init] Starting AUSF now…" >> $LOG
./install/bin/open5gs-ausfd