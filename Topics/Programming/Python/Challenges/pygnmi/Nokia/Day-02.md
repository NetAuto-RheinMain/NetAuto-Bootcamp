
## Day 2: Reading Operational Data with gNMI Get (Nokia SR Linux)

### Concepts:

  * **Get RPC**: Retrieving current state and configuration data from the device.
  * **gNMI Paths**: Specifying data points using OpenConfig or native Nokia SR Linux YANG paths.
  * **Encoding**: Understanding JSON, JSON\_IETF, PROTO, ASCII encodings.

### Containerlab Setup (`day2_srl_lab.yaml`):

Same as Day 1. You can reuse the lab or destroy/redeploy.

### Code Examples:

**1. `day2_srl_get_interfaces.py`**
This script gets operational state of all interfaces.

```python
from pygnmi.client import gNMIclient
import json

SRL_IP = "172.20.20.2" # **UPDATE THIS WITH YOUR SRL1 IP**
GNMI_PORT = 57400
USERNAME = "admin"
PASSWORD = "NokiaSrl1!"

if __name__ == "__main__":
    with gNMIclient(
        target=(SRL_IP, GNMI_PORT),
        username=USERNAME,
        password=PASSWORD,
        skip_verify=True,
    ) as gc:
        print(f"Connecting to {SRL_IP}:{GNMI_PORT} to get interface state...")
        try:
            # Corrected path for SR Linux to get operational state of all interfaces
            # The path /interface/oper-state correctly requests the oper-state of interfaces.
            # The response structure, however, puts the list of interfaces under a specific key in 'val'.
            path = ["/interface/oper-state"]

            result = gc.get(path=path, encoding="json_ietf", datatype="state")
            print("\n--- Interface Operational State ---")

            # Debugging: Print the raw result to understand its structure
            print(f"Raw gNMI result: {json.dumps(result, indent=2)}")

            if result and isinstance(result, dict) and 'notification' in result and result['notification']:
                for notification in result['notification']:
                    if 'update' in notification and notification['update']:
                        for update in notification['update']:
                            # Check if 'val' exists and contains the expected interface data
                            if 'val' in update and isinstance(update['val'], dict) and 'srl_nokia-interfaces:interface' in update['val']:
                                interfaces_data = update['val']['srl_nokia-interfaces:interface']
                                
                                # The 'interfaces_data' is a list of dictionaries, each representing an interface.
                                for interface in interfaces_data:
                                    interface_name = interface.get('name')
                                    oper_state = interface.get('oper-state')

                                    if interface_name:
                                        print(f"Interface: {interface_name}, Operational State: {oper_state}")
                                    else:
                                        print(f"Warning: Interface found without a 'name' key: {json.dumps(interface, indent=2)}")
                            else:
                                print(f"Warning: 'val' or 'srl_nokia-interfaces:interface' missing or malformed in update: {update}")
                    else:
                        print(f"Warning: 'update' key missing or empty in notification: {notification}")
            else:
                print("No valid data received for interfaces (or 'notification' key missing/empty).")
        except Exception as e:
            print(f"Error getting interfaces: {e}")

```

**2. `day2_srl_get_system_hostname.py`**
This script gets the system hostname.

```python
from pygnmi.client import gNMIclient
import json

SRL_IP = "172.20.20.2" # **UPDATE THIS WITH YOUR SRL1 IP**
GNMI_PORT = 57400
USERNAME = "admin"
PASSWORD = "NokiaSrl1!"

if __name__ == "__main__":
    with gNMIclient(
        target=(SRL_IP, GNMI_PORT),
        username=USERNAME,
        password=PASSWORD,
         skip_verify=True,
    ) as gc:
        print(f"Connecting to {SRL_IP}:{GNMI_PORT} to get system hostname...")
        try:
            # OpenConfig path for system hostname (config and state)
            path = ["/system/name/host-name"] # OpenConfig path
            result = gc.get(path=path, encoding="json_ietf", datatype="state")
            print("\n--- System Hostname ---")
            if result and 'notification' in result and result['notification']:
                for notification in result['notification']:
                    if 'update' in notification:
                        for update in notification['update']:
                            if 'path' in update and 'val' in update:
                                # The hostname is a simple string value
                                print(f"Hostname: {update['val']}")
            else:
                print("No hostname data received.")
        except Exception as e:
            print(f"Error getting hostname: {e}")

```

### Challenge 2:

  * Run both `day2_srl_get_interfaces.py` and `day2_srl_get_system_hostname.py`.
  * Find the Nokia SR Linux native gNMI path for interface statistics (e.g., `srl_nokia-interfaces:interface/statistics`). You can explore SR Linux documentation or the SR Linux CLI with `info from state <path>`.
  * Modify `day2_srl_get_interfaces.py` to fetch specific statistics (e.g., `in-octets`, `out-octets`) for `ethernet-1/1` using an SR Linux native path.


