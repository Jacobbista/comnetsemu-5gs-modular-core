#!/bin/bash

export DB_URI="mongodb://mongo/open5gs"

LOG=/open5gs/install/var/log/open5gs/udr.log

if [ -z "$STATIC_IP" ]; then
    echo "[UDR][init][WARNING] STATIC_IP environment variable not set. Using default IP 192.168.0.215." >> $LOG
    STATIC_IP="192.168.0.215"
else
    STATIC_IP="$STATIC_IP"
fi

echo "[UDR][init] Waiting for AMF SBI…" >> $LOG
while ! nc -z amf 7777; do
  echo "[UDR][init] Still waiting for AMF…" >> $LOG
  sleep 2
done

echo "[UDR][init] Waiting for IP address to be assigned..." >> $LOG
while ! ip addr show | grep -q "$STATIC_IP"; do
    sleep 1
done

echo "[UDR][init] IP address assigned, starting UDR daemon..." >> $LOG


echo "[UDR][init] Starting UDR now…" >> $LOG
./install/bin/open5gs-udrd