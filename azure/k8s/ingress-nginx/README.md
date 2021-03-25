# ingress-nginx

This is the documentation for the NGINX Ingress Controller.

It is built around the Kubernetes Ingress resource, using a ConfigMap to store the NGINX configuration.

More info here: https://kubernetes.github.io/ingress-nginx/deploy/#azure

> Also, don't forget to follow the [hardening guide](https://kubernetes.github.io/ingress-nginx/deploy/hardening-guide/).

## installation

```bash
# easy install command
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v0.41.2/deploy/static/provider/cloud/deploy.yaml
```