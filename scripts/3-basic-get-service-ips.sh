#!/bin/bash
source source.sh
az login --service-principal -u $ARM_CLIENT_ID -p $ARM_CLIENT_SECRET --tenant $ARM_TENANT_ID
az aks get-credentials -n $cluster_name -g $resource_group_name

echo V1 Service IP: http://$(kubectl get services -o json | jq -r '.items[] | select(.metadata.name=="sampleapp-v1") | .status.loadBalancer.ingress[].ip')
echo V2 Service IP: http://$(kubectl get services -o json | jq -r '.items[] | select(.metadata.name=="sampleapp-v2") | .status.loadBalancer.ingress[].ip')
echo Blue Green Service IP: http://$(kubectl get services -o json | jq -r '.items[] | select(.metadata.name=="sampleapp-bg") | .status.loadBalancer.ingress[].ip')
echo Canary Service IP: http://$(kubectl get services -o json | jq -r '.items[] | select(.metadata.name=="sampleapp-canary") | .status.loadBalancer.ingress[].ip')