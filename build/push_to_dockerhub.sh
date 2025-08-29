#!/bin/bash

# Docker Hub Push Script for ComNetsEmu 5G Core
# Tags and pushes Docker images to Docker Hub

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

print_debug() {
    echo -e "${YELLOW}[DEBUG]${NC} $1"
}

# Check if Docker is running
check_docker() {
    print_debug "Checking if Docker is running..."
    if ! docker info > /dev/null 2>&1; then
        print_error "Docker is not running. Start Docker and try again."
        exit 1
    fi
    print_debug "Docker is running"
}

# Check if required images exist
check_images() {
    print_debug "Checking if required Docker images exist..."
    local images_found=0
    
    if docker image inspect my5gc_v2-7-5 > /dev/null 2>&1; then
        print_success "5GC image found: my5gc_v2-7-5"
        images_found=$((images_found + 1))
    else
        print_warning "5GC image not found: my5gc_v2-7-5"
    fi
    
    if docker image inspect myueransim_v3-2-7 > /dev/null 2>&1; then
        print_success "UERANSIM image found: myueransim_v3-2-7"
        images_found=$((images_found + 1))
    else
        print_warning "UERANSIM image not found: myueransim_v3-2-7"
    fi
    
    if docker image inspect mec_server > /dev/null 2>&1; then
        print_success "MEC Server image found: mec_server"
        images_found=$((images_found + 1))
    else
        print_warning "MEC Server image not found: mec_server"
    fi
    
    if [ $images_found -eq 0 ]; then
        print_error "No images found. Run ./build.sh first or use ./dockerhub_pull.sh"
        exit 1
    fi
    
    print_debug "Found $images_found images"
}

# Get Docker Hub username
get_dockerhub_username() {
    print_debug "get_dockerhub_username function called with $# parameters"
    
    # Check if username is passed as parameter
    if [ $# -gt 0 ]; then
        DOCKERHUB_USERNAME="$1"
        print_status "Docker Hub username set from parameter: $DOCKERHUB_USERNAME"
        return
    fi
    
    # Check if set as environment variable
    if [ -z "$DOCKERHUB_USERNAME" ]; then
        print_error "Docker Hub username required but not provided!"
        echo ""
        echo "Usage: $0 username_dockerhub"
        echo "Example: $0 jacobbista"
        echo ""
        echo "Or use environment variable:"
        echo "export DOCKERHUB_USERNAME=username"
        echo "$0"
        echo ""
        exit 1
    else
        print_status "Docker Hub username set from environment variable: $DOCKERHUB_USERNAME"
    fi
}

# Login to Docker Hub
docker_login() {
    print_debug "Attempting Docker Hub login..."
    print_status "Logging in to Docker Hub..."
    if docker login; then
        print_success "Docker Hub login completed"
    else
        print_error "Docker Hub login failed"
        exit 1
    fi
}

# Tag images
tag_images() {
    local username=$1
    print_debug "Tagging images for username: $username"
    print_status "Tagging images with project prefix..."
    
    # Tag 5GC
    if docker image inspect my5gc_v2-7-5 > /dev/null 2>&1; then
        print_status "Tagging 5GC..."
        docker tag my5gc_v2-7-5 "$username/comnetsemu-5gc:2.7.5"
        docker tag my5gc_v2-7-5 "$username/comnetsemu-5gc:latest"
        print_success "5GC tagged as $username/comnetsemu-5gc:2.7.5 and latest"
    fi
    
    # Tag UERANSIM
    if docker image inspect myueransim_v3-2-7 > /dev/null 2>&1; then
        print_status "Tagging UERANSIM..."
        docker tag myueransim_v3-2-7 "$username/comnetsemu-ueransim:3.2.7"
        docker tag myueransim_v3-2-7 "$username/comnetsemu-ueransim:latest"
        print_success "UERANSIM tagged as $username/comnetsemu-ueransim:3.2.7 and latest"
    fi
    
    # Tag MEC Server
    if docker image inspect mec_server > /dev/null 2>&1; then
        print_status "Tagging MEC Server..."
        docker tag mec_server "$username/comnetsemu-mec:latest"
        print_success "MEC Server tagged as $username/comnetsemu-mec:latest"
    fi
}

# Push images
push_images() {
    local username=$1
    print_debug "Pushing images for username: $username"
    print_status "Pushing images to Docker Hub..."
    
    # Push 5GC
    if docker image inspect "$username/comnetsemu-5gc:latest" > /dev/null 2>&1; then
        print_status "Pushing 5GC:2.7.5..."
        docker push "$username/comnetsemu-5gc:2.7.5"
        print_status "Pushing 5GC:latest..."
        docker push "$username/comnetsemu-5gc:latest"
        print_success "5GC pushed successfully"
    fi
    
    # Push UERANSIM
    if docker image inspect "$username/comnetsemu-ueransim:latest" > /dev/null 2>&1; then
        print_status "Pushing UERANSIM:3.2.7..."
        docker push "$username/comnetsemu-ueransim:3.2.7"
        print_status "Pushing UERANSIM:latest..."
        docker push "$username/comnetsemu-ueransim:latest"
        print_success "UERANSIM pushed successfully"
    fi
    
    # Push MEC Server
    if docker image inspect "$username/comnetsemu-mec:latest" > /dev/null 2>&1; then
        print_status "Pushing MEC Server:latest..."
        docker push "$username/comnetsemu-mec:latest"
        print_success "MEC Server pushed successfully"
    fi
}

# Show final summary
show_summary() {
    local username=$1
    print_success "=== PUSH COMPLETED SUCCESSFULLY ==="
    echo
    print_status "Images available on Docker Hub:"
    echo "  - $username/comnetsemu-5gc:2.7.5"
    echo "  - $username/comnetsemu-5gc:latest"
    echo "  - $username/comnetsemu-ueransim:3.2.7"
    echo "  - $username/comnetsemu-ueransim:latest"
    echo "  - $username/comnetsemu-mec:latest"
    echo
    print_status "To use these images:"
    echo "  docker pull $username/comnetsemu-5gc:latest"
    echo "  docker pull $username/comnetsemu-ueransim:latest"
    echo "  docker pull $username/comnetsemu-mec:latest"
}

# Show help
show_help() {
    echo "Usage: $0 [username_dockerhub]"
    echo ""
    echo "Options:"
    echo "  username_dockerhub    Docker Hub username (optional)"
    echo ""
    echo "Examples:"
    echo "  $0                    # Requires username interactively"
    echo "  $0 my_username        # Uses specified username"
    echo "  DOCKERHUB_USERNAME=my_username $0  # Uses environment variable"
    echo ""
    echo "If no username is specified, the script will require it interactively"
}

# Main function
main() {
    print_debug "Script started with $# parameters: $@"
    
    # Check if help is requested
    if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
        show_help
        exit 0
    fi
    
    echo "Docker Hub Push Script - ComNetsEmu 5G Core"
    echo "============================================"
    echo
    
    print_debug "Starting preliminary checks..."
    # Preliminary checks
    check_docker
    check_images
    
    print_debug "Getting username and logging in..."
    # Get username and login
    get_dockerhub_username "$@"
    docker_login
    
    print_debug "Tagging and pushing images..."
    # Tag and push
    tag_images "$DOCKERHUB_USERNAME"
    push_images "$DOCKERHUB_USERNAME"
    
    print_debug "Showing final summary..."
    # Final summary
    show_summary "$DOCKERHUB_USERNAME"
}

# Execute script
print_debug "Script started, calling main with parameters: $@"
main "$@"