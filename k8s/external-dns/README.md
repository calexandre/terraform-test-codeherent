# external-dns

This tutorial describes how to setup ExternalDNS for usage within a Kubernetes cluster on GKE.

Please note that this workload is already provisioned via terraform using the `kubectl` provider.
The files provided here are used by the provider and any change will be reflected when you execute `terraform apply`.

## installation via k8s

Tutorial: <https://github.com/kubernetes-sigs/external-dns/blob/master/docs/tutorials/gke.md#gke-with-workload-identity>

```bash
# create the namespace
kubectl apply -f 00-namespace.yaml
kubectl apply -f 20-deployment.yaml

# logs
kubectl logs -n external-dns -l app=external-dns -f
```

## remarks

Use the `nginx` deployment to debug if you need.