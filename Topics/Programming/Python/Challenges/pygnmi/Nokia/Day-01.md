# Day 01

## Prerequisites

Before starting, ensure you have the following set up:

1.  **Python 3.9+**: Installed on your system.
2.  **`pip`**: Python package installer.
3.  **Docker**: Container runtime installed and running.
4.  **Containerlab**: Installed on your Linux host. Refer to the official Containerlab documentation for installation: `https://containerlab.dev/install/`.
5.  **Nokia SR Linux Image**: SR Linux images are publicly available on GitHub Container Registry. You can pull them directly or ensure they are available to Docker. For this tutorial, we'll assume `ghcr.io/nokia/srlinux:latest` or a specific version like `ghcr.io/nokia/srlinux:23.11.1`.
      * To pre-pull: `docker pull ghcr.io/nokia/srlinux:latest`

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

## Day 1: Getting Started with Containerlab and `pygnmi` Capabilities (Nokia SR Linux)

### Concepts:

  * **Containerlab Basics**: How to define and deploy a simple network topology.
  * **gNMI Overview**: Introduction to gRPC Network Management Interface (gNMI) as a modern network management protocol.
  * **`pygnmi` Client Initialization**: Connecting to a gNMI target.
  * **Capabilities RPC**: Discovering the gNMI version, supported YANG modules, and encoding types of the device.

### Containerlab Setup (`day1_srl_lab.yaml`):

```yaml
name: day1_srl_gnmi_lab
topology:
  nodes:
    srl1:
      kind: nokia_srlinux
      image: ghcr.io/nokia/srlinux:latest # Or specify your desired version, e.g., :23.11.1
      # SR Linux enables gNMI by default on port 57400 in the default network instance
      # with admin/admin credentials.
```

Deploy the lab:

```bash
sudo containerlab deploy --topo day1_srl_gnmi_lab.yaml
```

### Code Examples:

**1. `day1_srl_capabilities.py`**
This script connects to `srl1` and retrieves its gNMI capabilities.

```python
from pygnmi.client import gNMIclient
import json
import time

# Device connection details
# To get the IP of srl1:
# 1. After `sudo containerlab deploy --topo day1_srl_gnmi_lab.yaml`, run:
#    `docker inspect day1_srl_gnmi_lab-srl1 | grep "IPAddress"`
#    The IP will likely be in the 172.20.20.0/24 range or similar.
# --- IMPORTANT: Replace with the actual IP of srl1 ---
SRL_IP = "172.20.20.2" # Placeholder: **UPDATE THIS WITH YOUR SRL1 IP**
GNMI_PORT = 57400
USERNAME = "admin"
PASSWORD = "NokiaSrl1!" # Default password for Nokia SR Linux

if __name__ == "__main__":
    # Give SR Linux a moment to boot up and gNMI to become available
    print("Waiting for SR Linux to initialize gNMI...")
    time.sleep(10) # Adjust as needed for your environment

    with gNMIclient(
        target=(SRL_IP, GNMI_PORT),
        username=USERNAME,
        password=PASSWORD,
        skip_verify=True,  # Set to False if you want to verify the server's certificate
    ) as gc:
        print(f"Connecting to {SRL_IP}:{GNMI_PORT}...")
        try:
            capabilities = gc.capabilities()
            print("\n--- gNMI Capabilities ---")
            print(json.dumps(capabilities, indent=2))
        except Exception as e:
            print(f"Error getting capabilities: {e}")

```

**How to get `SRL_IP`:**

1.  After `sudo containerlab deploy --topo day1_srl_gnmi_lab.yaml`, run `docker inspect day1_srl_gnmi_lab-srl1 | grep "IPAddress"`.
2.  Copy the IP address (e.g., `172.20.0.2`) and update the `SRL_IP` variable in `day1_srl_capabilities.py`.

### Challenge 1:

  * Run the `day1_srl_capabilities.py` script and analyze the output.
  * Identify the gNMI version and a few supported YANG modules (e.g., `nokia-srl`, `openconfig-interfaces`).
  * Modify the script to print only the supported gNMI version.

