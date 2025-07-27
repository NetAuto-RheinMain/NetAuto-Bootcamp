# Day 5: Streaming Telemetry with gNMI Subscribe

### Concepts:

  * **Subscribe RPC**: Receiving continuous streams of data from the device.
  * **Subscription Modes**:
      * **STREAM**: Continuous stream of updates as they occur.
      * **ONCE**: A single snapshot of data, then terminates.
      * **POLL**: On-demand snapshots triggered by the client.
  * **QoS (Quality of Service)**: Setting DSCP values for telemetry traffic.

### Containerlab Setup (`day5_lab.yaml`):

```yaml
name: day5_gnmi_lab
topology:
  nodes:
    ceos1:
      kind: arista_ceos
      image: ceos:ceos:4.34.0F
      # No special configuration needed for subscribe, as gNMI is enabled by default.
      # We'll use the management interface (eth0) for gNMI.
```

### Code Examples:

**1. `day5_subscribe_interface_counters.py` (STREAM mode)**
This script subscribes to interface counter updates and prints them as they change.

```python
from pygnmi.client import gNMIclient
import json
import time

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
        print(f"Connecting to {CEOS_IP}:{GNMI_PORT} to subscribe to interface counters (STREAM)...")
        try:
            # OpenConfig path for all interface counters
            path = ["/interfaces/interface/state/counters"]

            # Subscribe in STREAM mode
            # Use the enum value for mode
            subscription_params = {
                "subscription": [
                    {
                        "path": path[0],
                        "mode": "sample", 
                        "sample_interval": 1000000000 # 1 second in nanoseconds
                    }
                ]
            }

            print("Subscribing to interface counters. Press Ctrl+C to stop.")
            for response in gc.subscribe2(subscribe=subscription_params):
                if 'update' in response:
                    print(f"\n--- Update received at {time.time()} ---")
                    # Process the update message
                    # The 'update' field in the response is a dict with 'update' and 'delete' keys
                    if 'update' in response['update']: # Check if there are actual updates
                        for update_item in response['update']['update']: # Iterate over the list of updates
                            # Reconstruct the path for display
                            path_elements = []
                            if 'elem' in update_item['path']:
                                for elem in update_item['path']['elem']:
                                    segment = elem.get('name', '')
                                    keys = elem.get('keys', {})
                                    if keys:
                                        key_str = ",".join(f"{k}={v}" for k, v in keys.items())
                                        segment += f"[{key_str}]"
                                    path_elements.append(segment)
                            path_str = "/" + "/".join(path_elements)

                            print(f"Path: {path_str}")
                            if 'val' in update_item:
                                # 'val' is already a Python object
                                print(f"Value: {json.dumps(update_item['val'], indent=2)}")
                            elif 'value' in update_item: # Fallback for 'value' if 'val' isn't present
                                # 'value' might need decoding if it's raw bytes or specific type
                                # For json_ietf, 'value' should typically be handled by 'val'
                                print(f"Value (raw): {update_item['value']}")
                            else:
                                print("No 'val' or 'value' found in update item.")
                elif 'sync_response' in response and response['sync_response']:
                    print("--- Initial synchronization complete ---")
                elif 'error' in response:
                    print(f"Error in subscription: {response['error']}")
                else:
                    print(f"Received unknown response type: {response}") # For debugging other response types

        except KeyboardInterrupt:
            print("\nSubscription stopped by user.")
        except Exception as e:
            print(f"Error during subscription: {e}")
```

**How to generate traffic for testing:**
After running the subscription script, you can generate traffic on `ceos1` by:

1.  Accessing the cEOS CLI: `docker exec -it day5_gnmi_lab-ceos1 Cli`
2.  Ping another interface (if connected to another node, or even ping an invalid IP to generate egress traffic).
      * You'd need another cEOS or a host connected to `Ethernet1` or `Ethernet2` to see meaningful traffic.
      * For a simple test, configure an IP on `Ethernet1` (e.g., `10.0.0.1/24`) and ping an IP on that subnet that doesn't exist (e.g., `ping 10.0.0.2`). This will generate outbound packets.

### Challenge 5:

  * Modify `day5_subscribe_interface_counters.py` to subscribe to the CPU utilization of `ceos1` using an appropriate OpenConfig path (e.g., `/system/cpu/state/utilization`).
  * Experiment with `ONCE` and `POLL` subscription modes. For `POLL`, implement a loop that sends poll requests every 5 seconds.
