#!/bin/bash
source source.sh
az login --service-principal -u $ARM_CLIENT_ID -p $ARM_CLIENT_SECRET --tenant $ARM_TENANT_ID
az aks get-credentials -n $cluster_name -g $resource_group_name

resolve_ip=$(kubectl get services -o json | jq -r '.items[] | select(.metadata.name=="ingress-nginx-controller") | .status.loadBalancer.ingress[].ip')
current_backend_service=$(kubectl get ingress sampleapp-bg-ingress -o json | jq -r '.spec.rules[] | select(.host=="aks.implodingduck.root") | .http.paths[0].backend.service.name')
checkout_backend_service=$(kubectl get ingress sampleapp-bg-ingress-checkout -o json | jq -r '.spec.rules[] | select(.host=="aks-checkout.implodingduck.root") | .http.paths[0].backend.service.name')
echo -e "Current Active:"
echo $current_backend_service
echo 'Calling http://aks.implodingduck.root'
curl --resolve aks.implodingduck.root:80:$resolve_ip http://aks.implodingduck.root

echo -e "\n\nCurrent Checkout:"
echo $checkout_backend_service
echo 'Calling http://aks-checkout.implodingduck.root'
curl --resolve aks-checkout.implodingduck.root:80:$resolve_ip http://aks-checkout.implodingduck.root
echo -e '\n==='
echo 'swapping active and checkout'
if [ "ingress-sampleapp-v1" == $current_backend_service ];
    then
    kubectl apply -f ../yaml/nginx-ingress/bg-ingress-activate.yaml
else
    kubectl apply -f ../yaml/nginx-ingress/bg-ingress.yaml
fi
echo '==='
new_backend_service=$(kubectl get ingress sampleapp-bg-ingress -o json | jq -r '.spec.rules[] | select(.host=="aks.implodingduck.root") | .http.paths[0].backend.service.name')
new_checkout_backend_service=$(kubectl get ingress sampleapp-bg-ingress-checkout -o json | jq -r '.spec.rules[] | select(.host=="aks-checkout.implodingduck.root") | .http.paths[0].backend.service.name')
echo -e "\nNew Active:"
echo $new_backend_service
echo 'Calling http://aks.implodingduck.root'
curl --resolve aks.implodingduck.root:80:$resolve_ip http://aks.implodingduck.root

echo -e "\n\nNew Checkout:"
echo $new_checkout_backend_service
echo 'Calling http://aks-checkout.implodingduck.root'
curl --resolve aks-checkout.implodingduck.root:80:$resolve_ip http://aks-checkout.implodingduck.root