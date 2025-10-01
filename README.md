# Quick Dev Box

A Docker-based development environment for network security training and testing.

## Overview

This project provides two Debian-based development containers with pre-installed network tools for security research and training. The containers are connected via a custom Docker network and include comprehensive toolsets for network analysis, penetration testing practice, and development.

**Base Image**: Debian Bookworm Slim (optimized for size while maintaining full functionality as Ubuntu)

## Requirements

* Docker
* Docker Compose

## Quick Start

Start the development environment:

```sh
./init.sh
```

This will build and start both containers, test connectivity, and display connection information.

## Container Details

* **dev-box-1**: 172.20.0.10
* **dev-box-2**: 172.20.0.11
* **Network**: 172.20.0.0/16
* **Shared directory**: `./shared` mounted at `/shared` in both containers

## Installed Tools

### Network Tools
* nmap - Network discovery and security auditing
* netcat (openbsd and traditional) - Network connections and data transfer
* socat - Advanced bidirectional data relay
* curl, wget - HTTP clients
* tcpdump - Network packet analyzer
* ssh - Secure shell client/server

### Development Tools
* git, vim, nano - Version control and editors
* python3, nodejs, go, rust - Programming languages
* vim with LSP support - gopls (Go) and rust-analyzer (Rust) with autocompletion
* AWS CLI, kubectl, helm - Cloud and Kubernetes tools
* htop, tree - System monitoring and file browsing
* zip, unzip, jq - Archive and JSON processing

## Usage Commands

### Container Management

Start containers:
```sh
./init.sh start
```

Stop containers:
```sh
./init.sh stop
```

Restart containers:
```sh
./init.sh restart
```

Check status:
```sh
./init.sh status
```

View logs:
```sh
./init.sh logs
```

### Connecting to Containers

Connect to dev-box-1:
```sh
./init.sh connect1
```

Connect to dev-box-2:
```sh
./init.sh connect2
```

Alternative direct connection:
```sh
docker exec -it dev-box-1 bash
docker exec -it dev-box-2 bash
```

### Testing Network Connectivity

Test network connectivity between containers:
```sh
./init.sh test
```

### Example Network Operations

Port scanning:
```sh
# From dev-box-1, scan dev-box-2
docker exec -it dev-box-1 bash
nmap -sn 172.20.0.0/24
nc -zv 172.20.0.11 22
```

File transfer using netcat:
```sh
# On receiver (dev-box-2)
nc -l -p 8080 > received_file

# On sender (dev-box-1)
nc 172.20.0.11 8080 < file_to_send
```

Interactive shell with socat:
```sh
# Listener (dev-box-2)
socat TCP-LISTEN:8080,fork,reuseaddr EXEC:/bin/bash,pty,stderr

# Connect (dev-box-1)
socat TCP:172.20.0.11:8080 -
```

## Cleanup

Remove all containers, images, and resources:
```sh
./init.sh cleanup
```

This command will:
* Stop all containers
* Remove Docker volumes
* Remove project-specific Docker images
* Clean up unused Docker resources

## Shared Directory

The `./shared` directory is mounted in both containers at `/shared`. Use this for:
* Transferring files between containers
* Sharing scripts and payloads
* Collaborative work across environments

The shared directory contains a README with network tool references and usage examples.
