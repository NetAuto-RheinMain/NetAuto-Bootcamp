## Day 3: Configuring Devices with gNMI Set (Update/Replace) (Nokia SR Linux)

### Concepts:

  * **Set RPC**: Modifying device configuration.
  * **Update Operation**: Merges provided configuration with existing configuration.
  * **Replace Operation**: Replaces the entire target path with the provided configuration.
  * **YANG Paths for Configuration**: Understanding how to construct paths for configuration changes.

### Containerlab Setup (`day3_srl_lab.yaml`):

Same as previous days.

### Code Examples:

**1. `day3_srl_set_interface_description.py`**
This script sets a description on `ethernet-1/1`.

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
        print(f"Connecting to {SRL_IP}:{GNMI_PORT} to set interface description...")
        try:
            # Define the update operation
            # OpenConfig path for interface configuration
            update = [
                (
                    "/interface[name=ethernet-1/1]",
                    {"description":"Configured by pygnmi Day 3 Tutorial - SRL"} 
                )
            ]
            response = gc.set(update=update, encoding="json_ietf")
            print("\n--- Set Operation Response ---")
            print(json.dumps(response, indent=2))

            # Verify the change by getting the description
            path_verify = ["/interface[name=ethernet-1/1]/description"]
            result_verify = gc.get(path=path_verify, encoding="json_ietf", datatype="config")
            print("\n--- Verified Interface Description ---")
            if result_verify and 'notification' in result_verify and result_verify['notification']:
                for notification in result_verify['notification']:
                    if 'update' in notification:
                        for item in notification['update']:
                            if 'path' in item and 'val' in item:
                                print(f"ethernet-1/1 Description: {item['val']}")
            else:
                print("Failed to verify description.")
        except Exception as e:
            print(f"Error setting interface description: {e}")
```

**2. `day3_srl_set_hostname.py`**
This script sets the system hostname.

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
        print(f"Connecting to {SRL_IP}:{GNMI_PORT} to set hostname...")
        try:
            # Define the update operation for hostname
            update = [
                (
                    "/system/name",
                    {"host-name":"pygnmi-srl-lab"}
                )
            ]
            response = gc.set(update=update, encoding="json_ietf")
            print("\n--- Set Hostname Response ---")
            print(json.dumps(response, indent=2))

            # Verify the change
            path_verify = ["/system/name/host-name"]
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

  * Using `pygnmi`, configure an IP address (e.g., `192.168.1.1/24`) on `ethernet-1/2` of `srl1`. Remember SR Linux interface naming (`ethernet-X/Y`).
      * **Hint**: OpenConfig path for IPv4 address on subinterface: `/interfaces/interface[name=ethernet-1/2]/subinterfaces/subinterface[index=0]/ipv4/addresses/address[ip=192.168.1.1]/config/prefix-length` and `/interfaces/interface[name=ethernet-1/2]/subinterfaces/subinterface[index=0]/ipv4/addresses/address[ip=192.168.1.1]/config/ip`. Also ensure the subinterface `index=0` is enabled: `/interfaces/interface[name=ethernet-1/2]/subinterfaces/subinterface[index=0]/config/enabled: true`.
  * After configuring, use a `get` operation to verify the IP address and its state.
  * **Bonus**: Attempt to use the `replace` operation instead of `update` to change the hostname. Observe the difference in behavior if any, and understand why `update` is often preferred for incremental changes.
