# Day 3: Automation with Cloud Shell & gcloud
Manually clicking through the console is slow and prone to errors. Today, we start automating! The gcloud command-line tool is your key to controlling GCP programmatically.

## Core Concepts
* **Cloud Shell**: A browser-based shell environment with the Google Cloud SDK (gcloud) and other utilities pre-installed. It provides a consistent environment for managing your resources.

* **gcloud**: The primary CLI tool for creating and managing Google Cloud resources. It follows a `gcloud <component> <resource> <action>` structure (e.g., `gcloud compute instances create ...`).

* **Scripting**: You can combine `gcloud` commands into shell scripts to automate repetitive tasks.

## Today's Plan
1. Explore Cloud Shell:
    * Open Cloud Shell by clicking the `[>_]` icon in the top-right of the Google Cloud Console.
    * Run `gcloud config list` to see your current project and account settings.
    * Run `gcloud projects list` to list all projects you have access to.

2. Manage VMs with `gcloud`:
    * List your VMs: `gcloud compute instances list`
    * Stop a VM: `gcloud compute instances stop vm-one --zone=us-central1-a`
    * Start a VM: `gcloud compute instances start vm-one --zone=us-central1-a`

3. Manage Networks with gcloud:
    * List VPCs: `gcloud compute networks list`
    * List subnets: `gcloud compute networks subnets list`
    * Create a firewall rule:
        ```sh
        gcloud compute firewall-rules create allow-http-8080 \
            --network=automation-vpc \
            --allow=tcp:8080 \
            --source-ranges=0.0.0.0/0 \
            --direction=INGRESS
        ```

## 🧠 Day 3 Challenge
Write a single shell script (`.sh` file) in your Cloud Shell that does the following:

1. Creates a new VPC named `scripted-vpc`.
2. Creates a subnet `scripted-subnet-east` in `us-east1` with range `10.10.0.0/24` within that VPC.
3. Creates a firewall rule to allow SSH (tcp:22) from any source (`0.0.0.0/0`). Note: This is not secure for production, but fine for a temporary lab!
4. Creates a new VM instance named `scripted-vm` in the new subnet.
5. Run the script and verify that all resources were created correctly in the console.

## 💥 Cleanup
1. Delete Challenge Resources: If you completed the challenge, delete those resources first.
```sh
# Delete the VM created by the script
gcloud compute instances delete scripted-vm --zone=us-east1-b --quiet
# Delete the VPC created by the script (also deletes its subnet and firewall rule)
gcloud compute networks delete scripted-vpc --quiet
```
2. Delete Today's Firewall Rule:
```sh
gcloud compute firewall-rules delete allow-http-8080 --quiet
```
