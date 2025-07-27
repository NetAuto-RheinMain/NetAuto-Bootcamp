# Day 01

## Prerequisites

Before starting, ensure you have the following set up:

1.  **Python 3.9+**: Installed on your system.
2.  **`pip`**: Python package installer.
3.  **Docker**: Container runtime installed and running.
4.  **Containerlab**: Installed on your Linux host. Refer to the official Containerlab documentation for installation: `https://containerlab.dev/install/`.
5.  **Arista cEOS-lab Image**: You will need to download a cEOS-lab image (e.g., `cEOS-lab-<version>.tar.xz`) from the Arista support portal. You typically need an Arista account to access these images.
      * **Import the cEOS image into Docker**: After downloading, import it using `docker import <path-to-ceos-image>.tar.xz arista/ceos:<version>` (e.g., `docker import cEOS-lab-4.30.6M.tar.xz arista/ceos:4.30.6M`). You can also tag it as `latest` for convenience: `docker tag arista/ceos:4.30.6M arista/ceos:latest`.

## Installation of `pygnmi`

```bash
pip install pygnmi
```

## Tutorial Structure

Each day will include:

  * **Concepts**: Explanation of `pygnmi` features and gNMI RPCs.
  * **Containerlab Setup**: A YAML file to define the lab topology.
  * **Code Examples**: Python scripts demonstrating `pygnmi` usage.
  * **Challenges**: Exercises to reinforce learning.

-----

## Day 1: Getting Started with Containerlab and `pygnmi` Capabilities

### Concepts:

  * **Containerlab Basics**: How to define and deploy a simple network topology.
  * **gNMI Overview**: Introduction to gRPC Network Management Interface (gNMI) as a modern network management protocol.
  * **`pygnmi` Client Initialization**: Connecting to a gNMI target.
  * **Capabilities RPC**: Discovering the gNMI version, supported YANG modules, and encoding types of the device.

### Containerlab Setup (`day1_lab.yaml`):

```yaml
name: day1_gnmi_lab
topology:
  nodes:
    ceos1:
      kind: arista_ceos
      image: ceos:4.34.0F # specify your downloaded version, e.g., arista/ceos:4.30.6M
      # Arista cEOS enables gNMI by default on port 6030 in the MGMT VRF
      # with admin/admin credentials.
```

Deploy the lab:

```bash
sudo containerlab deploy --topo day1_gnmi_lab.yaml
```

### Code Examples:

**1. `day1_capabilities.py`**
This script connects to `ceos1` and retrieves its gNMI capabilities.

```python
from pygnmi.client import gNMIclient
import json

# Device connection details (adjust IP if your Docker network assigns a different one)
# Containerlab typically assigns IP addresses to the management interface (eth0)
# You can find the IP by running `docker inspect <container_name> | grep "IPAddress"`
# Or, if you're running on the host, use the IP assigned by Containerlab's management network.
# For simplicity in this tutorial, we'll assume a common setup where
# the container is reachable via its hostname in the Docker network.
# You can use 'localhost' if running pygnmi from within another container in the same lab,
# or the assigned IP from the host. For direct host access to a single node lab,
# Containerlab often exposes the management interface, but it's more reliable
# to get the IP dynamically or use a known range.
# For simplicity, we'll use a placeholder IP and instruct to find the actual IP.

# --- IMPORTANT: Replace with the actual IP of ceos1 ---
# To get the IP:
# 1. After `sudo containerlab deploy --topo day1_gnmi_lab.yaml`, run:
#    `docker inspect day1_gnmi_lab-ceos1 | grep "IPAddress"`
#    The IP will likely be in the 172.20.20.0/24 range or similar.
#    Alternatively, if `clab inspect` works for you, it can show node IPs.
# ---
CEOS_IP = "172.20.20.2" # Placeholder: **UPDATE THIS WITH YOUR CEOS1 IP**
GNMI_PORT = 6030
USERNAME = "admin"
PASSWORD = "admin" # Default password for Arista cEOS

if __name__ == "__main__":
    with gNMIclient(
        target=(CEOS_IP, GNMI_PORT),
        username=USERNAME,
        password=PASSWORD,
        insecure=True  # Use insecure for lab environments without proper TLS setup
    ) as gc:
        print(f"Connecting to {CEOS_IP}:{GNMI_PORT}...")
        try:
            capabilities = gc.capabilities()
            print("\n--- gNMI Capabilities ---")
            print(json.dumps(capabilities, indent=2))
        except Exception as e:
            print(f"Error getting capabilities: {e}")

```

**How to get `CEOS_IP`:**

1.  After `sudo containerlab deploy --topo day1_gnmi_lab.yaml`, run `docker inspect day1_gnmi_lab-ceos1 | grep "IPAddress"`.
2.  Copy the IP address (e.g., `172.20.0.2`) and update the `CEOS_IP` variable in `day1_capabilities.py`.

### Challenge 1:

  * Run the `day1_capabilities.py` script and analyze the output.
  * Identify the gNMI version and a few supported YANG modules.
  * Modify the script to print only the supported gNMI version.
