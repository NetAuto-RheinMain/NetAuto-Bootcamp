# Day 2: VPC Networking Deep Dive
Yesterday, we created a basic network. Today, we'll dive deeper into controlling traffic flow and connecting different networks together.

## Core Concepts
* **Firewall Rules**: VPC firewall rules control incoming (ingress) and outgoing (egress) traffic to and from your VMs. They are stateful, meaning if you allow an incoming request, the response traffic is automatically allowed.

* **Subnets**: A VPC is global, but its IP ranges are broken down into regional subnets. VMs get their internal IP addresses from a subnet's range.

* **VPC Network Peering**: This allows you to connect two VPC networks so that resources in each network can communicate with each other using internal IP addresses, without traversing the public internet.

## Today's Plan
1. Mastering Firewall Rules:
    * Go to "VPC network" -> "Firewall".
    * Notice the default rules. One, `default-allow-internal`, allows traffic between all instances on the network. This is why your Day 1 challenge might have worked!
    * Create a new rule:
        * Name: `allow-ssh-from-iap`
        * Direction: `Ingress`
        * Targets: `All instances in the network`
        * Source filter: `IP ranges` -> `35.235.240.0/20` (This range is for Google's Identity-Aware Proxy, allowing you to SSH from the console).
        * Protocols and ports: `tcp:22`

2. Setting up a Second VPC:
    * Create a new VPC named `peering-vpc`.
    * Add a subnet in `us-central1` named `peering-subnet` with range `192.168.1.0/24`.
    * Launch a VM named `vm-three` in this new VPC and subnet.

3. Connecting VPCs with Peering:
    * Go to "VPC network" -> "VPC network peering" -> "Create connection".
    * Select your `automation-vpc` and the `peering-vpc`.
    * Create the peering connection. You'll need to create it from both VPCs' perspectives.

## 🧠 Day 2 Challenge
After setting up VPC peering, SSH into vm-one (in automation-vpc) and try to ping the internal IP address of vm-three (in peering-vpc). Does it work? If not, what firewall rule do you need to add to both networks to allow ICMP (ping) traffic between the peered VPCs?

## 💥 Cleanup
1. Delete the VM instance:
```sh
gcloud compute instances delete vm-three --zone=us-central1-a --quiet
```
2. Delete the VPC Peering Connection: You must delete the peering from both VPCs.
Note: The peering name is what you named it during creation.
```sh
gcloud compute networks peerings delete <peering-name-from-automation-vpc> --network=automation-vpc --quiet
gcloud compute networks peerings delete <peering-name-from-peering-vpc> --network=peering-vpc --quiet
```
3. Delete the Second VPC:
```sh
gcloud compute networks delete peering-vpc --quiet
```
4. Delete the Firewall Rule:
```sh
gcloud compute firewall-rules delete allow-ssh-from-iap --quiet
```