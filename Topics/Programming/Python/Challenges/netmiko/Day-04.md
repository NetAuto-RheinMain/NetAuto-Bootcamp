# Day 4: Parsing Data with TextFSM 📊

## **Goal:** Stop treating command output as a block of text and start using it as structured data (lists and dictionaries). Netmiko has built-in support for this using TextFSM.

## **1. Lab Update**

For this lesson, we need two routers to see neighbor information.

1.  **Destroy the old lab:** `sudo containerlab destroy -t topology.yml --cleanup`
2.  **Update `topology.yml`:**
```yaml
name: netmiko_lab_day4

topology:
    nodes:
    - name: ceos1
        kind: ceos
        image: ceosimage:4.28.1F
    - name: ceos2
        kind: ceos
        image: ceosimage:4.28.1F

    links:
    - endpoints: ["ceos1:eth1", "ceos2:eth1"]
```
3.  **Deploy the new lab:** `sudo containerlab deploy -t topology.yml`. You now have two routers, `ceos1` (172.20.20.2) and `ceos2` (172.20.20.3).

## **2. Structured Data Script**

By adding the argument `use_textfsm=True` to the `send_command()` method, Netmiko will parse the output if it has a corresponding TextFSM template. The result is a list of dictionaries.

Create `day4_structured_data.py`:

```python
from netmiko import ConnectHandler
import os
from pprint import pprint

os.system('clear')

arista_router = {
    "device_type": "arista_eos",
    "host": "172.20.20.2", # ceos1
    "username": "admin",
    "password": "admin",
}

try:
    net_connect = ConnectHandler(**arista_router)
    print(f"Connected to {net_connect.find_prompt()}\n")

    # Get structured data for interfaces
    interfaces = net_connect.send_command("show ip interface brief", use_textfsm=True)

    print("----- Structured Interface Data -----")
    pprint(interfaces) # pprint makes it easier to read

    print("\n----- Parsed Interface Info -----")
    for interface in interfaces:
        print(f"Interface: {interface['interface']}, IP Address: {interface['ipaddr']}")

    net_connect.disconnect()

except Exception as e:
    print(f"An error occurred: {e}")
```

## **⭐ Day 4 Challenge**

Write a script that connects to `ceos1` and uses TextFSM to parse the output of `show lldp neighbors`. The script should then print a friendly summary for each neighbor found, like:
`Neighbor ceos2 is connected on local port Ethernet1 to remote port Ethernet1.`

