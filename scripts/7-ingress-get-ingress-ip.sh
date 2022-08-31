#!/bin/bash
source source.sh
az login --service-principal -u $ARM_CLIENT_ID -p $ARM_CLIENT_SECRET --tenant $ARM_TENANT_ID
az aks get-credentials -n $cluster_name -g $resource_group_name

echo Nginx Ingress IP: http://$(kubectl get services -o json | jq -r '.items[] | select(.metadata.name=="ingress-nginx-controller") | .status.loadBalancer.ingress[].ip')