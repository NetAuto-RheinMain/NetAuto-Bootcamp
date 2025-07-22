# Day 5: Automating Multiple Devices 🌐

## **Goal:** Scale your scripts to work on multiple devices by using loops and a simple inventory.

## **1. Multi-Device Script**

We'll use the two-router lab from Day 4. The key is to define all your devices in a list and then loop through that list.

Create `day5_multi_device.py`:

```python
from netmiko import ConnectHandler
import os

os.system('clear')

# A simple inventory as a list of dictionaries
all_devices = [
    {
        "device_type": "arista_eos",
        "host": "172.20.20.2",
        "username": "admin",
        "password": "admin",
        "device_name": "ceos1",
    },
    {
        "device_type": "arista_eos",
        "host": "172.20.20.3",
        "username": "admin",
        "password": "admin",
        "device_name": "ceos2",
    },
]

# Loop through each device in the list
for device in all_devices:
    try:
        device_name = device.pop("device_name") # Remove custom key before connecting
        print(f"----- Connecting to {device_name} ({device['host']}) -----")
        net_connect = ConnectHandler(**device)

        # Get the hostname for verification
        hostname = net_connect.send_command("show hostname", use_textfsm=True)[0]['hostname']
        print(f"Successfully connected to {hostname}")

        net_connect.disconnect()
        print("Connection closed.\n")

    except Exception as e:
        print(f"Failed to connect to {device_name}: {e}\n")
```

## **⭐ Day 5 Challenge**

Create a script that connects to both routers in the lab. For each router, the script should retrieve the `show running-config` and save it to a file named after the router's hostname (e.g., `ceos1-running-config.txt` and `ceos2-running-config.txt`).
