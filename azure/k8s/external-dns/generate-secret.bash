#!/bin/bash

## variables
current=$PWD
azureJson="$PWD/azure.json"
namespace="external-dns"
secretName="azure-config-file"

## gather terraform output
cd $terraform_base
tenantId=$(terraform output tenant_id)
subscriptionId=$(terraform output subscription_id)
resourceGroup=$(terraform output resource_group)
aksManagedIdentityClientId=$(terraform output aks_default_managed_identity_client_id) # need this if more than one entity is present 

## create a json file in the following form: https://github.com/kubernetes-sigs/external-dns/blob/master/docs/tutorials/azure.md#azure-managed-service-identity-msi
cat <<EOF > $azureJson
{
  "tenantId": "$tenantId",
  "subscriptionId": "$subscriptionId",
  "resourceGroup": "$resourceGroup",
  "useManagedIdentityExtension": true,
  "userAssignedIdentityID": "$aksManagedIdentityClientId"
}
EOF
cat $azureJson | jq

## create the secret
echo "creating secret: $namespace/$secretName"
kubectl create secret generic $secretName --from-file=$azureJson --namespace $namespace

## cleanup
rm $azureJson