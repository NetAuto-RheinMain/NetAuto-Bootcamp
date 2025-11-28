# Day 4: Infrastructure as Code with Terraform
Shell scripts are good, but they don't track the state of your infrastructure. Terraform is a tool for Infrastructure as Code (IaC) that lets you define your cloud resources in declarative configuration files and manage their lifecycle.

## Core Concepts
* **Declarative vs. Imperative**: gcloud is imperative (you say what to do). Terraform is declarative (you say what you want), and it figures out how to achieve that state.

* **Providers**: Terraform uses plugins called providers to interact with cloud APIs (like GCP, AWS, etc.).

* **Resources**: A resource block in Terraform defines an object in your infrastructure, like a VM instance or a VPC network.

* **State**: Terraform keeps a state file (.tfstate) to map your configuration to the real-world resources it manages.

## Today's Plan:
1. Setting up Terraform in Cloud Shell:

* Terraform is pre-installed in Cloud Shell. Verify with terraform version.
* Create a new directory for your project: mkdir terraform-day4 && cd terraform-day4

2. Writing Your First Terraform Config:

* Create a file named main.tf. This is where you'll define your infrastructure.

* **Provider Block**: Tell Terraform you're using the Google Cloud provider.
```go
terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "4.51.0"
    }
  }
}

provider "google" {
  project = "YOUR_GCP_PROJECT_ID" # Replace with your project ID
  region  = "us-central1"
}
```

Resource Block: Define a VPC network.
```go
resource "google_compute_network" "terraform-vpc" {
  name                    = "terraform-network"
  auto_create_subnetworks = false
}
```

3. Running Terraform Commands:

* `terraform init`: Initializes the directory, downloading the Google provider.
* `terraform plan`: Shows you what changes Terraform will make.
* `terraform apply`: Executes the plan and creates the resources. Type `yes` to confirm.
* `terraform destroy`: Destroys all resources managed by the configuration.

## 🧠 Day 4 Challenge:
Expand your main.tf file to replicate the infrastructure from Day 3's challenge using Terraform. You will need to add:

1. A `google_compute_subnetwork` resource.
2. A `google_compute_firewall` resource.
3. A `google_compute_instance` resource.

Use `terraform plan` to verify your changes and `terraform apply` to deploy it. The goal is to have a single configuration file that defines the entire environment.

## 💥 Cleanup
Cleaning up with Terraform is the easiest part! It knows everything it created.

Destroy all Resources: Navigate to your `terraform-day4` directory in Cloud Shell and run:
```sh
terraform destroy
```
Terraform will show you a plan of everything it's about to delete. Type `yes` to confirm. This will remove the VM, VPC, subnet, and firewall rule defined in your configuration.