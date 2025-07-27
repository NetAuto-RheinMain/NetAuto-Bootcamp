## Day 7: Comprehensive Automation Scenario and Cleanup (Nokia SR Linux)

### Concepts:

  * **End-to-End Automation**: Combining all learned `pygnmi` operations to achieve a specific network automation goal.
  * **Modular Code**: Structuring your Python scripts for reusability.
  * **Lab Teardown**: Properly cleaning up Containerlab resources.

### Containerlab Setup (`day7_srl_full_lab.yaml`):

```yaml
name: day7_srl_gnmi_full_lab
topology:
  nodes:
    srl1:
      kind: nokia_srlinux
      image: ghcr.io/nokia/srlinux:latest
    srl2:
      kind: nokia_srlinux
      image: ghcr.io/nokia/srlinux:latest
    srl3:
      kind: nokia_srlinux
      image: ghcr.io/nokia/srlinux:latest
  links:
    - endpoints: ["srl1:e1-1", "srl2:e1-1"]
    - endpoints: ["srl2:e1-2", "srl3:e1-1"]
    - endpoints: ["srl1:e1-2", "srl3:e1-2"] # Triangle topology
```

Deploy the lab:

```bash
sudo containerlab deploy --topo day7_srl_full_lab.yaml
```

Get IPs for `srl1`, `srl2`, `srl3` using `docker inspect` or `clab inspect`.

### Code Examples:

**1. `day7_srl_full_lab_automation.py`**
This script will:

1.  Configure interfaces on `srl1`, `srl2`, `srl3`.
2.  Set up basic OSPF routing (simplified).
3.  Verify OSPF neighbor states.
4.  Continuously stream interface operational status.

<!-- end list -->

