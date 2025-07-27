# Day 6: Advanced Topics - Error Handling and Custom YANG Paths

### Concepts:

  * **Robust Error Handling**: Implementing `try-except` blocks for network operations.
  * **Custom/Native YANG Paths**: Working with vendor-specific YANG models and paths when OpenConfig is not sufficient or available. Arista's native paths are prefixed with `eos_native:`.
  * **Combining Operations**: Performing multiple Get/Set operations in a single script.

### Containerlab Setup (`day6_lab.yaml`):

```yaml
name: day6_gnmi_lab
topology:
  nodes:
    ceos1:
      kind: arista_ceos
      image: ceos:4.34.0F
    ceos2:
      kind: arista_ceos
      image: ceos:4.34.0F
  links:
    - endpoints: ["ceos1:eth1", "ceos2:eth1"]
```

Deploy the lab:

```bash
sudo containerlab deploy --topo day6_gnmi_lab.yaml
```

**Configure IPs on `ceos1` and `ceos2` for `eth1` in CLI:**

* **ceos1 CLI**:
  ```
  ssh admin@<ceos1-containername> # password: admin
  enable
  configure terminal
  interface Ethernet1
  no switchport
  ip address 10.0.0.1/30
  end
  ```
* **ceos2 CLI**:
  ```
  ssh admin@<ceos2-containername> # password: admin
  enable
  configure terminal
  interface Ethernet1
  no switchport
  ip address 10.0.0.2/30
  end
    ```

### Code Examples:

**1. `day6_robust_config_and_status.py`**
This script attempts to configure an IP on `Ethernet2` on both `ceos1` and `ceos2`, and then verifies their link status. It includes basic error handling.

```python
from pygnmi.client import gNMIclient
import json

CEOS1_IP = "172.20.20.2" # **UPDATE THIS WITH YOUR CEOS1 IP**
CEOS2_IP = "172.20.20.3" # **UPDATE THIS WITH YOUR CEOS2 IP**
GNMI_PORT = 6030
USERNAME = "admin"
PASSWORD = "admin"

DEVICES = {
    "ceos1": CEOS1_IP,
    "ceos2": CEOS2_IP
}

def configure_interface_ip(gc, device_name, interface_name, ip_address, prefix_length):
    print(f"\n--- Configuring {interface_name} on {device_name} with {ip_address}/{prefix_length} ---")

    # To ensure the interface is a Layer 3 (routed) port, delete the 'switched-vlan' container.
    delete_switchport = [
        f"/interfaces/interface[name={interface_name}]/ethernet/switched-vlan"
    ]

    # Ensure the main interface is enabled
    enable_interface = [
        (
            f"/interfaces/interface[name={interface_name}]/config/enabled",
            True 
        )
    ]

    update_path_ip = [
        # 1. Enable IPv4 on the subinterface

            f"/interfaces/interface[name={interface_name}]/subinterfaces/subinterface[index=0]/openconfig-if-ip:ipv4/config",
            {"enabled": True} # Dict will be JSON-encoded by pygnmi
        ),
        # 2. Set IP address and prefix-length
        (
            f"/interfaces/interface[name={interface_name}]/subinterfaces/subinterface[index=0]/openconfig-if-ip:ipv4/addresses/address[ip={ip_address}]/config",
            {"ip": ip_address, "prefix-length": prefix_length} # Dict will be JSON-encoded by pygnmi
        )
    ]

    try:
        # 1. Delete the switched-vlan container (equivalent to 'no switchport')
        print(f"Attempting to delete switched-vlan config for {interface_name} on {device_name}...")
        response_delete_switchport = gc.set(delete=delete_switchport, encoding="json_ietf")
        print(f"Delete switchport response: {json.dumps(response_delete_switchport, indent=2)}")
        print(f"Successfully ensured {interface_name} is a routed port on {device_name}.")

        # 2. Ensure the main interface is enabled
        print(f"Attempting to enable {interface_name} on {device_name}...")
        response_enable_interface = gc.set(update=enable_interface, encoding="json_ietf")
        print(f"Enable interface response: {json.dumps(response_enable_interface, indent=2)}")
        print(f"Successfully enabled {interface_name} on {device_name}.")

        # 3. Configure the IP address and IPv4 enabled status
        print(f"Attempting to configure IP address {ip_address}/{prefix_length} on {interface_name}.")
        response_ip_config = gc.set(update=update_path_ip, encoding="json_ietf")
        print(f"IP configuration response: {json.dumps(response_ip_config, indent=2)}")
        print(f"Successfully configured IP on {interface_name} on {device_name}.")
        return True
    except Exception as e:
        print(f"Failed to configure {interface_name} on {device_name}: {e}")
        return False

def get_interface_oper_status(gc, device_name, interface_name):
    print(f"\n--- Getting operational status of {interface_name} on {device_name} ---")
    path = [f"/interfaces/interface[name={interface_name}]/state/oper-status"]
    try:
        result = gc.get(path=path, encoding="json_ietf", datatype="state")
        if result and 'notification' in result and result['notification']:
            for notification in result['notification']:
                if 'update' in notification:
                    for item in notification['update']:
                        if 'path' in item and 'val' in item:
                            status = item['val']
                            print(f"Operational status of {interface_name} on {device_name}: {status}")
                            return status
        print(f"Could not retrieve operational status for {interface_name} on {device_name}.")
        return None
    except Exception as e:
        print(f"Error getting operational status for {interface_name} on {device_name}: {e}")
        return None

if __name__ == "__main__":
    for device_name, ip_address in DEVICES.items():
        with gNMIclient(
            target=(ip_address, GNMI_PORT),
            username=USERNAME,
            password=PASSWORD,
            insecure=True
        ) as gc:
            ip_addr = f"172.16.0.{1 if device_name == 'ceos1' else 2}"
            configure_interface_ip(gc, device_name, "Ethernet2", ip_addr, 24)
            get_interface_oper_status(gc, device_name, "Ethernet1")
```

### Challenge 6:

  * Using an Arista native gNMI path (e.g., something under `eos_native:/Smash/routing/status/route`), try to retrieve the routing table of `ceos1`.
  * Implement robust error handling in `day6_robust_config_and_status.py` to catch specific gRPC errors (e.g., `grpc.RpcError`) and provide more informative messages to the user.
  * Extend `day6_robust_config_and_status.py` to also configure an OSPF process on both `ceos1` and `ceos2` using `pygnmi` and OpenConfig paths (if supported by cEOS for OSPF config via gNMI). Verify the OSPF neighbor state.

