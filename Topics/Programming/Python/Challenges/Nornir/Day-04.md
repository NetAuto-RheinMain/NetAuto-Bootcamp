# **Day 4: Configuration Management - Sending Commands**

## **Objective:** 
Learn to push configuration commands to cEOS devices.

## **Concepts:**

* `nornir_scrapli.tasks.send_configs`
* Atomic configuration changes.
* Idempotency (brief introduction).

## **Challenge:** Configure a loopback interface on both cEOS routers.

## **Code Example:**

1.  **`day4_configure_loopback.py`:**
```python
from nornir import InitNornir
from nornir_scrapli.tasks import send_configs
from nornir.core.filter import F

def configure_loopback(task):
    commands = [
        f"interface Loopback0",
        f"description Configured by Nornir",
        f"ip address 10.0.0.{task.host.name[-1]}/32" # Dynamic IP based on host name
    ]
    result = task.run(task=send_configs, configs=commands)
    if result.failed:
        print(f"Failed to configure {task.host.name}: {result.result}")
    else:
        print(f"Successfully configured Loopback0 on {task.host.name}")
    # Verify configuration
    verify_result = task.run(task=send_command, command="show ip interface brief Loopback0")
    print(f"\n--- {task.host.name} Loopback0 Status ---")
    print(verify_result.result)


def main():
    nr = InitNornir(config_file="nornir_config.yaml")
    arista_nr = nr.filter(F(groups__contains="arista_devices"))
    arista_nr.run(task=configure_loopback)

if __name__ == "__main__":
    main()
```
Run: `python day4_configure_loopback.py`

