

## Day 4: Deleting Configuration with gNMI Set (Delete)

### Concepts:

  * **Set RPC with Delete Operation**: Removing existing configuration from the device.

### Containerlab Setup (`day4_lab.yaml`):

Same as previous days. Ensure you have the configuration from Day 3 (e.g., IP address on `Ethernet2`) in place before starting this day's challenges.

### Code Examples:

**1. `day4_delete_interface_description.py`**
This script deletes the description from `Ethernet1`.

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
        print(f"Connecting to {CEOS_IP}:{GNMI_PORT} to delete interface description...")
        try:
            # Ensure a description exists first (optional, for testing flow)
            # You might want to run day3_set_interface_description.py beforehand
            # Or manually configure it:
            # ceos1(config)#interface Ethernet1
            # ceos1(config-if-Et1)#description "Test Description"

            # Define the delete operation
            delete_path = ["/interfaces/interface[name=Ethernet1]/config/description"]
            
            response = gc.set(delete=delete_path, encoding="json_ietf")
            print("\n--- Delete Operation Response ---")
            print(json.dumps(response, indent=2))

            # Verify the deletion
            path_verify = ["/interfaces/interface[name=Ethernet1]/config/description"]
            result_verify = gc.get(path=path_verify, encoding="json_ietf", datatype="config")
            print("\n--- Verified Interface Description After Deletion ---")
            # If deleted, the path should ideally not return any data
            if result_verify and 'notification' in result_verify and result_verify['notification']:
                for notification in result_verify['notification']:
                    if 'update' in notification:
                        print("Description still present (or partial data received).")
                        print(json.dumps(notification['update'], indent=2))
                    elif 'delete' in notification:
                        print("Description successfully deleted (indicated by a delete notification).")
            else:
                print("Description successfully deleted (no data returned for the path).")

        except Exception as e:
            print(f"Error deleting interface description: {e}")
```

### Challenge 4:

  * Delete the IP address you configured on `Ethernet2` on Day 3 using `pygnmi`'s `set` with a `delete` operation.
  * Verify the deletion by attempting to retrieve the IP address configuration. The result should indicate that the configuration is no longer present.
