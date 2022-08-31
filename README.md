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
Opening up the v1 service ip url and the v2 service ip url will show you the extremely simple test app that we have setup. 

V1:
![v1](https://raw.githubusercontent.com/implodingduck/aks-blue-green-canary/main/images/v1.png)

V2:
![v2](https://raw.githubusercontent.com/implodingduck/aks-blue-green-canary/main/images/v2.png)

### Blue/Green
To understand Blue/Green with a kubernetes `service` lets look at [`basic\bg-service-v1.yaml`](https://github.com/implodingduck/aks-blue-green-canary/blob/main/yaml/basic/bg-service-v1.yaml)

The important part is at the very bottom:
```
selector:
    app: sampleapp
    version: v1
```
The selector tells the service what pod labels it should look for when directing traffic. In order to swap this to a new version, we can simply update the version reference to v2 which is exactly what [`basic\bg-service-v2.yaml`](https://github.com/implodingduck/aks-blue-green-canary/blob/main/yaml/basic/bg-service-v2.yaml) performs when we run it. 

You can see this in action by running `4-basic-bg-swap.sh`

![Showing how changing the service selector version attribute routes users from the pod running v1 to the pod running v2](https://raw.githubusercontent.com/implodingduck/aks-blue-green-canary/main/images/basic-bg.png)


## Ingress Controller
Kubernetes provides the kind `ingress` but in order for it to work it needs a [controller](https://kubernetes.io/docs/concepts/services-networking/ingress-controllers/). For this lab we will use [nginx-ingress controller](https://github.com/kubernetes/ingress-nginx/)

You can easily set one up by running `6-ingress-setup.sh`
## TODO
* Future 
    * Github IO page
    * Open Service Mesh