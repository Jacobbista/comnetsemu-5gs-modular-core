#!/bin/bash

export DB_URI="mongodb://mongo/open5gs"

LOG=/open5gs/install/var/log/open5gs/bsf.log

if [ -z "$STATIC_IP" ]; then
    echo "[BSF][init][WARNING] STATIC_IP environment variable not set. Using default IP 192.168.0.217." >> $LOG
    STATIC_IP="192.168.0.217"
else
    STATIC_IP="$STATIC_IP"
fi

echo "[BSF][init] Waiting for AMF SBI…" >> $LOG
while ! nc -z amf 7777; do
  echo "[BSF][init] Still waiting for AMF…" >> $LOG
  sleep 2
done

echo "[BSF][init] Waiting for IP address to be assigned..." >> $LOG
while ! ip addr show | grep -q "$STATIC_IP"; do
    sleep 1
done

echo "[BSF][init] IP address assigned, starting BSF daemon..." >> $LOG


echo "[BSF][init] Starting BSF now…" >> $LOG
./install/bin/open5gs-bsfd