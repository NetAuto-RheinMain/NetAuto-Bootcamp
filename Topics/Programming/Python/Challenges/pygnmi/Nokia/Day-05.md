## Day 5: Streaming Telemetry with gNMI Subscribe (Nokia SR Linux)

### Concepts:

  * **Subscribe RPC**: Receiving continuous streams of data from the device.
  * **Subscription Modes**:
      * **STREAM**: Continuous stream of updates as they occur.
      * **ONCE**: A single snapshot of data, then terminates.
      * **POLL**: On-demand snapshots triggered by the client.
  * **QoS (Quality of Service)**: Setting DSCP values for telemetry traffic.

### Containerlab Setup (`day5_srl_lab.yaml`):

```yaml
name: day5_srl_gnmi_lab
topology:
  nodes:
    srl1:
      kind: nokia_srlinux
      image: ghcr.io/nokia/srlinux:latest
      # No special configuration needed for subscribe, as gNMI is enabled by default.
```

### Code Examples:

**1. `day5_srl_subscribe_interface_counters.py` (STREAM mode)**
This script subscribes to interface counter updates and prints them as they change.

```python
from pygnmi.client import gNMIclient
import json
import time

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
        print(f"Connecting to {SRL_IP}:{GNMI_PORT} to subscribe to interface counters (STREAM)...")
        try:
            # Using OpenConfig path for all interface statistics
            # SR Linux usually provides counters under /interface/state/statistics or directly /interface/statistics
            # Let's try /interface/statistics first, expecting it might return aggregated data in 'val'
            path = ["/interface[name=ethernet-1/1]]/statistics"] # OpenConfig path

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
                # print(f"Raw subscribe response: {json.dumps(response, indent=2)}") # Uncomment for detailed debugging

                if 'update' in response and isinstance(response['update'], list): # Ensure 'update' is a list
                    print(f"\n--- Update received at {time.time()} ---")
                    for update_data in response['update']: # Corrected: direct iteration over response['update']
                        if 'path' in update_data and update_data['path'] is not None and 'elem' in update_data['path']:
                            # Case 1: Interface name is in the path structure
                            interface_name = None
                            for elem in update_data['path']['elem']:
                                if 'key' in elem and 'name' in elem['key']:
                                    interface_name = elem['key']['name']
                                    break # Found the name, exit inner loop
                            if interface_name:
                                print(f"Interface: {interface_name} Counters:")
                                print(json.dumps(update_data['val'], indent=2))
                            else:
                                print(f"Path with no specific interface name key: {update_data['path']['elem']}")
                                print(json.dumps(update_data['val'], indent=2))
                        elif 'val' in update_data and isinstance(update_data['val'], dict):
                            # Case 2: Path is null, interface data is aggregated in 'val'
                            # This is the likely scenario for SR Linux with /interface/statistics
                            if 'srl_nokia-interfaces:interface' in update_data['val']:
                                interfaces_data = update_data['val']['srl_nokia-interfaces:interface']
                                for interface in interfaces_data:
                                    interface_name = interface.get('name')
                                    # The 'statistics' might be nested further within the interface dictionary
                                    statistics = interface.get('statistics')
                                    if interface_name and statistics:
                                        print(f"Interface: {interface_name} Counters:")
                                        print(json.dumps(statistics, indent=2))
                                    elif interface_name:
                                        # If 'statistics' key is missing but name is present
                                        print(f"Interface: {interface_name} (no statistics data found in val)")
                                        print(json.dumps(interface, indent=2)) # Print whole interface dict
                                    else:
                                        print(f"Warning: Interface data in 'val' without 'name' key: {json.dumps(interface, indent=2)}")
                            else:
                                print(f"Warning: 'val' does not contain 'srl_nokia-interfaces:interface' key: {json.dumps(update_data['val'], indent=2)}")
                        else:
                            print(f"Warning: Neither path nor aggregated 'val' found in update_data: {update_data}")
                elif 'sync_response' in response and response['sync_response']:
                    print("--- Initial synchronization complete ---")
                elif 'error' in response:
                    print(f"Error in subscription response: {response['error']}")
                else:
                    print(f"Unknown response type: {json.dumps(response, indent=2)}")

        except KeyboardInterrupt:
            print("\nSubscription stopped by user.")
        except Exception as e:
            print(f"Error during subscription: {e}")
```

**How to generate traffic for testing:**
After running the subscription script, you can generate traffic on `srl1` by:

1.  Accessing the SR Linux CLI: `docker exec -it day5_srl_gnmi_lab-srl1 /usr/bin/sr_cli`
2.  Configure an IP on `ethernet-1/1` (e.g., `10.0.0.1/24`) if you haven't.
3.  Ping an IP on that subnet that doesn't exist (e.g., `ping 10.0.0.2`). This will generate outbound packets and should trigger counter updates.

### Challenge 5:

  * Modify `day5_srl_subscribe_interface_counters.py` to subscribe to the CPU utilization of `srl1` using an appropriate OpenConfig path (e.g., `/system/cpu/state/utilization`).
  * Experiment with `ONCE` and `POLL` subscription modes. For `POLL`, implement a loop that sends poll requests every 5 seconds.

