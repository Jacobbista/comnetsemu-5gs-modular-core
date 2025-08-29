# 5G Core Modular Architecture with ComNetsEmu

This project explores a **modular architecture** of the 5G Core (5GC) by running each Network Function (NF) in a separate Docker container. This approach enables better scalability, maintainability, and deployment flexibility for 5G network research and development.

## 🔗 Related Project

This project is an extension of the [5G Network Virtualization with ComNetsEmu](https://github.com/jacobbista/comnetsemu_5gs) repository, where the objective here is to **modularize each network function** into separate containers for enhanced isolation and management.

## 📦 Software Versions

- **[Open5GS](https://github.com/open5gs/open5gs)**: v2.7.5
- **[UERANSIM](https://github.com/aligungr/UERANSIM)**: v3.2.7
- **[ComNetsEmu](https://github.com/stevelorenz/comnetsemu)**: v0.3.1
- **Docker**: v26.1.3

## 🚀 Quick Start

### Option 1: Use Pre-built Images (Recommended)

The fastest way to get started is using pre-built Docker images from Docker Hub:

1. **Clone the repository**
   ```bash
   git clone https://github.com/Jacobbista/comnetsemu-5gs-modular-core
   cd comnetsemu-5gs-modular-core
   ```

2. **Pull pre-built images**
   ```bash
   cd build
   ./dockerhub_pull.sh
   ```

3. **Install Python modules**
   ```bash
   ./pyModules.sh
   ```

4. **Start the 5G network**
   ```bash
   cd ..
   ./runTopology.sh
   ```

### Option 2: Build Images Locally

If you prefer to build images locally or need custom modifications:

1. **Clone the repository**
   ```bash
   git clone https://github.com/Jacobbista/comnetsemu-5gs-modular-core
   cd comnetsemu-5gs-modular-core
   ```

2. **Build Docker images**
   ```bash
   cd build
   ./build.sh
   ```

3. **Install Python modules**
   ```bash
   ./pyModules.sh
   ```

4. **Build MEC Server**
   ```bash
   cd ../mec_server
   docker build -t mec_server .
   ```

5. **Start the 5G network**
   ```bash
   cd ..
   ./runTopology.sh
   ```

## 🐳 Docker Hub Scripts

### Docker Hub Pull Script (`dockerhub_pull.sh`)

**Purpose**: Pulls pre-built Docker images from Docker Hub (recommended for most users)

**Usage**:
```bash
cd build
./dockerhub_pull.sh
```

**What it does**:
- Pulls `jacobbista/comnetsemu-5gc:latest`
- Pulls `jacobbista/comnetsemu-ueransim:latest`
- Pulls `jacobbista/comnetsemu-mec:latest`
- Tags them locally as `my5gc_v2-7-5`, `myueransim_v3-2-7`, and `mec_server`

**Benefits**:
- ✅ **Fast**: No compilation time
- ✅ **Reliable**: Pre-tested images
- ✅ **Consistent**: Same images for everyone
- ✅ **Space-efficient**: No build dependencies

### Docker Hub Push Script (`push_to_dockerhub.sh`)

**Purpose**: Tags and pushes locally built images to Docker Hub (for contributors)

**Usage**:
```bash
cd build
./push_to_dockerhub.sh your_username
```

**What it does**:
- Tags local images with your Docker Hub username
- Pushes them to `your_username/comnetsemu-*` repositories
- Creates both version-specific and `latest` tags

**When to use**:
- 🔧 You've modified the source code
- 🔧 You want to share custom builds
- 🔧 You're contributing to the project

## 🏗️ Architecture Overview

### Modular 5G Core Components

Each Network Function runs in its own dedicated container:

| Component | Container | IP Address | Description |
|-----------|-----------|------------|-------------|
| **NRF** | `nrf` | `192.168.0.210` | Network Repository Function |
| **SMF** | `smf` | `192.168.0.211` | Session Management Function |
| **AMF** | `amf` | `192.168.0.212` | Access and Mobility Management Function |
| **AUSF** | `ausf` | `192.168.0.213` | Authentication Server Function |
| **UDM** | `udm` | `192.168.0.214` | Unified Data Management |
| **UDR** | `udr` | `192.168.0.215` | Unified Data Repository |
| **PCF** | `pcf` | `192.168.0.216` | Policy Control Function |
| **BSF** | `bsf` | `192.168.0.217` | Binding Support Function |
| **NSSF** | `nssf` | `192.168.0.218` | Network Slice Selection Function |
| **UPF-Cloud** | `upf_cld` | `192.168.0.112` | User Plane Function (Cloud) |
| **UPF-MEC** | `upf_mec` | `192.168.0.113` | User Plane Function (MEC) |
| **MongoDB** | `mongo` | `192.168.0.200` | Database for 5GC + WebUI (port 3000) |
| **MEC Server** | `mec_server` | `192.168.0.135` | Multi-Access Edge Computing Server |

> **Note**: The IP addresses listed above are the actual IPs configured in the `topology.py` file. If you wish to use different static IPs within the Mininet network, you can modify them in the `topology.py` file and the corresponding container configuration files.

### Radio Access Network

- **gNodeB 1**: `gnb1` - `192.168.0.131` (UERANSIM)
- **gNodeB 2**: `gnb2` - `192.168.0.132` (UERANSIM)
- **UE 1**: `ue1` - `192.168.0.133` (UERANSIM)
- **UE 2**: `ue2` - `192.168.0.134` (UERANSIM)

### Multi-Access Edge Computing

- **MEC Server**: `mec_server` - `192.168.0.135` - Integrated with UPF-MEC for low-latency applications  
  > _Note: This is a simple dummy Python server provided for demonstration purposes._

## 📋 Usage

### Starting the 5G Network

1. **Launch the topology**

   To start the topology in a clean way (removing old containers and network interfaces before starting), use:
   ```bash
   ./runTopology.sh
   ```
   Alternatively, for a manual start without cleanup:
   ```bash
   sudo python3 topology.py
   ```

2. **Run the test network**
   ```bash
   sudo python3 TestNet5G.py
   ```

### Container Management

- **Enter a specific container**
  ```bash
  ./enter_container.sh <container_name>
  ```

- **View container logs**
  ```bash
  docker logs <container_name>
  ```

- **Clean up environment**
  ```bash
  ./clean.sh
  ```

### Network Functions Initialization

Each NF has its own initialization script in `open5gs/scripts/`:

```bash
# Example: Initialize AMF
./open5gs/scripts/amf_init.sh

# Example: Initialize SMF
./open5gs/scripts/smf_init.sh
```

## 🔧 Configuration

### Network Function Configurations

Configuration files are located in `open5gs/config/`:

- `amf.yaml` - AMF configuration
- `smf.yaml` - SMF configuration
- `nrf.yaml` - NRF configuration
- `upf_mec.yaml` - UPF MEC configuration
- `upf_cld.yaml` - UPF Cloud configuration
- And more...

### UERANSIM Configurations

UE and gNodeB configurations are in `ueransim/config/`:

- `open5gs-gnb.yaml` - gNodeB 1 configuration
- `open5gs-gnb_2.yaml` - gNodeB 2 configuration  
- `open5gs-ue.yaml` - UE 1 configuration
- `open5gs-ue_2.yaml` - UE 2 configuration

## 📊 Monitoring & Debugging

### Health Checks

The project includes sophisticated health check mechanisms:

- **TCP/UDP Port Monitoring**: Checks service availability
- **Service-Specific Health Checks**: Tailored for each NF type
- **Automated Recovery**: Container restart on failure

### Logging

- **Centralized Logging**: All NF logs in `/open5gs/install/var/log/open5gs/`
- **Real-time Monitoring**: Use `docker logs -f <container_name>`
- **Network Capture**: `./start_tcpdump.sh` for packet analysis

## 🌐 Network Slicing

The architecture supports multiple network slices:

- **Slice 1**: SST=1, SD=1 (eMBB - Enhanced Mobile Broadband)
- **Slice 2**: SST=2, SD=1 (URLLC - Ultra-Reliable Low-Latency Communications)

## 🔬 Research Applications

This modular architecture enables:

- **Network Function Scaling**: Independent scaling of each NF
- **Fault Isolation**: Failures contained within individual containers
- **Performance Analysis**: Per-NF resource monitoring
- **Service Chaining**: Flexible NF deployment patterns
- **Edge Computing**: MEC integration for low-latency applications

## 🛠️ Troubleshooting

### Common Issues

1. **UE Registration Failure**
   - Check AMF IP configuration in gNodeB config
   - Verify PLMN settings match across all components

2. **Container Connectivity Issues**
   - Verify Docker network configuration
   - Check IP address assignments

3. **Database Connection Problems**
   - Ensure MongoDB container is running
   - Check database URI in NF configurations

### Debug Commands

```bash
# Check container status
docker ps -a

# View specific NF logs
docker logs <nf-container-name>

# Network connectivity test
docker exec <container> ping <target-ip>

# Enter container for debugging
./enter_container.sh <container-name>
```

## 📈 Performance Optimization

- **Resource Limits**: Configure appropriate CPU/memory limits
- **Network Optimization**: Use Docker's networking features
- **Database Tuning**: Optimize MongoDB for your use case
- **Load Balancing**: Implement for high-traffic scenarios

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🙏 Acknowledgments

- [Open5GS](https://github.com/open5gs/open5gs) team for the excellent 5G Core implementation
- [UERANSIM](https://github.com/aligungr/UERANSIM) team for the 5G UE/gNodeB simulator
- [ComNetsEmu](https://github.com/stevelorenz/comnetsemu) for the network emulation framework

---

**Note**: Remember to run `docker image prune` to clean up disk space after building images to save space :).