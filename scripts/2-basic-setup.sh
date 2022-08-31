#!/bin/bash
source source.sh
az login --service-principal -u $ARM_CLIENT_ID -p $ARM_CLIENT_SECRET --tenant $ARM_TENANT_ID
az aks get-credentials -n $cluster_name -g $resource_group_name

kubectl apply -f ../yaml/basic/v1-deployment.yaml
kubectl apply -f ../yaml/basic/v2-deployment.yaml
kubectl apply -f ../yaml/basic/bg-service-v1.yaml
kubectl apply -f ../yaml/basic/canary-service.yaml