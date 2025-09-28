#!/bin/bash

# Initialization script for Docker dev environment
# This script sets up and manages the two Ubuntu development containers

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_header() {
    echo -e "\n${BLUE}=== $1 ===${NC}"
}

# Check if Docker and Docker Compose are installed
check_dependencies() {
    print_header "Checking Dependencies"

    if ! command -v docker &> /dev/null; then
        print_error "Docker is not installed or not in PATH"
        exit 1
    fi

    if ! command -v docker-compose &> /dev/null; then
        print_error "Docker Compose is not installed or not in PATH"
        exit 1
    fi

    print_status "Docker and Docker Compose are available"
}

# Create shared directory
create_shared_dir() {
    print_header "Setting Up Shared Directory"

    if [ ! -d "shared" ]; then
        mkdir shared
        print_status "Created shared directory"
    else
        print_status "Shared directory already exists"
    fi

    # Create a test file and networking reference
    cat > shared/README.md << 'EOF'
# Shared Files
This directory is mounted on both containers at /shared
Use it to transfer files between containers

## Network Tools Quick Reference

### Container IPs:
- dev-box-1: 172.20.0.10
- dev-box-2: 172.20.0.11

### Netcat Variants:
1. nc (openbsd) - Secure, no -e flag
2. nc.traditional - Has -e flag for shell execution
3. socat - Advanced bidirectional relay

### Example Commands:

#### Traditional Netcat (bind shell):
```bash
# Listener with shell
nc.traditional -l -p 8080 -e /bin/bash

# Connect
nc.traditional <target> 8080
```

#### Socat (interactive shell):
```bash
# Better shell listener
socat TCP-LISTEN:8080,fork,reuseaddr EXEC:/bin/bash,pty,stderr

# Connect
socat TCP:<target>:8080 -
```

#### Port Scanning:
```bash
# Single port
nc -zv <target> 22

# Port range
nc -zv <target> 20-25

# Nmap network scan
nmap -sn 172.20.0.0/24
```

#### File Transfer:
```bash
# Send file (receiver)
nc -l -p 8080 > received_file

# Send file (sender)
nc <target> 8080 < file_to_send
```
EOF
}

# Build and start containers
start_containers() {
    print_header "Building and Starting Containers"

    print_status "Building Docker images..."
    docker-compose build

    print_status "Starting containers..."
    docker-compose up -d

    # Wait for containers to be ready
    sleep 5

    print_status "Containers are starting up..."
}

# Test network connectivity
test_connectivity() {
    print_header "Testing Network Connectivity"

    print_status "Testing ping from dev-box-1 to dev-box-2..."
    docker exec dev-box-1 ping -c 3 dev-box-2

    print_status "Testing ping from dev-box-2 to dev-box-1..."
    docker exec dev-box-2 ping -c 3 dev-box-1

    print_status "Network connectivity test completed"
}

# Display container information
show_info() {
    print_header "Container Information"

    echo -e "${BLUE}Container Status:${NC}"
    docker-compose ps

    echo -e "\n${BLUE}Network Information:${NC}"
    echo "dev-box-1: 172.20.0.10"
    echo "dev-box-2: 172.20.0.11"
    echo "Network: 172.20.0.0/16"

    echo -e "\n${BLUE}Installed Tools:${NC}"
    echo "Network: nmap, nc, curl, wget, tcpdump, ssh"
    echo "Development: git, vim, nano, python3, nodejs"
    echo "System: htop, tree, zip, unzip, jq"

    echo -e "\n${BLUE}Usage Examples:${NC}"
    echo "Connect to dev-box-1: docker exec -it dev-box-1 bash"
    echo "Connect to dev-box-2: docker exec -it dev-box-2 bash"
    echo "Test network scan: docker exec dev-box-1 nmap -sn 172.20.0.0/24"
    echo "Test netcat server: docker exec dev-box-2 nc -l -p 8080"
    echo "Test netcat client: docker exec dev-box-1 nc dev-box-2 8080"
}

# Stop containers
stop_containers() {
    print_header "Stopping Containers"
    docker-compose down
    print_status "Containers stopped"
}

# Clean up everything
cleanup() {
    print_header "Cleaning Up"
    print_status "Stopping containers..."
    docker-compose down --volumes --remove-orphans

    print_status "Removing unused Docker resources..."
    docker system prune -f

    print_status "Removing Docker images for this project..."
    docker images | grep "docker.*devbox" | awk '{print $3}' | xargs -r docker rmi -f

    print_status "Cleanup completed - all resources removed"
}

# Main function
main() {
    case "${1:-start}" in
        start)
            check_dependencies
            create_shared_dir
            start_containers
            test_connectivity
            show_info
            ;;
        stop)
            stop_containers
            ;;
        restart)
            stop_containers
            sleep 2
            start_containers
            test_connectivity
            show_info
            ;;
        status)
            docker-compose ps
            ;;
        logs)
            docker-compose logs -f
            ;;
        cleanup)
            cleanup
            ;;
        connect1)
            docker exec -it dev-box-1 bash
            ;;
        connect2)
            docker exec -it dev-box-2 bash
            ;;
        test)
            test_connectivity
            ;;
        *)
            echo "Usage: $0 {start|stop|restart|status|logs|cleanup|connect1|connect2|test}"
            echo ""
            echo "Commands:"
            echo "  start    - Build and start the containers (default)"
            echo "  stop     - Stop the containers"
            echo "  restart  - Restart the containers"
            echo "  status   - Show container status"
            echo "  logs     - Show container logs"
            echo "  cleanup  - Stop containers and clean up project resources"
            echo "  connect1 - Connect to dev-box-1"
            echo "  connect2 - Connect to dev-box-2"
            echo "  test     - Test network connectivity"
            exit 1
            ;;
    esac
}

# Run main function with all arguments
main "$@"
