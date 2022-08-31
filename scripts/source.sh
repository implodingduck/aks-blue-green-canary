#!/bin/bash
export ARM_CLIENT_ID=$(cat ../spn.json | jq -r '.appId' )
export ARM_CLIENT_SECRET=$(cat ../spn.json | jq -r '.password' )
export ARM_TENANT_ID=$(cat ../spn.json | jq -r '.tenant' )
export TF_VAR_subscription_id=$(cat ../spn.json | jq -r '.subscription' )
cd ../terraform
export cluster_name=$(terraform output -raw cluster_name)
export resource_group_name=$(terraform output -raw resource_group_name)