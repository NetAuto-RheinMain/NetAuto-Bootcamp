# Day 7: Final Project - Network Audit and Remediation 🏆

## **Goal:** Combine everything you've learned to build a useful script that audits the network for compliance and fixes it if necessary.

## **1. Project Goal**

Write a script that performs the following actions on all devices in the lab:

1.  Checks if **VLAN 99** exists.
2.  If the VLAN does not exist, the script creates it and names it `MANAGEMENT`.
3.  If the VLAN already exists, the script does nothing but reports its presence.
4.  The script prints a final summary of actions taken on each device.

## **2. Final Script (`day7_audit.py`)**

This script uses functions for better organization and performs conditional logic based on the device's state.

```python
from netmiko import ConnectHandler
import os

os.system('clear')

all_devices = [
    {"device_type": "arista_eos", "host": "172.20.20.2", "username": "admin", "password": "admin"},
    {"device_type": "arista_eos", "host": "172.20.20.3", "username": "admin", "password": "admin"},
]

def check_and_create_vlan(net_connect, vlan_id, vlan_name):
    """Checks for a VLAN and creates it if it's missing."""
    vlan_config = []
    
    # Check if the VLAN exists using a TextFSM-compatible command
    vlans = net_connect.send_command(f"show vlan id {vlan_id}", use_textfsm=True)

    # The 'vlans' list will be empty if the VLAN doesn't exist
    if not vlans:
        print(f"VLAN {vlan_id} not found. Creating it...")
        config_commands = [
            f"vlan {vlan_id}",
            f"name {vlan_name}"
        ]
        # Apply the configuration
        result = net_connect.send_config_set(config_commands)
        vlan_config.append(result)
        # Save the new configuration
        net_connect.save_config() # 'write memory' or 'copy running-config startup-config'
        return f"VLAN {vlan_id} ({vlan_name}) created and saved."
    else:
        # If it exists, check if the name is correct
        if vlans[0]['name'] != vlan_name:
            print(f"VLAN {vlan_id} has wrong name. Correcting it...")
            config_commands = [f"vlan {vlan_id}", f"name {vlan_name}"]
            result = net_connect.send_config_set(config_commands)
            vlan_config.append(result)
            net_connect.save_config()
            return f"VLAN {vlan_id} name corrected to {vlan_name} and saved."
        else:
            return f"VLAN {vlan_id} ({vlan_name}) is already configured correctly."


# --- Main script execution ---
print("--- Starting Network VLAN Audit ---")
for device in all_devices:
    try:
        print(f"\n>>> Connecting to {device['host']}...")
        net_connect = ConnectHandler(**device)
        hostname = net_connect.find_prompt().replace("#", "")

        # Call the function to perform the audit and remediation
        action_summary = check_and_create_vlan(net_connect, vlan_id=99, vlan_name="MANAGEMENT")

        print(f"    - Device: {hostname}")
        print(f"    - Status: {action_summary}")

        net_connect.disconnect()

    except Exception as e:
        print(f"Failed to process device {device['host']}: {e}")

print("\n--- Audit Complete ---")

```

## **⭐ Day 7 Challenge**

Expand the final script. In addition to the VLAN check, add a new function that audits for a specific loopback interface (e.g., `Loopback99` with IP `99.99.99.99/32`).

  * If the loopback doesn't exist, create it.
  * If it exists but has the wrong IP, correct it.
  * If it is configured correctly, report that all is well.
  * Update the final summary to include the status of the loopback check.