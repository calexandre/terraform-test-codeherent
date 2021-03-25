# cert-manager

cert-manager runs within your Kubernetes cluster as a series of deployment resources. It utilizes CustomResourceDefinitions to configure Certificate Authorities and request certificates.

It is deployed using regular YAML manifests, like any other application on Kubernetes.

Once cert-manager has been deployed, you must configure Issuer or ClusterIssuer resources which represent certificate authorities. More information on configuring different Issuer types can be found in the respective configuration guides.

## installation

```bash
# download the manifest
curl -L https://github.com/jetstack/cert-manager/releases/download/v1.0.4/cert-manager.yaml > 00-manifest.yaml

# create the operator
kubectl apply --validate=false -f 00-manifest.yaml

# create our clusterissuer (you need to edit this file)
kubectl apply -f 20-clusterissuer.yaml

# logs
kubectl logs -n cert-manager -l app=cert-manager -f
```