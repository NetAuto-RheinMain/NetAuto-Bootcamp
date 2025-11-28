# Day 1: GCP Fundamentals & Your First VM
Welcome to your first day! Today, we'll get acquainted with the Google Cloud environment and launch our first virtual machine (VM). The goal is to understand the foundational building blocks.

## Core Concepts
* **Projects**: In GCP, all resources belong to a Project. It's the primary unit for organizing, managing billing, and controlling permissions.

* **IAM (Identity and Access Management)**: This service controls who (which user or service) can do what (which actions) on which resources.

* **VPC (Virtual Private Cloud)**: A VPC is your private, isolated network in the cloud. It's a global resource, but it contains regional subnets.

* **Compute Engine**: This is GCP's Infrastructure-as-a-Service (IaaS) offering, allowing you to create and run VMs.

## Today's Plan
1. Create a Project: If you don't have one already, create a new project in the Google Cloud Console.

2. Create a VPC Network: Although a "default" VPC exists, let's create a custom one.
    * Go to "VPC network" -> "VPC networks" -> "Create VPC network".
        * Give it a name (e.g., `automation-vpc`).
        * Choose "Custom" for subnet creation mode.
        * Add a subnet:
            * Name: `subnet-us-central1`
            * Region: `us-central1`
            * IP address range: `10.0.1.0/24`

3. Launch a Compute Engine VM:
    * Go to "Compute Engine" -> "VM instances" -> "Create instance".
        * Name your instance `vm-one`.
        * Select the `us-central1` region.
        * Under "Networking", select your `automation-vpc` and `subnet-us-central1`.
        * Allow HTTP traffic in the firewall settings for later use.
        * Click "Create".

## 🧠 Day 1 Challenges
Create a second VM named `vm-two` in a different region (e.g., `europe-west1`). To do this, you'll first need to add a new subnet in that region to your `automation-vpc` (e.g., `subnet-europe-west1` with range `10.0.2.0/24`).</br>
</br>
Once both VMs are running, try to ping the internal IP address of vm-two from vm-one using the SSH button in the console. Question: Does it work by default? Why or why not? (Hint: Check your firewall rules).

# 💥 Cleanup
To avoid ongoing charges, you should destroy the resources you created. It's best to delete resources in the reverse order of creation.

1. Delete the VM instances:
    ```sh
    gcloud compute instances delete vm-one --zone=us-central1-a --quiet
    gcloud compute instances delete vm-two --zone=europe-west1-b --quiet
    ```
Delete the VPC Network: Deleting the VPC will also delete its subnets and default firewall rules.
```sh
gcloud compute networks delete automation-vpc --quiet
```