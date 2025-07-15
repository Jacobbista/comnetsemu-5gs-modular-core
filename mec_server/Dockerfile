FROM python:3.9-slim-bullseye

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        bash \
        apt-utils \
        libsctp-dev \
        lksctp-tools \
        ethtool \
        iputils-ping \
        iproute2 \
        iptables \
        ifupdown \
        net-tools \
        curl \
        tcpdump \
        iperf3 && \
    apt-get autoremove -y && apt-get autoclean

# Copia i file del server
COPY mec_server.py /mnt/mec_server/mec_server.py
COPY mec_server.sh /mnt/mec_server/mec_server.sh

# Crea la cartella log se serve
RUN mkdir -p /mnt/log

# Rendi eseguibile lo script di avvio
RUN chmod +x /mnt/mec_server/mec_server.sh

# Comando di default
CMD ["/mnt/mec_server/mec_server.sh"]