#!/bin/bash
source source.sh
az login --service-principal -u $ARM_CLIENT_ID -p $ARM_CLIENT_SECRET --tenant $ARM_TENANT_ID
az aks get-credentials -n $cluster_name -g $resource_group_name

canary_url=http://$(kubectl get services -o json | jq -r '.items[] | select(.metadata.name=="sampleapp-canary") | .status.loadBalancer.ingress[].ip')

echo "calling Canary Service..."
for i in {1..10}
do
  echo ""
  curl $canary_url
  echo ""
done