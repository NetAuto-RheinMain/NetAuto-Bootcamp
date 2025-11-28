# Day 10: Putting It All Together - A Hybrid Scenario
Congratulations, you've made it to the final day! Today, we'll combine everything we've learned—Terraform, VPCs, VMs, GKE, Services, and Network Policies—to build and secure a realistic scenario.

## The Mission:
Deploy a complete environment using Terraform. This environment will consist of:

A custom VPC.

A GKE cluster within that VPC.

A Compute Engine VM in the same VPC, which will act as an internal "monitoring" tool.

A web application deployed to the GKE cluster. This application has two endpoints: a public one (/) and a private one (/metrics).

The final network configuration must enforce these rules:

External users can only access the / endpoint of the web application.

The monitoring VM can access both the / and /metrics endpoints.

No other pods or VMs can access the /metrics endpoint.

## High-Level Plan:
Terraform: Write a single Terraform configuration (.tf files) to provision the VPC, subnet, GKE cluster, and the monitoring VM. This is the foundation.

Kubernetes Deployments: Create YAML files for your web application. You'll need two separate Deployments and Services: one for the main app and one for the metrics endpoint. This separation allows us to apply different rules.

web-app Deployment/Service (label: app: web)

metrics-app Deployment/Service (label: app: metrics)

Kubernetes Networking: Create YAML files for the networking objects.

An Ingress resource to route external traffic for / to the web-app service.

A Network Policy that allows ingress to the metrics-app pods only from the IP address range of your VPC's subnet (where the monitoring VM lives).

## 🧠 Day 10 Challenge:
Your challenge is to implement the full scenario described above.

* **Step 1**: Terraform Foundation. Write the Terraform code to create the google_compute_network, google_compute_subnetwork, google_container_cluster, and google_compute_instance. Run terraform apply.
* **Step 2**: Deploy Apps. After the cluster is ready, configure kubectl and deploy your web-app and metrics-app YAMLs. For the app image, you can use nginx for both as a placeholder.
* **Step 3**: Secure the Network.
    * Deploy the Ingress resource. Get its external IP and verify you can access / but get an error for /metrics.
    * Deploy the final, crucial Network Policy.
* **Step 4**: Final Verification.
    * From your local browser, confirm you can only see the main page.
    * SSH into your Terraform-created monitoring VM. From its shell, curl the internal ClusterIP for both the web-app service and the metrics-app service. Both should succeed.

This final challenge ties together Infrastructure as Code, virtual machines, container orchestration, and multi-layered network security. Good luck!

## 💥 Cleanup
This is a two-step process: first clean up the Kubernetes resources you applied manually, then destroy the underlying infrastructure with Terraform.

1. Delete all Kubernetes resources: Using the YAML files you created for the applications, ingress, and network policy:
```sh
kubectl delete -f <your-ingress-file>.yaml
kubectl delete -f <your-network-policy-file>.yaml
kubectl delete -f <your-web-app-file>.yaml
kubectl delete -f <your-metrics-app-file>.yaml
```
2. Destroy the Terraform Infrastructure: Navigate to the directory containing your Day 10 Terraform files and run:
```sh
terraform destroy -auto-approve
```
This will delete the GKE cluster, the monitoring VM, and the VPC network, effectively cleaning up everything from this final day.