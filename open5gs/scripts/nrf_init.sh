#!/bin/bash

export DB_URI="mongodb://mongo/open5gs"

LOG=/open5gs/install/var/log/open5gs/nrf.log

if [ -z "$STATIC_IP" ]; then
    echo "[NRF][init][WARNING] STATIC_IP environment variable not set. Using default IP 192.168.0.210." >> $LOG
    STATIC_IP="192.168.0.210"
else
    STATIC_IP="$STATIC_IP"
fi

echo "[NRF][init] Starting NRF now…" >> $LOG

# Aspetta che l'IP sia assegnato e che l'interfaccia sia UP
echo "[NRF][init] Waiting for IP address to be assigned..." >> $LOG
while ! ip addr show | grep -q "$STATIC_IP"; do
    sleep 1
done

echo "[NRF][init] IP address assigned, starting NRF daemon..." >> $LOG

# Usa script per rimuovere completamente i colori ANSI e il buffering
./install/bin/open5gs-nrfd