# **Day 8: Structured Data with TextFSM (Optional but Recommended)**

## **Objective:** 
Parse unstructured command output into structured data using TextFSM with Nornir.

## **Concepts:**
* `nornir_scrapli.tasks.send_and_parse_command` (if using Scrapli's built-in parsing).
* Alternatively, using `nornir_utils.plugins.functions.print_result` and `textfsm` directly.
* The need for NTC-templates.

## **Challenge:** 
Get the `show ip interface brief` output and parse it into structured data.

## **Code Examples:**

1.  **Ensure NTC-templates are available.** You might need to install `ntc-templates` and configure the `textfsm_templates_path` in your Nornir config or within the task.
```bash
pip install ntc-templates
```

2.  **`nornir_config.yaml` (add TextFSM path if using `send_and_parse_command`):**
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
# Add if you are using scrapli's parse capability with external templates
# connection_options:
#   scrapli:
#     extras:
#       genie_xpaths: null # Disable Genie if not using
#       textfsm_templates_path: /path/to/ntc-templates/templates # Replace with your actual path
```

*Note: The `textfsm_templates_path` setting above is for Scrapli's built-in parsing. You might need to adjust based on your specific `scrapli` version or if you're using a different parsing method.*

3.  **`day8_parse_output.py`:**

```python
from nornir import InitNornir
from nornir_scrapli.tasks import send_command
from nornir.core.filter import F
from pprint import pprint

# If you choose to parse manually with textfsm
import textfsm
import os

# Path to your NTC-templates
# Adjust this path to where your ntc-templates are installed or downloaded
NTC_TEMPLATES_PATH = "/path/to/ntc-templates/templates" # e.g., /usr/local/lib/python3.x/dist-packages/ntc_templates/templates

def parse_interface_brief(task):
    cmd = "show ip interface brief"
    result = task.run(task=send_command, command=cmd)
    raw_output = result.result

    if not raw_output:
        print(f"No output received for {cmd} from {task.host.name}")
        return

    # Attempt to parse using TextFSM
    try:
        template_file = os.path.join(NTC_TEMPLATES_PATH, "arista_eos_show_ip_interface_brief.textfsm")
        if not os.path.exists(template_file):
            print(f"TextFSM template not found for Arista: {template_file}")
            # Fallback to just storing raw output if template isn't found
            task.host["parsed_interfaces"] = raw_output
            return

        with open(template_file) as f:
            re_table = textfsm.TextFSM(f)
            parsed_output = re_table.ParseText(raw_output)
            header = re_table.header

            # Convert to a list of dictionaries for easier consumption
            structured_data = [dict(zip(header, row)) for row in parsed_output]
            task.host["parsed_interfaces"] = structured_data
            print(f"\n--- Parsed Interface Brief for {task.host.name} ---")
            pprint(structured_data)
    except Exception as e:
        print(f"Error parsing interface brief from {task.host.name}: {e}")
        task.host["parsed_interfaces"] = raw_output # Store raw on error


def main():
    nr = InitNornir(config_file="nornir_config.yaml")
    arista_nr = nr.filter(F(groups__contains="arista_devices"))
    arista_nr.run(task=parse_interface_brief)

if __name__ == "__main__":
    main()
```

Run: `python day8_parse_output.py`
*Crucial: Ensure `NTC_TEMPLATES_PATH` points to the correct location of your `ntc-templates` installation.*
