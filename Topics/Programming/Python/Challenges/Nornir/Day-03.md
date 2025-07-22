# **Day 3: Basic Device Interaction with Scrapli**

## **Objective:** 
Use Nornir with the Scrapli plugin to send commands and retrieve information from cEOS devices.

## **Concepts:**

* Nornir tasks.
* `nornir_scrapli.tasks.send_command`
* Processing `Result` objects.

## **Challenge:** 
Get the `show version` output from both cEOS routers.

## **Code Example:**

1.  **`day3_show_version.py`:**
```python
from nornir import InitNornir
from nornir_scrapli.tasks import send_command
from nornir.core.filter import F

def get_version(task):
    result = task.run(task=send_command, command="show version")
    task.host["facts"] = result.result # Store output in host data
    print(f"\n--- {task.host.name} show version ---")
    print(result.result)

def main():
    nr = InitNornir(config_file="nornir_config.yaml")
    arista_nr = nr.filter(F(groups__contains="arista_devices"))
    arista_nr.run(task=get_version)

if __name__ == "__main__":
    main()
```
Run: `python day3_show_version.py`
