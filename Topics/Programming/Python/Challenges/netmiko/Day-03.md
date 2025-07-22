#  Day 3: Sending Configuration Commands ⚙️

## **Goal:** 
Learn to change the device's configuration using Netmiko's `send_config_set()` method.

The `send_config_set()` method is ideal for making changes. It automatically enters and exits configuration mode (`configure terminal`) for you. You can pass it a single command as a string or multiple commands as a list of strings.

## **1. Script for Configuration**

Create a file named `day3_configure.py`. This script adds a new loopback interface.

```python
from netmiko import ConnectHandler
import os

os.system('clear')

arista_router = {
    "device_type": "arista_eos",
    "host": "172.20.20.2",
    "username": "admin",
    "password": "admin",
}

# List of configuration commands to send
config_commands = [
    "interface loopback100",
    "description Configured by Netmiko",
    "ip address 100.100.100.100/32"
]

try:
    net_connect = ConnectHandler(**arista_router)
    print(f"Connected to {net_connect.find_prompt()}")

    # --- Send configuration commands ---
    print("\n----- Sending configuration -----")
    output_config = net_connect.send_config_set(config_commands)
    print(output_config)

    # --- Verify the configuration ---
    print("\n----- Verifying configuration -----")
    output_verify = net_connect.send_command("show run interface loopback100")
    print(output_verify)

    net_connect.disconnect()
    print("\nConnection closed.")

except Exception as e:
    print(f"An error occurred: {e}")
```

## **⭐ Day 3 Challenge**

Write a script to create two new VLANs:

1.  **VLAN 20** with the name `SALES`.
2.  **VLAN 30** with the name `MARKETING`.

After applying the configuration, verify your changes by running `show vlan` and printing the output.

