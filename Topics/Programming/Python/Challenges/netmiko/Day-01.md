# Day 1: Setup and First Connection 🚀

## **Goal:** 
Install the necessary tools, launch a lab environment with a single Arista router, and write your first Netmiko script to connect to it.

## **1. Lab Setup**

First, you need Docker and Containerlab installed. Then, create your lab topology.

1.  **Create a project directory:**

```bash
mkdir netmiko-lab
cd netmiko-lab
```

2.  **Create a topology file:** Create a file named `topology.yml` with the following content. This defines one Arista cEOS router.

```yaml
name: netmiko_lab_day1

topology:
    nodes:
    - name: ceos1
        kind: ceos
        image: ceosimage:4.28.1F
```

3.  **Deploy the Lab:** Run the following command from your terminal.

```bash
sudo containerlab deploy -t topology.yml
```

Containerlab will pull the cEOS image and start your router container. The default credentials are `admin` / `admin`.

## **2. Python Environment**

1.  **Install Netmiko:**

```bash
pip install netmiko
```

2.  **Create your first script:** Create a file named `day1_connect.py`.

```python
from netmiko import ConnectHandler
import os

# Clear the screen for a cleaner output
os.system('clear')

# Define the device details for the cEOS router
# Default credentials for cEOS in Containerlab are admin/admin
arista_router = {
    "device_type": "arista_eos",
    "host": "172.20.20.2", # This is the default IP assigned by containerlab
    "username": "admin",
    "password": "admin",
}

try:
    # Establish an SSH connection to the device
    print("Connecting to device...")
    net_connect = ConnectHandler(**arista_router)

    # If successful, Netmiko returns a connection object
    # and you will see the device prompt
    prompt = net_connect.find_prompt()
    print(f"Successfully connected! Device prompt is: {prompt}")

    # Disconnect from the device
    net_connect.disconnect()
    print("Connection closed.")

except Exception as e:
    print(f"Failed to connect: {e}")

```

## **⭐ Day 1 Challenge**

Modify the `day1_connect.py` script. After connecting, find the device's hostname by running the command `show hostname` and print it to the console.

**Hint:** You'll need a method to send commands, which we'll cover tomorrow. A good starting point is to look for a `send_command` method in Netmiko's documentation.

