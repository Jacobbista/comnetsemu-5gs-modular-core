#!/bin/bash

export DB_URI="mongodb://mongo/open5gs"

LOG=/open5gs/install/var/log/open5gs/smf.log

if [ -z "$STATIC_IP" ]; then
    echo "[SMF][init][WARNING] STATIC_IP environment variable not set. Using default IP 192.168.0.211." >> $LOG
    STATIC_IP="192.168.0.211"
else
    STATIC_IP="$STATIC_IP"
fi

echo "[SMF][init] Waiting for NRF SBI…" >> $LOG
while ! nc -z nrf 7777; do
  echo "[SMF][init] Still waiting for NRF…" >> $LOG
  sleep 2
done

echo "[SMF][init] Waiting for IP address to be assigned..." >> $LOG
while ! ip addr show | grep -q "$STATIC_IP"; do
    sleep 1
done

echo "[SMF][init] IP address assigned, starting SMF daemon..." >> $LOG


echo "[SMF][init] Starting SMF now…" >> $LOG
./install/bin/open5gs-smfd