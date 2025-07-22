# **Day 2: Nornir Fundamentals - Inventory**

## **Objective:** 
Understand Nornir's inventory system and how to represent your network devices.

## **Concepts:**

* Nornir's `SimpleInventory` plugin.
* `hosts.yaml`, `groups.yaml`, and `defaults.yaml` files.
* Defining connection options (e.g., SSH credentials).

## **Challenge:** Create a Nornir inventory for two cEOS routers.

## **Code Examples:**

1.  **`clab_2_ceos_topology.yaml`:**

```yaml
name: two-ceos-lab
topology:
    nodes:
    ceos1:
        kind: arista_ceos
        image: ceos:4.28.0F
    ceos2:
        kind: arista_ceos
        image: ceos:4.28.0F
```

Deploy this lab: `sudo containerlab deploy --topo clab_2_ceos_topology.yaml`

2.  **`inventory/hosts.yaml`:**

```yaml
ceos1:
    hostname: 172.20.20.2 # Containerlab assigns IPs in the management network
    platform: arista_eos
    groups:
    - arista_devices
ceos2:
    hostname: 172.20.20.3
    platform: arista_eos
    groups:
    - arista_devices
```

*Note:* Containerlab automatically generates a `containerlab.clab.yml` (or similar) file with the assigned management IPs. You can find these IPs by running `sudo containerlab inspect --topo clab_2_ceos_topology.yaml`. The `172.20.20.x` range is a common default for Containerlab's management bridge. Adjust if yours is different.

3.  **`inventory/groups.yaml`:**

```yaml
arista_devices:
    connection_options:
    scrapli:
        platform: arista_eos
        extras:
        auth_strict_key: false # Important for lab environments
```

4.  **`inventory/defaults.yaml`:**

```yaml
username: admin
password: admin
```

*(Default cEOS credentials)*

5.  **`nornir_config.yaml`:**

```yaml
---
inventory:
    plugin: SimpleInventory
    options:
    host_file: "inventory/hosts.yaml"
    group_file: "inventory/groups.yaml"
    defaults_file: "inventory/defaults.yaml"
runner:
    plugin: threaded
    options:
    num_workers: 2
```

6.  **`day2_inventory_test.py`:**

```python
from nornir import InitNornir
from nornir.core.filter import F

def main():
    nr = InitNornir(config_file="nornir_config.yaml")
    print("Initialized Nornir with inventory:")
    for host in nr.inventory.hosts.values():
        print(f"  Host: {host.name}, Platform: {host.platform}, Hostname: {host.hostname}")

    # Example: Filter hosts by group
    arista_hosts = nr.filter(F(groups__contains="arista_devices"))
    print("\nArista Devices:")
    for host in arista_hosts.inventory.hosts.values():
        print(f"  - {host.name}")

if __name__ == "__main__":
    main()
```

Run: `python day2_inventory_test.py`

