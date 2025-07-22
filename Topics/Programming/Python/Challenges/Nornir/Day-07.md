# **Day 7: Data Validation and Error Handling**

## **Objective:** 
Implement basic error handling and data validation within Nornir tasks.

## **Concepts:**
* Checking `result.failed` and `result.exc`.
* Using `try-except` blocks.
* Nornir's `on_failed` and `on_good` callbacks (for later).

## **Challenge:** 
Introduce an intentional error (e.g., a syntax error in a command) and demonstrate how Nornir handles it, then implement a `try-except` to catch and report it gracefully.

## **Code Examples:**
1.  **`day7_error_handling.py`:**
```python
from nornir import InitNornir
from nornir_scrapli.tasks import send_command, send_configs
from nornir.core.filter import F

def check_interfaces(task):
    try:
        result = task.run(task=send_command, command="show interfaces status")
        task.host["interface_status"] = result.result
        print(f"\n--- {task.host.name} Interface Status ---")
        print(result.result)
    except Exception as e:
        print(f"Error retrieving interface status from {task.host.name}: {e}")
        task.host["error"] = str(e) # Store error in host data for later analysis

def introduce_error_and_handle(task):
    # Intentional syntax error
    bad_command = ["interface Ethernet3", "ip address 192.168.1.1 255.255.255.0 this_is_bad"]
    try:
        result = task.run(task=send_configs, configs=bad_command)
        if result.failed:
            print(f"Configuration failed on {task.host.name}: {result.result}")
            # Accessing the underlying exception if available
            if result.exc:
                print(f"Exception details: {result.exc}")
        else:
            print(f"Successfully applied (bad) configuration on {task.host.name}")
    except Exception as e:
        print(f"An unexpected error occurred during configuration on {task.host.name}: {e}")


def main():
    nr = InitNornir(config_file="nornir_config.yaml")
    arista_nr = nr.filter(F(groups__contains="arista_devices"))

    print("\n--- Running initial check ---")
    arista_nr.run(task=check_interfaces)

    print("\n--- Introducing an error ---")
    arista_nr.run(task=introduce_error_and_handle)

    print("\n--- Checking for errors in results ---")
    for host in arista_nr.inventory.hosts.values():
        if "error" in host:
            print(f"Host {host.name} had an error: {host['error']}")

if __name__ == "__main__":
    main()
```
Run: `python day7_error_handling.py`

