# Day 8: Connecting VMs and GKE Pods
So far, our VMs and GKE pods have lived in separate worlds. Today, we'll bridge that gap. Understanding how they can communicate is crucial for hybrid architectures where you might have a database on a VM and an application in GKE.

## Core Concepts:
* **VPC-Native Clusters**: Modern GKE clusters are "VPC-native". This is the key concept. It means that Pods get their IP addresses directly from a secondary IP range of the VPC's subnet. They are no longer hidden behind an overlay network.
* **First-Class Citizens**: Because Pods have IPs from the VPC, they are first-class citizens on the network. VMs can route to them, and they can route to VMs, subject to firewall rules.
* **IP Aliasing**: The feature that allows a VM network interface (like on a GKE node) to have multiple IP ranges assigned to it. This is how GKE assigns Pod IPs from the VPC subnet.

## Today's Plan:
1. Inspect Your GKE Cluster's Networking:
    * Go to the GKE section in the Cloud Console and click on your cluster.
    * Go to the "Networking" tab. Note the "Pod address range". This is a secondary range assigned to your `subnet-us-central1`.
    * List your pods with more detail: `kubectl get pods -o wide`. Note that their IP addresses are from the Pod address range you just saw.

2. Create a Test VM:
    * Using the `gcloud` command or the console, create a new VM instance named `vm-tester`.
    * Crucially, create it in the same VPC and region as your GKE cluster (`automation-vpc` and `us-central1`).

3. Attempt Communication:
    * Get the ClusterIP of your nginx-service from Day 6: `kubectl get service nginx-service`.
    * SSH into your `vm-tester`.
    * From the VM's shell, try to access the service: `curl <NGINX_SERVICE_CLUSTER_IP>`.

It will fail! Why? By default, firewall rules don't allow traffic from the VM's primary subnet range to the Pod's secondary subnet range.

## 🧠 Day 8 Challenge:
Your challenge is to make the `curl` command from the `vm-tester` work.

1. Find the IP range for your VMs (this is the primary IP range of your subnet, e.g., `10.0.1.0/24`).
2. Find the secondary IP range for your Pods (you found this in the GKE networking tab).
3. Go to "VPC network" -> "Firewall" and create a new firewall rule that allows ingress traffic on `tcp:80` for all targets, with the source IP range set to your VM's primary subnet range.

After adding the rule, SSH back into `vm-tester` and run the `curl <NGINX_SERVICE_CLUSTER_IP>` command again. It should now succeed!

## 💥 Cleanup
1. Delete the Test VM:
```sh
gcloud compute instances delete vm-tester --zone=us-central1-a --quiet
```
2. Delete the Firewall Rule: You must remember the name you gave the firewall rule in the challenge.
```sh
gcloud compute firewall-rules delete <your-challenge-firewall-rule-name> --quiet
```
3. Reminder: Remember to delete your GKE cluster and other resources from previous days if you are stopping here.