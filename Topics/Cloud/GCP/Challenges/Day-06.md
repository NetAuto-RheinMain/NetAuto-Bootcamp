# Day 6: GKE Networking - Services
Yesterday we deployed pods, but they have ephemeral IP addresses. How do clients reliably connect to them? The answer is Kubernetes Services.

## Core Concepts:
* **Service**: A Kubernetes Service is an abstraction that defines a logical set of Pods and a policy by which to access them. It provides a single, stable IP address and DNS name.
* **Selector**: A Service uses labels and selectors to determine which Pods it should route traffic to.
* **Service Types**:
  * `ClusterIP`: (Default) Exposes the Service on an internal IP in the cluster. Not reachable from outside.
  * `NodePort`: Exposes the Service on each Node's IP at a static port.
  * `LoadBalancer`: Creates an external cloud load balancer (a GCP Network Load Balancer) to expose the Service to the internet.

## Today's Plan:
1. Prepare Pods with Labels:

  * Modify your Deployment YAML from yesterday to include labels. These are key-value pairs that we'll use for the Service selector.
  ```yaml
  # In your Deployment YAML
  metadata:
    name: nginx-deployment
    labels:
      app: nginx  # Add this label to the Deployment metadata
  spec:
    replicas: 3
    selector:
      matchLabels:
        app: nginx # This tells the Deployment which pods to manage
    template:
      metadata:
        labels:
          app: nginx # Add this label to the Pod template
      spec: # ... rest of pod spec
  ```
  * Apply the changes: `kubectl apply -f your-deployment.yaml`

2. Create a ClusterIP Service:

  * Create a file nginx-clusterip.yaml:
  ```sh
  apiVersion: v1
  kind: Service
  metadata:
    name: nginx-service
  spec:
    selector:
      app: nginx # This selects pods with the label "app: nginx"
    ports:
      - protocol: TCP
        port: 80 # The port the Service will be available on
        targetPort: 80 # The port on the pod to forward traffic to
    type: ClusterIP
  ```
  * Apply it: `kubectl apply -f nginx-clusterip.yaml`

  * Check it: `kubectl get service nginx-service`. Note the CLUSTER-IP.

## 🧠 Day 6 Challenge:
1. **Test the ClusterIP**: You can't access the ClusterIP from your local machine. Launch a temporary "jumper" pod inside the cluster (`kubectl run --rm -it jumper --image=busybox -- sh`). From inside this pod's shell, run `wget -O- <YOUR-CLUSTER-IP>`. You should get the Nginx welcome page.

2. **Expose Externally**: Change the `type` of your `nginx-service` from `ClusterIP` to `LoadBalancer` in the YAML file and re-apply it. Run `kubectl get service` again and wait for the `EXTERNAL-IP` to be assigned. Paste that external IP address into your browser. You should now see the Nginx welcome page from anywhere!

## 💥 Cleanup
When you are finished, delete the Kubernetes resources you created today.

Delete the Service: This will also de-provision the external Load Balancer if you created one for the challenge.
```sh
kubectl delete -f nginx-clusterip.yaml
```
Delete the Deployment: This will terminate the Nginx pods.
```sh
kubectl delete -f your-deployment.yaml
```
Reminder: If you are done for the day, remember to delete the GKE cluster itself (using the command from Day 5) to stop all billing.