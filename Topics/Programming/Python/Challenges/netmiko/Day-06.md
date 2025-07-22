# Day 6: Configuring from a File 📁

## **Goal:** Learn how to apply a larger, pre-written configuration from a local file using `send_config_from_file()`.

This method is perfect for standardizing configurations (like NTP, SNMP, or banners) across many devices.

## **1. Configuration File**

First, create a separate text file named `standard_config.txt` with the following content:

```
ntp server 1.2.3.4
snmp-server community MySecretRO
snmp-server community MySecretRW
```

## **2. Script to Push File**

Now, create a Python script `day6_config_from_file.py` to push this configuration to both routers.

```python
from netmiko import ConnectHandler
import os

os.system('clear')

all_devices = [
    {"device_type": "arista_eos", "host": "172.20.20.2", "username": "admin", "password": "admin"},
    {"device_type": "arista_eos", "host": "172.20.20.3", "username": "admin", "password": "admin"},
]

CONFIG_FILE = "standard_config.txt"

for device in all_devices:
    try:
        print(f"----- Connecting to {device['host']} -----")
        net_connect = ConnectHandler(**device)
        hostname = net_connect.find_prompt()

        print(f"Applying config from {CONFIG_FILE} to {hostname}")
        output = net_connect.send_config_from_file(CONFIG_FILE)
        print(output)

        print("\nVerifying NTP config:")
        verify_ntp = net_connect.send_command("show run | i ntp")
        print(verify_ntp)

        net_connect.disconnect()
        print("Connection closed.\n")

    except Exception as e:
        print(f"Failed to configure {device['host']}: {e}\n")
```

## **⭐ Day 6 Challenge**

Create a configuration file named `banner.txt` that sets a "Message of the Day" (MOTD) banner on the router. The command is `banner motd`. Remember that banner commands require a delimiting character to mark the beginning and end of the message.

Example `banner.txt`:

```
banner motd #
##############################################
#                                            #
#   This device is managed by Automation.    #
#   Unauthorized access is prohibited!       #
#                                            #
##############################################
#
```

Write a Netmiko script to apply this banner to both routers in the lab.

