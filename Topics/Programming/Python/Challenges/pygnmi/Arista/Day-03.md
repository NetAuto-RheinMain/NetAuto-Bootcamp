
# Day 3: Configuring Devices with gNMI Set (Update/Replace)

### Concepts:

  * **Set RPC**: Modifying device configuration.
  * **Update Operation**: Merges provided configuration with existing configuration.
  * **Replace Operation**: Replaces the entire target path with the provided configuration.
  * **YANG Paths for Configuration**: Understanding how to construct paths for configuration changes.

### Containerlab Setup (`day3_lab.yaml`):

Same as previous days.

### Code Examples:

**1. `day3_set_interface_description.py`**
This script sets a description on `Ethernet1`.

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
        print(f"Connecting to {CEOS_IP}:{GNMI_PORT} to set interface description...")
        try:
            # Define the update operation
            # The 'update' argument expects a list of (path, value) tuples.
            update = [
                (
                    "/interfaces/interface[name=Ethernet1]/config/description",
                    json.dumps("Configured by pygnmi Day 3 Tutorial") # This would become "\"Configured by...\""
                )
            ]
            # When using json_ietf, the 'value' in the tuple should be the Python object
            # that pygnmi will then serialize to JSON.
            # For a simple string, it's just the string.
            # For more complex data, it would be a dict or list.
            response = gc.set(update=update, encoding="json_ietf")
            print("\n--- Set Operation Response ---")
            print(json.dumps(response, indent=2))

            # Verify the change by getting the description
            path_verify = ["/interfaces/interface[name=Ethernet1]/config/description"]
            result_verify = gc.get(path=path_verify, encoding="json_ietf", datatype="config")
            print("\n--- Verified Interface Description ---")
            if result_verify and 'notification' in result_verify and result_verify['notification']:
                for notification in result_verify['notification']:
                    if 'update' in notification:
                        for item in notification['update']:
                            if 'path' in item and 'val' in item:
                                # When datatype="config" and encoding="json_ietf",
                                # 'val' is the Python object (string in this case)
                                print(f"Ethernet1 Description: {item['val']}")
            else:
                print("Failed to verify description or no update found.")
        except Exception as e:
            print(f"Error setting interface description: {e}")
```

**2. `day3_set_hostname.py`**
This script sets the system hostname.

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
        print(f"Connecting to {CEOS_IP}:{GNMI_PORT} to set hostname...")
        try:
            # Define the update operation for hostname
            update = [
                (
                    "/system/config/hostname",
                    json.dumps("pygnmi-ceos-lab")
                )
            ]
            response = gc.set(update=update, encoding="json_ietf")
            print("\n--- Set Hostname Response ---")
            print(json.dumps(response, indent=2))

            # Verify the change
            path_verify = ["/system/state/hostname"]
            result_verify = gc.get(path=path_verify, encoding="json_ietf", datatype="state")
            print("\n--- Verified Hostname ---")
            if result_verify and 'notification' in result_verify and result_verify['notification']:
                for notification in result_verify['notification']:
                    if 'update' in notification:
                        for item in notification['update']:
                            if 'path' in item and 'val' in item:
                                print(f"Current Hostname: {item['val']}")
            else:
                print("Failed to verify hostname.")

        except Exception as e:
            print(f"Error setting hostname: {e}")
```

### Challenge 3:

  * Using `pygnmi`, configure an IP address (e.g., `192.168.1.1/24`) on `Ethernet2` of `ceos1`.
  * After configuring, use a `get` operation to verify the IP address and its status.
  * **Bonus**: Attempt to use the `replace` operation instead of `update` to change the hostname. Observe the difference in behavior if any, and understand why `update` is often preferred for incremental changes.
