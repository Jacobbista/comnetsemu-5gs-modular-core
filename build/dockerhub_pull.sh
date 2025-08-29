#!/bin/bash

# Docker Hub Pull Script for ComNetsEmu 5G Core
# Pulls pre-built Docker images from Docker Hub

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored messages
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if Docker is running
check_docker() {
    if ! docker info > /dev/null 2>&1; then
        print_error "Docker is not running. Start Docker and try again."
        exit 1
    fi
}

# Pull Docker images
pull_images() {
    print_status "Pulling Docker images from Docker Hub..."
    
    # Pull 5GC
    print_status "Pulling 5GC:latest..."
    if docker pull jacobbista/comnetsemu-5gc:latest; then
        print_success "5GC pulled successfully"
        docker tag jacobbista/comnetsemu-5gc:latest my5gc_v2-7-5
        print_success "5GC tagged as my5gc_v2-7-5"
    else
        print_error "Failed to pull 5GC"
        exit 1
    fi
    
    # Pull UERANSIM
    print_status "Pulling UERANSIM:latest..."
    if docker pull jacobbista/comnetsemu-ueransim:latest; then
        print_success "UERANSIM pulled successfully"
        docker tag jacobbista/comnetsemu-ueransim:latest myueransim_v3-2-7
        print_success "UERANSIM tagged as myueransim_v3-2-7"
    else
        print_error "Failed to pull UERANSIM"
        exit 1
    fi
    
    # Pull MEC Server
    print_status "Pulling MEC Server:latest..."
    if docker pull jacobbista/comnetsemu-mec:latest; then
        print_success "MEC Server pulled successfully"
        docker tag jacobbista/comnetsemu-mec:latest mec_server
        print_success "MEC Server tagged as mec_server"
    else
        print_error "Failed to pull MEC Server"
        exit 1
    fi
}

# Show final summary
show_summary() {
    print_success "=== PULL COMPLETED SUCCESSFULLY ==="
    echo
    print_status "Images available locally:"
    echo "  - my5gc_v2-7-5 (from jacobbista/comnetsemu-5gc:latest)"
    echo "  - myueransim_v3-2-7 (from jacobbista/comnetsemu-ueransim:latest)"
    echo "  - mec_server (from jacobbista/comnetsemu-mec:latest)"
    echo
    print_status "To verify images:"
    echo "  docker images | grep -E '(my5gc|myueransim|mec_server)'"
    echo
    print_status "Next steps:"
    echo "  1. Run the topology: cd .. && ./runTopology.sh"
    echo "  2. Test the network: sudo python3 TestNet5G.py"
}

# Main function
main() {
    echo "Docker Hub Pull Script - ComNetsEmu 5G Core"
    echo "============================================"
    echo
    
    # Preliminary checks
    check_docker
    
    # Pull images
    pull_images
    
    # Final summary
    show_summary
}

# Execute script
main "$@"