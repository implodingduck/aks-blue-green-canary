# aks-blue-green-canary
This repo is to help demonstrate different ways you can do Blue/Green and canary deployments inside of AKS

* **Blue/Green:** having two different versions of an application running and gives the option to validate the green before replacing the blue version
* **Canary:** having two different versions of an application live at the same time, some users will experience the old version and some will experience the new

## Prereqs
* Azure Cloud Shell 
* Or if running locally:
    * terraform
    * kubectl
    * helm
    * jq

* Fill out spn.json to let the scripts use a Service Principal 
* If you dont have an existing spn you can create one with:
```
SUB_ID=$(az account show | jq -r '.id')
az ad sp create-for-rbac -n "implodingduck-ghactions-spn" --role Contributor --scopes subscriptions/$SUB_ID
```
* Then run ```./1-setup.sh``` to create the initial AKS cluster

## Basic Kubernetes
Kubernetes uses `service` for routing to different pods and the base `service` is powerful enough to help with both blue/green and canary deployments.

Setup the basic example by running `2-basic-setup.sh`

Validate that the services have been created with `3-basic-get-service-ips.sh`

## Ingress Controller
Kubernetes provides the kind `ingress` but in order for it to work it needs a [controller](https://kubernetes.io/docs/concepts/services-networking/ingress-controllers/). For this lab we will use [nginx-ingress controller](https://github.com/kubernetes/ingress-nginx/)

You can easily set one up by running `6-ingress-setup.sh`
## TODO
* Future 
    * Github IO page
    * Open Service Mesh