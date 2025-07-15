#!/bin/bash

export DB_URI="mongodb://mongo/open5gs"

LOG=/open5gs/install/var/log/open5gs/amf.log

# Usa la variabile di ambiente STATIC_IP, oppure default a 192.168.0.212 se non impostata
if [ -z "$STATIC_IP" ]; then
    echo "[AMF][init][WARNING] STATIC_IP environment variable not set. Using default IP 192.168.0.212." >> $LOG
    STATIC_IP="192.168.0.212"
else
    STATIC_IP="$STATIC_IP"
fi

echo "[AMF][init] Waiting for SMF SBI…" >> $LOG
while ! nc -z smf 7777; do
  echo "[AMF][init] Still waiting for SMF…" >> $LOG
  sleep 2
done

# Aspetta che l'IP sia assegnato e che l'interfaccia sia UP
echo "[AMF][init] Waiting for IP address ($STATIC_IP) to be assigned..." >> $LOG
while ! ip addr show | grep -q "$STATIC_IP"; do
    sleep 1
done

echo "[AMF][init] IP address ($STATIC_IP) assigned, starting AMF daemon..." >> $LOG

echo "[AMF][init] Starting AMF now…" >> $LOG
./install/bin/open5gs-amfd