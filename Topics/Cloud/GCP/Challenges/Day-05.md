# Day 5: Introduction to Google Kubernetes Engine (GKE)
We've mastered VMs. Now let's move up the stack to containers and orchestration with GKE, Google's managed Kubernetes service.

## Core Concepts:
* **Containers:** Lightweight, portable units of software that package up code and all its dependencies. Docker is the most popular container runtime.
* **Kubernetes (K8s)**: An open-source system for automating deployment, scaling, and management of containerized applications.
* **GKE Cluster**: A GKE cluster consists of a control plane (managed by Google) and a set of worker machines called nodes (which are actually Compute Engine VMs).
* **Nodes**: The worker machines where your containers run.
* **Pods**: The smallest deployable units in Kubernetes. A Pod is a group of one or more containers that share storage and network resources.

## Today's Plan:
Enable the GKE API: Before you can create a cluster, you must enable the API in your project.

gcloud services enable container.googleapis.com

Create a GKE Cluster: We'll create a small, cost-effective Autopilot cluster. GKE Autopilot manages the nodes for you.
```sh
gcloud container clusters create-auto "my-gke-cluster" \
    --region=us-central1
```
(This can take 5-10 minutes)

Connect to the Cluster: Configure kubectl (the Kubernetes command-line tool) to talk to your new cluster.
```sh
gcloud container clusters get-credentials my-gke-cluster --region=us-central1
```
Run Your First Pod:

Create a file named nginx-pod.yaml:
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: nginx-web-server
spec:
  containers:
  - name: nginx
    image: nginx:latest
    ports:
    - containerPort: 80
```
Apply the configuration: `kubectl apply -f nginx-pod.yaml`

Check the status: `kubectl get pods`

## 🧠 Day 5 Challenge:
Modify the nginx-pod.yaml file to create a Deployment instead of a single Pod. A Deployment manages a ReplicaSet, which ensures that a specified number of Pod replicas are always running.

Your goal is to create a Deployment that runs three replicas of the Nginx web server. Use kubectl get pods to verify that all three are running. Then, delete one of the pods with `kubectl delete pod <pod-name>` and quickly run `kubectl get pods` again. What happens?

## 💥 Cleanup
To avoid ongoing charges, you should destroy the resources you created.

Delete Kubernetes Resources: First, delete the Pod or Deployment you created within the cluster.
```sh
# If you created the single pod
kubectl delete -f nginx-pod.yaml

# If you created the deployment for the challenge (use the filename)
kubectl delete -f your-deployment.yaml
```

Delete the GKE Cluster: This is the most important step, as the cluster is the primary source of costs for this lesson.
```sh
gcloud container clusters delete "my-gke-cluster" --region=us-central1 --quiet
```