## Day 4: Deleting Configuration with gNMI Set (Delete) (Nokia SR Linux)

### Concepts:

  * **Set RPC with Delete Operation**: Removing existing configuration from the device.

### Containerlab Setup (`day4_srl_lab.yaml`):

Same as previous days. Ensure you have the configuration from Day 3 (e.g., IP address on `ethernet-1/2`) in place before starting this day's challenges.

### Code Examples:

**1. `day4_srl_delete_interface_description.py`**
This script deletes the description from `ethernet-1/1`.

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
        print(f"Connecting to {SRL_IP}:{GNMI_PORT} to delete interface description...")
        try:
            # Ensure a description exists first (optional, for testing flow)
            # You might want to run day3_srl_set_interface_description.py beforehand

            # Define the delete operation
            delete_path = ["/interface[name=ethernet-1/1]/description"]

            response = gc.set(delete=delete_path, encoding="json_ietf")
            print("\n--- Delete Operation Response ---")
            print(json.dumps(response, indent=2))

            # Verify the deletion
            path_verify = ["/interface[name=ethernet-1/1]/description"]
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

  * Delete the IP address you configured on `ethernet-1/2` on Day 3 using `pygnmi`'s `set` with a `delete` operation. Remember that deleting a keyed list entry (like an IP address) typically involves deleting the specific key.
      * **Hint**: The path for deleting the IP address will be `/interfaces/interface[name=ethernet-1/2]/subinterfaces/subinterface[index=0]/ipv4/addresses/address[ip=192.168.1.1]`.
  * Verify the deletion by attempting to retrieve the IP address configuration. The result should indicate that the configuration is no longer present.


