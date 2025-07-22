# **Day 1: Setting up the Lab Environment**

## **Objective:** 
Get Containerlab and your cEOS image ready, and deploy a basic topology.

## **Concepts:**

* Containerlab basics: Topology definition with YAML.
* Arista cEOS image management.
* Deploying and destroying labs.

## **Challenge:** Deploy a single cEOS router, verify its connectivity, and access its CLI.

**Code Examples:**

1.  **`clab_topology.yaml` (minimal topology):**

```yaml
name: single-ceos-lab
topology:
    nodes:
    ceos1:
        kind: arista_ceos
        image: ceos:4.28.0F # Replace with your downloaded cEOS image tag
```

2.  **Deploy the lab:**

```bash
sudo containerlab deploy --topo clab_topology.yaml
```

3.  **Verify container status:**

```bash
sudo docker ps
```

You should see a container named `clab-single-ceos-lab-ceos1`.

4.  **Access cEOS CLI:**

```bash
sudo docker exec -it clab-single-ceos-lab-ceos1 Cli
```

(You should now be in the Arista EOS CLI.)

5.  **Destroy the lab (after verification):**

```bash
sudo containerlab destroy --topo clab_topology.yaml --cleanup
```

