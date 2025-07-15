#!/bin/bash

export DB_URI="mongodb://mongo/open5gs"

LOG=/open5gs/install/var/log/open5gs/pcf.log

if [ -z "$STATIC_IP" ]; then
    echo "[PCF][init][WARNING] STATIC_IP environment variable not set. Using default IP 192.168.0.216." >> $LOG
    STATIC_IP="192.168.0.216"
else
    STATIC_IP="$STATIC_IP"
fi

echo "[PCF][init] Waiting for AMF SBI…" >> $LOG
while ! nc -z amf 7777; do
  echo "[PCF][init] Still waiting for AMF…" >> $LOG
  sleep 2
done

echo "[PCF][init] Waiting for IP address to be assigned..." >> $LOG
while ! ip addr show | grep -q "$STATIC_IP"; do
    sleep 1
done

echo "[PCF][init] IP address assigned, starting PCF daemon..." >> $LOG


echo "[PCF][init] Starting PCF now…" >> $LOG
./install/bin/open5gs-pcfd