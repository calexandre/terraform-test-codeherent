# external-dns

This tutorial describes how to setup ExternalDNS for usage within a Kubernetes cluster on Azure.

Make sure to use **>=0.5.7** version of ExternalDNS for this tutorial.

This tutorial uses [Azure CLI 2.0](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli) for all
Azure commands and assumes that the Kubernetes cluster was created via Azure Container Services and `kubectl` commands
are being run on an orchestration node.

## installation

Tutorial: <https://github.com/kubernetes-sigs/external-dns/blob/master/docs/tutorials/azure.md>

```bash
# generate secret from terraform output
bash generate-secret.sh

# create the namespace
kubectl apply -f 00-namespace.yaml
kubectl apply -f 20-deployment.yaml

# logs
kubectl logs -n external-dns -l app=external-dns -f
```