#!/bin/bash
source source.sh
az login --service-principal -u $ARM_CLIENT_ID -p $ARM_CLIENT_SECRET --tenant $ARM_TENANT_ID
az aks get-credentials -n $cluster_name -g $resource_group_name

helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update

helm install ingress-nginx ingress-nginx/ingress-nginx \
  --set controller.service.annotations."service\.beta\.kubernetes\.io/azure-load-balancer-health-probe-request-path"=/healthz

kubectl apply -f ../yaml/nginx-ingress/v1-deployment.yaml
kubectl apply -f ../yaml/nginx-ingress/v2-deployment.yaml
kubectl apply -f ../yaml/nginx-ingress/bg-ingress.yaml
kubectl apply -f ../yaml/nginx-ingress/canary-ingress.yaml