#!/bin/bash

# Sophisticated health check script for Open5GS services
# Uses environment variables to specify service type for targeted checks
# 
# Environment variables:
# HEALTH_CHECK_TYPE: nf | mongo | upf
# HEALTH_CHECK_PORT: custom port override (optional)
# HEALTH_CHECK_PROTOCOL: tcp | udp (default: tcp)

# Get the container's IP address (first IP from hostname -I)
CONTAINER_IP=$(hostname -I | awk '{print $1}')

# Set default protocol
PROTOCOL=${HEALTH_CHECK_PROTOCOL:-tcp}

# Function to test TCP port
test_tcp_port() {
    local host=$1
    local port=$2
    nc -z "$host" "$port" 2>/dev/null
}

# Function to test UDP port
test_udp_port() {
    local host=$1
    local port=$2
    nc -zu "$host" "$port" 2>/dev/null
}

# Function to test port based on protocol
test_port() {
    local host=$1
    local port=$2
    local protocol=$3
    
    if [ "$protocol" = "udp" ]; then
        test_udp_port "$host" "$port"
    else
        test_tcp_port "$host" "$port"
    fi
}

# Main health check logic based on service type
case "${HEALTH_CHECK_TYPE:-auto}" in
    "nf")
        PORT=${HEALTH_CHECK_PORT:-7777}
        if test_port "$CONTAINER_IP" "$PORT" "$PROTOCOL"; then
            echo "Network Function service healthy on $CONTAINER_IP:$PORT ($PROTOCOL)"
            exit 0
        fi
        ;;
    
    "mongo")
        PORT=${HEALTH_CHECK_PORT:-27017}
        if test_port "localhost" "$PORT" "$PROTOCOL"; then
            echo "MongoDB service healthy on localhost:$PORT ($PROTOCOL)"
            exit 0
        fi
        ;;
    
    "upf")
        # Check both PFCP (UDP 8805) and Management (TCP 9090)
        if test_udp_port "$CONTAINER_IP" 8805; then
            echo "UPF service healthy on $CONTAINER_IP:8805 (PFCP/UDP)"
            exit 0
        elif test_tcp_port "$CONTAINER_IP" 9090; then
            echo "UPF service healthy on $CONTAINER_IP:9090 (Management/TCP)"
            exit 0
        fi
        ;;
    
    "auto"|*)
        # Auto-detect service type (fallback to current behavior)
        if test_tcp_port "$CONTAINER_IP" 7777; then
            echo "Network Function service healthy on $CONTAINER_IP:7777"
            exit 0
        elif test_tcp_port "localhost" 27017; then
            echo "MongoDB service healthy on localhost:27017"
            exit 0
        elif test_udp_port "$CONTAINER_IP" 8805; then
            echo "UPF service healthy on $CONTAINER_IP:8805 (PFCP)"
            exit 0
        elif test_tcp_port "$CONTAINER_IP" 9090; then
            echo "UPF service healthy on $CONTAINER_IP:9090 (Management)"
            exit 0
        fi
        ;;
esac

# If we get here, health check failed
echo "Health check failed for service type: ${HEALTH_CHECK_TYPE:-auto}"
echo "Expected service not responding on configured ports"
exit 1 