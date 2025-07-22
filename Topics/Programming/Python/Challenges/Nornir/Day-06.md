# **Day 6: Advanced Inventory & Data Structures**

## **Objective:** 
Explore more complex inventory structures and how to organize data within Nornir.

## **Concepts:**
* Nested data structures in `hosts.yaml` and `groups.yaml`.
* Accessing nested data in Nornir tasks.
* The benefit of separating data from logic.

## **Challenge:** 
Define BGP peerings between `ceos1` and `ceos2` in the inventory, then generate and deploy the BGP configuration using a Jinja2 template.

## **Code Examples:**

1.  **Update `inventory/hosts.yaml` (add BGP data):**

```yaml
ceos1:
    hostname: 172.20.20.2
    platform: arista_eos
    groups:
    - arista_devices
    data:
    interfaces:
        - name: Ethernet1
        description: "Link to ceos2"
        ip: 10.0.12.1
        mask: 255.255.255.0
    bgp:
        asn: 65001
        router_id: 10.0.0.1
        neighbors:
        - ip: 10.0.12.2
            remote_as: 65002
            update_source: Loopback0
ceos2:
    hostname: 172.20.20.3
    platform: arista_eos
    groups:
    - arista_devices
    data:
    interfaces:
        - name: Ethernet1
        description: "Link to ceos1"
        ip: 10.0.12.2
        mask: 255.255.255.0
    bgp:
        asn: 65002
        router_id: 10.0.0.2
        neighbors:
        - ip: 10.0.12.1
            remote_as: 65001
            update_source: Loopback0
```

2.  **`templates/bgp.j2`:**
```jinja2
router bgp {{ bgp.asn }}
    router-id {{ bgp.router_id }}
    {% for neighbor in bgp.neighbors %}
    neighbor {{ neighbor.ip }} remote-as {{ neighbor.remote_as }}
    {% if neighbor.update_source is defined %}
    neighbor {{ neighbor.ip }} update-source {{ neighbor.update_source }}
    {% endif %}
    {% endfor %}
```

3.  **`day6_bgp_config.py`:**

```python
from nornir import InitNornir
from nornir_scrapli.tasks import send_configs, send_command
from nornir_jinja2.tasks import template_file
from nornir.core.filter import F

def deploy_bgp_config(task):
    # Render the BGP template
    bgp_r = task.run(
        task=template_file,
        path="templates/",
        template="bgp.j2",
        bgp=task.host["data"]["bgp"]
    )
    task.host["bgp_config"] = bgp_r.result

    print(f"\n--- Generated BGP config for {task.host.name} ---")
    print(task.host["bgp_config"])

    # Send BGP configuration
    task.run(task=send_configs, configs=task.host["bgp_config"].splitlines())
    print(f"BGP configuration deployed to {task.host.name}")

    # Verify BGP neighbor
    verify_result = task.run(task=send_command, command="show ip bgp summary")
    print(f"\n--- {task.host.name} BGP Summary ---")
    print(verify_result.result)

def main():
    nr = InitNornir(config_file="nornir_config.yaml")
    arista_nr = nr.filter(F(groups__contains="arista_devices"))
    arista_nr.run(task=deploy_bgp_config)

if __name__ == "__main__":
    main()
```

Run: `python day6_bgp_config.py`
*Don't forget to run `day4_configure_loopback.py` again if you destroyed the lab, as BGP neighbors will try to source from Loopback0.*

