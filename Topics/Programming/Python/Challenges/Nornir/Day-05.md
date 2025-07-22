# **Day 5: Leveraging Jinja2 for Dynamic Configurations**

## **Objective:** 
Use Jinja2 templates with Nornir to create dynamic configurations based on host data.

## **Concepts:**
  * `nornir_jinja2.tasks.template_file`
  * Passing host variables to templates.
  * Generating device-specific configurations.

## **Challenge:** 
Create an interface configuration using a Jinja2 template and deploy it to your cEOS devices, including a unique description for each.

## **Code Examples:**

1.  **`templates/interface.j2`:**

```jinja2
interface {{ interface_name }}
    description {{ interface_description }}
    ip address {{ ip_address }} {{ subnet_mask }}
    no shutdown
```

2.  **Update `inventory/hosts.yaml` (add interface data):**

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
```

3.  **`day5_jinja_config.py`:**

```python
from nornir import InitNornir
from nornir_scrapli.tasks import send_configs
from nornir_jinja2.tasks import template_file
from nornir.core.filter import F

def deploy_interface_config(task):
    # Render the template
    r = task.run(
        task=template_file,
        path="templates/",
        template="interface.j2",
        # Pass data from host.data.interfaces to the template
        interface_name=task.host["data"]["interfaces"][0]["name"],
        interface_description=task.host["data"]["interfaces"][0]["description"],
        ip_address=task.host["data"]["interfaces"][0]["ip"],
        subnet_mask=task.host["data"]["interfaces"][0]["mask"],
    )
    # Store the rendered configuration in host data
    task.host["config_to_deploy"] = r.result

    print(f"\n--- Generated config for {task.host.name} ---")
    print(task.host["config_to_deploy"])

    # Send the rendered configuration to the device
    task.run(task=send_configs, configs=task.host["config_to_deploy"].splitlines())
    print(f"Configuration deployed to {task.host.name}")

    # Verify configuration
    verify_result = task.run(task=send_command, command=f"show ip interface brief {task.host['data']['interfaces'][0]['name']}")
    print(f"\n--- {task.host.name} Interface Status ---")
    print(verify_result.result)

def main():
    nr = InitNornir(config_file="nornir_config.yaml")
    arista_nr = nr.filter(F(groups__contains="arista_devices"))
    arista_nr.run(task=deploy_interface_config)

if __name__ == "__main__":
    main()
```

Run: `python day5_jinja_config.py`
*Remember to create the `templates` directory and `interface.j2` file.*

