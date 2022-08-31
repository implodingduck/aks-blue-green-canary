#!/bin/bash
source source.sh
az login --service-principal -u $ARM_CLIENT_ID -p $ARM_CLIENT_SECRET --tenant $ARM_TENANT_ID
az aks get-credentials -n $cluster_name -g $resource_group_name

bg_url=http://$(kubectl get services -o json | jq -r '.items[] | select(.metadata.name=="sampleapp-bg") | .status.loadBalancer.ingress[].ip')
current_selector=$(kubectl get service sampleapp-bg  -o json | jq -r '.spec.selector.version')

echo "Current Selector: $current_selector"
curl $bg_url
echo -e "\n===\nSwitching version selector..."
if [ "v1" == $current_selector ];
    then
    kubectl apply -f ../yaml/basic/bg-service-v2.yaml
else 
    kubectl apply -f ../yaml/basic/bg-service-v1.yaml
fi
sleep 5
new_selector=$(kubectl get service sampleapp-bg  -o json | jq -r '.spec.selector.version')
echo -e "New Selector: $new_selector\n==="
curl $bg_url