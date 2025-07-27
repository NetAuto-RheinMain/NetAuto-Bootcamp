### **Day 10: Building a Complete Automation Workflow & Cleanup**

## **Objective:** 
Combine all learned concepts into a practical automation script and demonstrate proper lab cleanup.

## **Concepts:**

* Putting it all together: Inventory, Jinja2, Scrapli, error handling.
* Pre-checks and post-checks.
* Lab teardown best practices.

## **Challenge:**

1.  Deploy a 2-node cEOS lab with Containerlab.
2.  Use Nornir to:
      * Perform a pre-check (e.g., `show ip interface brief`).
      * Deploy a complete configuration (e.g., interfaces and BGP) using Jinja2 templates.
      * Perform a post-check to verify the configuration.
      * Save the running configuration to startup config.
3.  Destroy the Containerlab topology cleanly.

## **Code Examples:**

1.  **Re-use `clab_2_ceos_topology.yaml` from Day 2.**
2.  **Re-use `inventory/hosts.yaml`, `inventory/groups.yaml`, `inventory/defaults.yaml` from Day 6 (or integrate if using exported inventory).**
3.  **Re-use `templates/interface.j2` and `templates/bgp.j2` from Day 5/6.**
4.  **`day10_full_workflow.py`:**

```python
from nornir import InitNornir
from nornir_scrapli.tasks import send_command, send_configs
from nornir_jinja2.tasks import template_file
from nornir.core.filter import F
import subprocess
import os
import time

def run_command(command, check_success=True):
    """Helper to run shell commands."""
    try:
        result = subprocess.run(command, check=check_success, capture_output=True, text=True)
        if check_success:
            print(f"Command successful: {' '.join(command)}")
        return result.stdout
    except subprocess.CalledProcessError as e:
        print(f"Command failed: {' '.join(command)}")
        print(f"Error: {e.stderr}")
        if check_success:
            raise

def pre_check(task):
    print(f"\n--- Performing pre-check on {task.host.name} ---")
    result = task.run(task=send_command, command="show ip interface brief")
    print(result.result)
    task.host["pre_check_status"] = result.result

def deploy_full_config(task):
    print(f"\n--- Deploying configuration to {task.host.name} ---")
    # Render interface config
    interface_config_rendered = task.run(
        task=template_file,
        path="templates/",
        template="interface.j2",
        interface_name=task.host["data"]["interfaces"][0]["name"],
        interface_description=task.host["data"]["interfaces"][0]["description"],
        ip_address=task.host["data"]["interfaces"][0]["ip"],
        subnet_mask=task.host["data"]["interfaces"][0]["mask"],
    ).result

    # Render BGP config
    bgp_config_rendered = task.run(
        task=template_file,
        path="templates/",
        template="bgp.j2",
        bgp=task.host["data"]["bgp"]
    ).result

    full_config = interface_config_rendered + "\n" + bgp_config_rendered
    print(f"Generated Full Config for {task.host.name}:\n{full_config}")

    # Send configuration
    result = task.run(task=send_configs, configs=full_config.splitlines())
    if result.failed:
        print(f"Configuration failed on {task.host.name}: {result.result}")
        if result.exc:
            print(f"Exception: {result.exc}")
        raise Exception(f"Failed to deploy config on {task.host.name}")
    else:
        print(f"Configuration deployed successfully on {task.host.name}")

def post_check(task):
    print(f"\n--- Performing post-check on {task.host.name} ---")
    result_interface = task.run(task=send_command, command=f"show ip interface brief {task.host['data']['interfaces'][0]['name']}")
    result_bgp = task.run(task=send_command, command="show ip bgp summary")
    print("Interface Status:\n", result_interface.result)
    print("BGP Summary:\n", result_bgp.result)
    task.host["post_check_interface"] = result_interface.result
    task.host["post_check_bgp"] = result_bgp.result

def save_config(task):
    print(f"\n--- Saving configuration on {task.host.name} ---")
    result = task.run(task=send_command, command="write memory")
    if result.failed:
        print(f"Failed to save config on {task.host.name}: {result.result}")
    else:
        print(f"Configuration saved on {task.host.name}")


def main():
    topology_file = "clab_2_ceos_topology.yaml"
    nornir_config_file = "nornir_config.yaml" # Or nornir_config_clab.yaml

    print("--- Day 10: Complete Automation Workflow ---")

    # 1. Deploy Containerlab topology
    print("\nDeploying Containerlab lab...")
    run_command(["sudo", "containerlab", "deploy", "--topo", topology_file])
    print("Waiting for devices to boot up (approx. 60 seconds)...")
    time.sleep(60) # Give devices time to boot

    try:
        # Initialize Nornir
        nr = InitNornir(config_file=nornir_config_file)
        arista_nr = nr.filter(F(groups__contains="arista_devices"))

        # 2. Perform Pre-checks
        print("\nRunning pre-checks...")
        nr_result = arista_nr.run(task=pre_check)
        for host, result in nr_result.items():
            if result.failed:
                print(f"Pre-check failed for {host}: {result.exception}")

        # 3. Deploy full configuration
        print("\nDeploying full configurations...")
        nr_result = arista_nr.run(task=deploy_full_config)
        for host, result in nr_result.items():
            if result.failed:
                print(f"Configuration deployment failed for {host}: {result.exception}")
                # You might want to exit here or handle specific hosts
                # sys.exit(1)

        # 4. Perform Post-checks
        print("\nRunning post-checks...")
        nr_result = arista_nr.run(task=post_check)
        for host, result in nr_result.items():
            if result.failed:
                print(f"Post-check failed for {host}: {result.exception}")

        # 5. Save configuration
        print("\nSaving configurations...")
        nr_result = arista_nr.run(task=save_config)
        for host, result in nr_result.items():
            if result.failed:
                print(f"Save config failed for {host}: {result.exception}")

    except Exception as e:
        print(f"\nAn error occurred during Nornir execution: {e}")

    finally:
        # 6. Destroy Containerlab topology
        print("\nDestroying Containerlab lab...")
        run_command(["sudo", "containerlab", "destroy", "--topo", topology_file, "--cleanup"])
        print("Lab destroyed successfully.")

if __name__ == "__main__":
    main()
```
Run: `python day10_full_workflow.py`
