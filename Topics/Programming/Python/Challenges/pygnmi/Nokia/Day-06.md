
## Day 6: Advanced Topics - Error Handling and Custom YANG Paths (Nokia SR Linux)

### Concepts:

  * **Robust Error Handling**: Implementing `try-except` blocks for network operations.
  * **Custom/Native YANG Paths**: Working with vendor-specific YANG models and paths when OpenConfig is not sufficient or available. For SR Linux, these are often prefixed with `srl_nokia-state:/` or `srl_nokia-conf:/`.
  * **Combining Operations**: Performing multiple Get/Set operations in a single script.

### Containerlab Setup (`day6_srl_lab.yaml`):

```yaml
name: day6_srl_gnmi_lab
topology:
  nodes:
    srl1:
      kind: nokia_srlinux
      image: ghcr.io/nokia/srlinux:latest
    srl2:
      kind: nokia_srlinux
      image: ghcr.io/nokia/srlinux:latest
  links:
    - endpoints: ["srl1:e1-1", "srl2:e1-1"] # ethernet-1/1
```

Deploy the lab:

```bash
sudo containerlab deploy --topo day6_srl_gnmi_lab.yaml
```

**Configure IPs on `srl1` and `srl2` for `ethernet-1/1` in CLI:**

  * **srl1 CLI (`/usr/bin/sr_cli`)**:
    ```
    enter candidate
    set /interface ethernet-1/1 subinterface 0 admin-state enable
    set /interface ethernet-1/1 subinterface 0 ipv4 address 10.0.0.1/30
    commit now
    quit
    ```
  * **srl2 CLI (`/usr/bin/sr_cli`)**:
    ```
    enter candidate
    set /interface ethernet-1/1 subinterface 0 admin-state enable
    set /interface ethernet-1/1 subinterface 0 ipv4 address 10.0.0.2/30
    commit now
    quit
    ```

### Code Examples:

**1. `day6_srl_robust_config_and_status.py`**
This script attempts to configure an IP on `ethernet-1/2` on both `srl1` and `srl2`, and then verifies their link status. It includes basic error handling.

```python
from pygnmi.client import gNMIclient
import json
import time

SRL1_IP = "172.20.20.3" # **UPDATE THIS WITH YOUR SRL1 IP**
SRL2_IP = "172.20.20.2" # **UPDATE THIS WITH YOUR SRL2 IP**
GNMI_PORT = 57400
USERNAME = "admin"
PASSWORD = "NokiaSrl1!"

DEVICES = {
    "srl1": SRL1_IP,
    "srl2": SRL2_IP
}

def configure_interface_ip(gc, device_name, interface_name, ip_address, prefix_length):
    print(f"\n--- Configuring {interface_name} on {device_name} with {ip_address}/{prefix_length} ---")
    updates = [
        # Set admin-state enabled for the main interface
        (
            f"/interface[name={interface_name}]",
            {"admin-state":"enable"}
        ),
        # Set admin-state enabled for subinterface 0
        (
            f"/interface[name={interface_name}]/subinterface[index=0]",
            {"admin-state":"enable"}
        ),
        # Configure IPv4 address - CORRECTED PATH AND VALUE
        (
            f"/interface[name={interface_name}]/subinterface[index=0]/ipv4/address[ip-prefix={ip_address}/{prefix_length}]",
            {} # Empty dictionary as ip-prefix is the key leaf
        )
    ]
    try:
        response = gc.set(update=updates, encoding="json_ietf")
        print(f"Configuration response: {json.dumps(response, indent=2)}")
        
        # CORRECTED SUCCESS CHECK:
        if response and 'response' in response and isinstance(response['response'], list):
            # You can add more granular checks here if needed,
            # e.g., iterating through response['response'] to ensure all ops are 'UPDATE'
            print(f"Successfully configured {interface_name} on {device_name}.")
            return True
        else:
            print(f"Configuration for {interface_name} on {device_name} might not have been fully successful. Unexpected response structure.")
            return False
    except Exception as e:
        print(f"Failed to configure {interface_name} on {device_name}: {e}")
        return False

def get_interface_oper_status(gc, device_name, interface_name):
    print(f"\n--- Getting operational status of {interface_name} on {device_name} ---")
    # OpenConfig path for operational status
    path = [f"/interface[name={interface_name}]/oper-state"]
    try:
        result = gc.get(path=path, encoding="json_ietf", datatype="state")
        # print(f"Raw oper status result: {json.dumps(result, indent=2)}") # Debugging line
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
            skip_verify=True,
        ) as gc:
            # Configure IP on ethernet-1/2 (example)
            interface_ip = f"172.16.0.{1 if device_name == 'srl1' else 2}"
            configure_interface_ip(gc, device_name, "ethernet-1/2", interface_ip, 24)
            
            # Add a small delay to allow configuration to settle
            time.sleep(2) 
            
            # Get operational status of ethernet-1/1 (link between srl1 and srl2)
            get_interface_oper_status(gc, device_name, "ethernet-1/1")
```

### Challenge 6:

  * Using a Nokia SR Linux native gNMI path (e.g., `srl_nokia-state:/network-instance[name=default]/routes/route`), try to retrieve the routing table of `srl1`.
  * Implement robust error handling in `day6_srl_robust_config_and_status.py` to catch specific gRPC errors (e.g., `grpc.RpcError`) and provide more informative messages to the user.
  * **Bonus**: Extend `day6_srl_robust_config_and_status.py` to also configure an OSPF process on both `srl1` and `srl2` using `pygnmi` and OpenConfig paths (if supported and well-documented for SR Linux). Verify the OSPF neighbor state.
      * **Hint**: OpenConfig OSPF paths are complex. SR Linux has robust native YANG for routing protocols. You might find `srl_nokia-network-instance:network-instance[name=default]/protocols/ospf/v2/area` more practical.


