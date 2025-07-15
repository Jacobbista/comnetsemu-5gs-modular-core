#!/bin/bash

export DB_URI="mongodb://127.0.0.1/open5gs"

mongod --smallfiles --dbpath /var/lib/mongodb --logpath /open5gs/install/var/log/open5gs/mongodb.log --logRotate reopen --logappend --bind_ip_all --ipv6 &

sleep 15 && cd webui && npm run dev