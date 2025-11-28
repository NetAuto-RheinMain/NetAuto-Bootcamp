# Day 7: GKE Networking - Ingress
A `LoadBalancer` Service is great, but it gives you one IP address per service, which can be expensive. Ingress is a more intelligent L7 (HTTP/S) load balancer that can route traffic to multiple services based on the request host or path.

## Core Concepts:
* **Ingress**: An API object that manages external access to the services in a cluster. It acts as a reverse proxy.
* **Ingress Controller**: The Ingress resource itself doesn't do anything. You need an Ingress controller (a pod running in your cluster) to read the Ingress resources and actually implement the routing rules. GKE manages a controller for you by default.
* **Routing Rules**: Ingress rules define how to route traffic. You can route based on the hostname (`foo.example.com`) or the URL path (`/api`, `/frontend`).

## Today's Plan:
1. Deploy a Second Application:

  * Let's create a simple "hello world" app. Create `hello-app.yaml`:
  ```yaml
  apiVersion: apps/v1
  kind: Deployment
  metadata:
    name: hello-app
  spec:
    replicas: 2
    selector:
      matchLabels:
        app: hello
    template:
      metadata:
        labels:
          app: hello
      spec:
        containers:
        - name: hello
          image: "gcr.io/google-samples/hello-app:1.0"
  ---
  apiVersion: v1
  kind: Service
  metadata:
    name: hello-service
  spec:
    selector:
      app: hello
    ports:
    - port: 80
      targetPort: 8080
    type: ClusterIP # Important! Ingress talks to ClusterIP services
  ```
  * Apply it: `kubectl apply -f hello-app.yaml`

2. Create the Ingress Resource:

  * Ensure your original Nginx service from Day 6 is a `ClusterIP` type, not `LoadBalancer`.
  * Create my-ingress.yaml:
  ```yaml
  apiVersion: networking.k8s.io/v1
  kind: Ingress
  metadata:
    name: my-app-ingress
  spec:
    defaultBackend:
      service:
        name: nginx-service # Default traffic goes to nginx
        port:
          number: 80
    rules:
    - http:
        paths:
        - path: /hello
          pathType: Prefix
          backend:
            service:
              name: hello-service # Traffic for /hello goes here
              port:
                number: 80
  ```
  * Apply it: `kubectl apply -f my-ingress.yaml`

3. Test the Ingress:
  * Get the IP address of the Ingress: `kubectl get ingress my-app-ingress`. It might take a few minutes for the address to be provisioned.
  * Navigate to `http://<INGRESS_IP>/` in your browser. You should see Nginx.
  * Navigate to `http://<INGRESS_IP>/hello`. You should see the "Hello, world!" message.

## 🧠 Day 7 Challenge:
Modify your Ingress resource to use host-based routing.

1. Deploy a second version of the hello-app, maybe using the `gcr.io/google-samples/hello-app:2.0` image, with its own Deployment and Service (hello-service-v2).
2. Update your my-ingress.yaml to route traffic for the host `v1.example.com` to the original hello-service and traffic for v2.example.com to the new hello-service-v2.
3. You won't have real DNS, so test this using curl with a host header: `curl --resolve "v1.example.com:80:<INGRESS_IP>" http://v1.example.com/` and `curl --resolve "v2.example.com:80:<INGRESS_IP>" http://v2.example.com/`.

## 💥 Cleanup
1. Delete the Ingress: This will de-provision the L7 Load Balancer created by GKE.
```sh
kubectl delete -f my-ingress.yaml
```
2. Delete the Applications:
```sh
kubectl delete -f hello-app.yaml
# Also delete the v2 app from the challenge if you created it
kubectl delete service hello-service-v2
kubectl delete deployment hello-app-v2
```
Reminder: Don't forget to delete your Nginx service/deployment from Day 6 and the GKE cluster itself if you are finished.