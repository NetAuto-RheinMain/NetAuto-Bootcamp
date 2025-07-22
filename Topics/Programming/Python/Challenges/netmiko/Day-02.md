# Day 2: Sending Read-Only Commands 🔍

## **Goal:** 
Learn to execute `show` commands and retrieve their output using Netmiko's `send_command()` method.

The `send_command()` method sends a single command to the device and waits for the output, returning it as a single string.

## **1. Script for `show` commands**

Create a file named `day2_show_commands.py`. This script connects to the router and executes a few common commands.

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

try:
    net_connect = ConnectHandler(**arista_router)
    print(f"Connected to {net_connect.find_prompt()}")

    # --- Send commands and print output ---

    # 1. Get the IOS version
    print("\n----- Getting software version -----")
    output_version = net_connect.send_command("show version")
    print(output_version)

    # 2. Get the IP interface status
    print("\n----- Getting IP interfaces -----")
    output_interfaces = net_connect.send_command("show ip interface brief")
    print(output_interfaces)

    net_connect.disconnect()
    print("\nConnection closed.")

except Exception as e:
    print(f"An error occurred: {e}")
```

## **⭐ Day 2 Challenge**

Write a script that performs a simple backup. The script should:

1.  Connect to the `ceos1` router.
2.  Execute the `show running-config` command.
3.  Save the output to a local file named `ceos1_backup.cfg`.

