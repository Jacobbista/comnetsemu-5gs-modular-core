#!/bin/bash

export DB_URI="mongodb://mongo/open5gs"

LOG=/open5gs/install/var/log/open5gs/udm.log

if [ -z "$STATIC_IP" ]; then
    echo "[UDM][init][WARNING] STATIC_IP environment variable not set. Using default IP 192.168.0.214." >> $LOG
    STATIC_IP="192.168.0.214"
else
    STATIC_IP="$STATIC_IP"
fi

echo "[UDM][init] Waiting for AMF SBI…" >> $LOG
while ! nc -z amf 7777; do
  echo "[UDM][init] Still waiting for AMF…" >> $LOG
  sleep 2
done

echo "[UDM][init] Waiting for IP address to be assigned..." >> $LOG
while ! ip addr show | grep -q "$STATIC_IP"; do
    sleep 1
done

echo "[UDM][init] IP address assigned, starting UDM daemon..." >> $LOG


echo "[UDM][init] Starting UDM now…" >> $LOG
./install/bin/open5gs-udmd