```python
from pygnmi.client import gNMIclient
import json
import time
import threading

# --- IMPORTANT: UPDATE WITH YOUR SRL IPs ---
SRL1_IP = "172.20.0.2"
SRL2_IP = "172.20.0.3"
SRL3_IP = "172.20.0.4"
# ---

GNMI_PORT = 57400
USERNAME = "admin"
PASSWORD = "admin"

DEVICES = {
    "srl1": SRL1_IP,
    "srl2": SRL2_IP,
    "srl3": SRL3_IP
}

def connect_gnmi(ip, port, username, password, insecure=True):
    return gNMIclient(target=(ip, port), username=username, password=password, insecure=insecure)

def configure_interface(gc, device_name, interface_name, ip_address, prefix_length):
    print(f"Configuring {interface_name} on {device_name} with {ip_address}/{prefix_length}")
    updates = [
        {
            "path": f"/interface[name={interface_name}]/admin-state",
            "value": "enable"
        },
        {
            "path": f"/interface[name={interface_name}]/subinterface[index=0]/admin-state",
            "value": "enable"
        },
        {
            "path": f"/interface[name={interface_name}]/subinterface[index=0]/ipv4/address[ip-prefix={ip_address}/{prefix_length}]/ip-prefix",
            "value": f"{ip_address}/{prefix_length}"
        }
    ]
    # SR Linux configuration path needs 'network-instance' for interfaces to be in default VRF
    # For a full interface config, we often need to specify the network-instance
    # Simplified here assuming default.
    updates_with_ni = [
        {
            "path": f"/network-instance[name=default]/interface[name={interface_name}]/admin-state",
            "value": "enable"
        },
        {
            "path": f"/network-instance[name=default]/interface[name={interface_name}]/subinterface[index=0]/admin-state",
            "value": "enable"
        },
        {
            "path": f"/network-instance[name=default]/interface[name={interface_name}]/subinterface[index=0]/ipv4/address[ip-prefix={ip_address}/{prefix_length}]/ip-prefix",
            "value": f"{ip_address}/{prefix_length}"
        }
    ]
    # Use OpenConfig paths for SR Linux:
    updates_oc = [
        {
            "path": f"/interfaces/interface[name={interface_name}]/config/admin-state",
            "value": "true"
        },
        {
            "path": f"/interfaces/interface[name={interface_name}]/subinterfaces/subinterface[index=0]/config/admin-state",
            "value": "true"
        },
        {
            "path": f"/interfaces/interface[name={interface_name}]/subinterfaces/subinterface[index=0]/ipv4/addresses/address[ip={ip_address}]/config/ip",
            "value": ip_address
        },
        {
            "path": f"/interfaces/interface[name={interface_name}]/subinterfaces/subinterface[index=0]/ipv4/addresses/address[ip={ip_address}]/config/prefix-length",
            "value": prefix_length
        }
    ]

    try:
        response = gc.set(update=updates_oc, encoding="json_ietf")
        print(f"  {device_name} {interface_name} config response: {json.dumps(response, indent=2)}")
        return True
    except Exception as e:
        print(f"  Failed to configure {interface_name} on {device_name}: {e}")
        return False

def configure_ospf_interface(gc, device_name, interface_name, area_id):
    print(f"Configuring OSPF on {interface_name} on {device_name} in area {area_id}")
    # Using SR Linux native YANG for OSPF configuration
    # This is a simplified OSPF config, you would typically need more for a full setup.
    # The 'global' node below is for router-id.
    updates = [
        {
            "path": "/network-instance[name=default]/protocols/ospf/router-id",
            "value": f"{'1.1.1.1' if device_name == 'srl1' else ('2.2.2.2' if device_name == 'srl2' else '3.3.3.3')}"
        },
        {
            "path": f"/network-instance[name=default]/protocols/ospf/area[area-id={area_id}]/interface[interface-name={interface_name}]/interface-type",
            "value": "POINT_TO_POINT" # Example interface type
        },
        {
            "path": f"/network-instance[name=default]/protocols/ospf/area[area-id={area_id}]/interface[interface-name={interface_name}]/admin-state",
            "value": "enable"
        }
    ]
    try:
        response = gc.set(update=updates, encoding="json_ietf")
        print(f"  {device_name} OSPF config response: {json.dumps(response, indent=2)}")
        return True
    except Exception as e:
        print(f"  Failed to configure OSPF on {device_name}: {e}")
        return False

def get_ospf_neighbors(gc, device_name):
    print(f"Checking OSPF neighbors on {device_name}...")
    # SR Linux native state path for OSPF neighbors
    path = ["/network-instance[name=default]/protocols/ospf/area/interface/neighbor"]
    try:
        result = gc.get(path=path, encoding="json_ietf", datatype="state")
        if result and 'notification' in result and result['notification']:
            for notification in result['notification']:
                if 'update' in notification:
                    for update in notification['update']:
                        if 'path' in update and 'val' in update:
                            print(f"  {device_name} OSPF Neighbor: {json.dumps(update['val'], indent=2)}")
        else:
            print(f"  No OSPF neighbor data found on {device_name}.")
        return True
    except Exception as e:
        print(f"  Error getting OSPF neighbors on {device_name}: {e}")
        return False

def subscribe_interface_oper_status(gc, device_name, interface_name):
    print(f"Subscribing to {interface_name} operational status on {device_name}...")
    # OpenConfig path for operational state
    path = [f"/interfaces/interface[name={interface_name}]/state/oper-status"]
    subscription_params = {
        "subscription": [
            {
                "path": path[0],
                "mode": "STREAM",
                "sample_interval": 5000000000 # 5 seconds
            }
        ]
    }
    try:
        for response in gc.subscribe2(subscribe=subscription_params):
            if 'update' in response:
                update = response['update']['update'][0]
                status = update['val'] if 'val' in update else update['value']
                print(f"  [{device_name} - {interface_name}] OPER STATUS: {status} at {time.strftime('%H:%M:%S')}")
            elif 'sync_response' in response and response['sync_response']:
                print(f"  {device_name} - {interface_name} subscription initial sync complete.")
            elif 'error' in response:
                print(f"  {device_name} - {interface_name} subscription error: {response['error']}")
    except Exception as e:
        print(f"  Error in {device_name} - {interface_name} subscription thread: {e}")

if __name__ == "__main__":
    # Define IP addresses for the links
    # srl1-e1-1 (10.0.0.1/30) - srl2-e1-1 (10.0.0.2/30)
    # srl2-e1-2 (10.0.0.5/30) - srl3-e1-1 (10.0.0.6/30)
    # srl1-e1-2 (10.0.0.9/30) - srl3-e1-2 (10.0.0.10/30)

    # Give SR Linux nodes time to boot up
    print("Waiting for SR Linux nodes to initialize...")
    time.sleep(20)

    # Step 1: Configure Interfaces
    print("--- Day 7: Configuring Interfaces ---")
    with connect_gnmi(DEVICES["srl1"], GNMI_PORT, USERNAME, PASSWORD) as gc1:
        configure_interface(gc1, "srl1", "ethernet-1/1", "10.0.0.1", 30)
        configure_interface(gc1, "srl1", "ethernet-1/2", "10.0.0.9", 30)

    with connect_gnmi(DEVICES["srl2"], GNMI_PORT, USERNAME, PASSWORD) as gc2:
        configure_interface(gc2, "srl2", "ethernet-1/1", "10.0.0.2", 30)
        configure_interface(gc2, "srl2", "ethernet-1/2", "10.0.0.5", 30)

    with connect_gnmi(DEVICES["srl3"], GNMI_PORT, USERNAME, PASSWORD) as gc3:
        configure_interface(gc3, "srl3", "ethernet-1/1", "10.0.0.6", 30)
        configure_interface(gc3, "srl3", "ethernet-1/2", "10.0.0.10", 30)

    time.sleep(10) # Give devices time to process config and bring up links

    # Step 2: Configure OSPF (simplified for demonstration)
    print("\n--- Day 7: Configuring OSPF (Simplified) ---")
    with connect_gnmi(DEVICES["srl1"], GNMI_PORT, USERNAME, PASSWORD) as gc1:
        configure_ospf_interface(gc1, "srl1", "ethernet-1/1", 0) # Area 0
        configure_ospf_interface(gc1, "srl1", "ethernet-1/2", 0)
    with connect_gnmi(DEVICES["srl2"], GNMI_PORT, USERNAME, PASSWORD) as gc2:
        configure_ospf_interface(gc2, "srl2", "ethernet-1/1", 0)
        configure_ospf_interface(gc2, "srl2", "ethernet-1/2", 0)
    with connect_gnmi(DEVICES["srl3"], GNMI_PORT, USERNAME, PASSWORD) as gc3:
        configure_ospf_interface(gc3, "srl3", "ethernet-1/1", 0)
        configure_ospf_interface(gc3, "srl3", "ethernet-1/2", 0)

    time.sleep(20) # Give OSPF time to converge

    # Step 3: Verify OSPF Neighbors
    print("\n--- Day 7: Verifying OSPF Neighbors ---")
    for device_name, ip_address in DEVICES.items():
        with connect_gnmi(ip_address, GNMI_PORT, USERNAME, PASSWORD) as gc:
            get_ospf_neighbors(gc, device_name)

    # Step 4: Stream Interface Operational Status in parallel threads
    print("\n--- Day 7: Streaming Interface Operational Status ---")
    subscription_threads = []
    for device_name, ip_address in DEVICES.items():
        # Subscribe to ethernet-1/1 status on all devices for cross-link visibility
        thread = threading.Thread(target=lambda: subscribe_interface_oper_status(
            connect_gnmi(ip_address, GNMI_PORT, USERNAME, PASSWORD), device_name, "ethernet-1/1"
        ))
        thread.daemon = True # Allow main program to exit even if threads are running
        subscription_threads.append(thread)
        thread.start()

    try:
        print("\nStreaming interface status for 60 seconds. Press Ctrl+C to exit early.")
        time.sleep(60) # Stream for 60 seconds
    except KeyboardInterrupt:
        print("\nStopping streaming and exiting.")
    finally:
        print("Automation complete. Cleaning up lab...")
        # Containerlab cleanup (manual step for the user)
        # sudo containerlab destroy --topo day7_srl_full_lab.yaml

```

### Challenge 7:

  * Run the `day7_srl_full_lab_automation.py` script. Observe the configuration, OSPF neighbor output, and streaming telemetry.
  * While the script is running, manually shut down `ethernet-1/1` on `srl1` via its CLI (`docker exec -it day7_srl_gnmi_full_lab-srl1 /usr/bin/sr_cli` then `enter candidate`, `set /interface ethernet-1/1 admin-state disable`, `commit and quit`). Observe how the `pygnmi` script's streaming output reacts. Then bring it back up (`set /interface ethernet-1/1 admin-state enable`, `commit and quit`).
  * **Bonus**: Extend the `day7_srl_full_lab_automation.py` script to include a function that retrieves and prints the system uptime for each SR Linux device using a *native SR Linux gNMI path* (e.g., `srl_nokia-state:/system/state/boot-time`).

### Lab Teardown:

After completing the tutorial, destroy your Containerlab environment:

```bash
sudo containerlab destroy --topo day7_srl_full_lab.yaml
```

If you created other labs (Day 1-6), remember to destroy them as well using their respective YAML files.



