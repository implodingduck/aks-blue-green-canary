#!/bin/bash
export ARM_CLIENT_ID=$(cat ../spn.json | jq -r '.appId' )
export ARM_CLIENT_SECRET=$(cat ../spn.json | jq -r '.password' )
export ARM_TENANT_ID=$(cat ../spn.json | jq -r '.tenant' )
export TF_VAR_subscription_id=$(cat ../spn.json | jq -r '.subscription' )

cd ../terraform
terraform init
terraform apply --auto-approve

cluster_name=$(terraform output -raw cluster_name)
resource_group_name=$(terraform output -raw resource_group_name)

az login --service-principal -u $ARM_CLIENT_ID -p $ARM_CLIENT_SECRET --tenant $ARM_TENANT_ID
az aks get-credentials -n $cluster_name -g $resource_group_name
