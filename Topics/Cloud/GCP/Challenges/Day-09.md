# Day 9: Advanced GKE Networking - Network Policies
We've controlled north-south traffic (from outside the cluster to inside). Now let's control east-west traffic (between pods inside the cluster). Network Policies are the firewall for your pods.

## Core Concepts:
* **Default-Allow**: By default, all pods in a Kubernetes cluster can communicate with all other pods, without restriction.
* **Network Policy**: An object that specifies how groups of pods are allowed to communicate with each other and with other network endpoints. They are like firewall rules for pods.
* **Label Selectors**: Network Policies don't use IP addresses. They use labels to select which pods the policy applies to and what traffic is allowed.
* **Policy Types**: Policies can be `Ingress` (for incoming traffic to a pod) or Egress (for outgoing traffic from a pod).

## Today's Plan:
1. Enable Network Policy on Your Cluster:
  * Network Policies must be explicitly enabled.
  * Run this command:
```sh
gcloud container clusters update my-gke-cluster \
    --update-addons=NetworkPolicy=ENABLED \
    --region=us-central1
```

2. Deploy a "Frontend" and "Backend":

  * Let's simulate a simple two-tier app.
  * Backend (a simple Nginx pod):
```yaml
# backend.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: backend-api
spec:
  replicas: 1
  selector:
    matchLabels:
      app: backend
  template:
    metadata:
      labels:
        app: backend # The important label
    spec:
      containers:
      - name: nginx
        image: nginx
```
  * Frontend (a "jumper" pod we'll use to test from):
```yaml
# frontend.yaml
apiVersion: v1
kind: Pod
metadata:
  name: frontend-app
  labels:
    app: frontend # The important label
spec:
  containers:
  - name: busybox
    image: busybox
    command: ["sleep", "3600"]
```
  * Apply both: `kubectl apply -f backend.yaml -f frontend.yaml`.

3. Apply a Deny-All Policy:

   * To start, let's lock down the backend completely.
```yaml
# deny-all-ingress.yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: backend-deny-all
spec:
  podSelector:
    matchLabels:
      app: backend # Apply this policy to the backend pod
  policyTypes:
  - Ingress
```
  * Apply it: `kubectl apply -f deny-all-ingress.yaml`. The empty ingress rule means nothing is allowed.

## 🧠 Day 9 Challenge:
Right now, your frontend can't talk to your backend.

1. Verify this: `kubectl exec -it frontend-app -- sh`. Inside the shell, get the backend pod's IP (`kubectl get pods -l app=backend -o wide`) and try to `wget` it. It will time out.
2. Your challenge is to create a new Network Policy that specifically allows ingress traffic to pods with the label `app: backend` only from pods with the label `app: frontend`.
3. After applying your new policy, exec into the `frontend-app` pod again and re-run the `wget` command. It should now succeed!

## 💥 Cleanup
1. Delete the Network Policies:
```sh
kubectl delete networkpolicy backend-deny-all
kubectl delete networkpolicy <your-challenge-policy-name>
```
2. Delete the Application Pods:
```sh
kubectl delete -f frontend.yaml
kubectl delete -f backend.yaml
```
3. Disable Network Policy Addon (Optional): You can disable the addon if you wish, but it's not necessary if you are deleting the cluster.
```sh
gcloud container clusters update my-gke-cluster \
    --update-addons=NetworkPolicy=DISABLED \
    --region=us-central1
```
4. Reminder: Don't forget to delete the GKE cluster if you are done for the day.