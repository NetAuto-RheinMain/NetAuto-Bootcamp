# Day 2: Reading Operational Data with gNMI Get

### Concepts:

  * **Get RPC**: Retrieving current state and configuration data from the device.
  * **gNMI Paths**: Specifying data points using OpenConfig or native vendor YANG paths.
  * **Encoding**: Understanding JSON, JSON\_IETF, PROTO, ASCII encodings.

### Containerlab Setup (`day2_lab.yaml`):

Same as Day 1, or you can destroy and redeploy:

```bash
sudo containerlab destroy --topo day1_gnmi_lab.yaml
sudo containerlab deploy --topo day2_lab.yaml # (if you rename day1_lab.yaml)
```

### Code Examples:

**1. `day2_get_interfaces.py`**
This script gets operational state of all interfaces.

```python
from pygnmi.client import gNMIclient
import json

CEOS_IP = "172.20.20.2" # **UPDATE THIS WITH YOUR CEOS1 IP**
GNMI_PORT = 6030
USERNAME = "admin"
PASSWORD = "admin"

if __name__ == "__main__":
    with gNMIclient(
        target=(CEOS_IP, GNMI_PORT),
        username=USERNAME,
        password=PASSWORD,
        insecure=True
    ) as gc:
        print(f"Connecting to {CEOS_IP}:{GNMI_PORT} to get interface state...")
        try:
            # OpenConfig path for all interfaces' state data
            path = ["/interfaces/interface/state"]
            result = gc.get(path=path, encoding="json_ietf", datatype="state")
            print("\n--- Interface Operational State ---")

            if result and 'notification' in result and result['notification']:
                for notification in result['notification']:
                    if 'update' in notification:
                        for update in notification['update']:
                            if 'path' in update and 'val' in update:
                                # 'path' contains the YANG path elements
                                # 'val' contains the actual data as a dictionary (decoded JSON)

                                # Reconstruct the path for display
                                path_elements = []
                                if 'elem' in update['path']:
                                    for elem in update['path']['elem']:
                                        segment = elem.get('name', '')
                                        keys = elem.get('keys', {})
                                        if keys:
                                            key_str = ",".join(f"{k}={v}" for k, v in keys.items())
                                            segment += f"[{key_str}]"
                                        path_elements.append(segment)
                                path_str = "/" + "/".join(path_elements)


                                # The 'val' itself is the dictionary representing the data
                                print(f"Path: {path_str}")
                                print(json.dumps(update['val'], indent=2))
                            else:
                                print(f"Update missing 'path' or 'val': {update}")
                    elif 'delete' in notification:
                        # Handle delete notifications if they occur
                        print(f"Deleted Path: {notification['delete']}")
                if not any('update' in n or 'delete' in n for n in result['notification']):
                     print("No updates or deletes in notification (possibly empty response).")
            else:
                print("No data received for interfaces or unexpected response format.")
        except Exception as e:
            print(f"Error getting interfaces: {e}")

```

**2. `day2_get_system_hostname.py`**
This script gets the system hostname.

```python
from pygnmi.client import gNMIclient
import json

CEOS_IP = "172.20.20.2" # **UPDATE THIS WITH YOUR CEOS1 IP**
GNMI_PORT = 6030
USERNAME = "admin"
PASSWORD = "admin"

if __name__ == "__main__":
    with gNMIclient(
        target=(CEOS_IP, GNMI_PORT),
        username=USERNAME,
        password=PASSWORD,
        insecure=True
    ) as gc:
        print(f"Connecting to {CEOS_IP}:{GNMI_PORT} to get system hostname...")
        try:
            # OpenConfig path for system hostname (config and state)
            path = ["/system/state/hostname"]
            result = gc.get(path=path, encoding="json_ietf", datatype="state")
            print("\n--- System Hostname ---")
            if result and 'notification' in result and result['notification']:
                for notification in result['notification']:
                    if 'update' in notification:
                        for update in notification['update']:
                            if 'path' in update and 'val' in update:
                                # The hostname is often a simple string value
                                print(f"Hostname: {update['val']}")
            else:
                print("No hostname data received.")
        except Exception as e:
            print(f"Error getting hostname: {e}")
```

### Challenge 2:

  * Run both `day2_get_interfaces.py` and `day2_get_system_hostname.py`.
  * Find the Arista native gNMI path for interface counters (e.g., `eos_native:/Smash/interfaces/interface/counters`). You might need to consult Arista's gNMI documentation or use `gnmic` CLI tool with `--path /` and explore.
  * Modify `day2_get_interfaces.py` to fetch specific counters (e.g., `in-octets`, `out-octets`) for `Ethernet1` using an Arista native path.

-----
