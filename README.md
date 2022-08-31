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


### Canary
For the canary scenario we take advantage in how a kubernetes `service` does its lookup. By simplifying the selector to be just the app name and not include the version, then it will auto load balance between the pods of both versions. Running `5-basic-canary.sh` calls the same service IP but the responses will switch between both v1 and v2. 

![Showing how having the service selector with just app name and no version will auto balance between the pod running v1 to the pod running v2](https://raw.githubusercontent.com/implodingduck/aks-blue-green-canary/main/images/basic-canary.png)


**Extra Credit!** Not in a script but if you adjust the scale of v1 vs v2, then you can adjust the "weight" that the canary version gets called vs the stable version. 


## Ingress Controller
Kubernetes provides the kind `ingress` but in order for it to work it needs a [controller](https://kubernetes.io/docs/concepts/services-networking/ingress-controllers/). For this lab we will use [nginx-ingress controller](https://github.com/kubernetes/ingress-nginx/)

You can easily set one up by running `6-ingress-setup.sh`

Running `7-ingress-get-ingress-ip.sh` will return an IP but the default path is not actually setup in this lab so it will return a 404 page.

### Blue/Green
With the ingress controller we can use a second host for routing traffic to a green deployment.

In this lab we setup a host listen on aks.implodingduck.root for the v1 of the app and aks-checkout.implodingduck.root for the v2 of the app to test. Then to activate v2 as the main version we adjust the backend service for the aks.implodingduck.root ingress and move v1 into checkout. The script `8-ingress-bg-swap.sh` can be ran to highlight this. 

![Showing how having two different host ingress routes can be defined and switching the endpoint to activate v2](https://raw.githubusercontent.com/implodingduck/aks-blue-green-canary/main/images/ingress-bg.png)

### Canary
Nginx Ingress Controller has built in support for a [canary ingress](https://kubernetes.github.io/ingress-nginx/user-guide/nginx-configuration/annotations/#canary)

This lets us define a specific canary ingress and define either a header, cookie and/or weight to control the routing to the defined version of the application. The script `9-ingress-canary.sh` can be ran to highlight this. 

![Showing how nginx ingress controller evaluates the canary ingress definition to route the traffic between two different versions of an app](https://raw.githubusercontent.com/implodingduck/aks-blue-green-canary/main/images/ingress-canary.png)

## Service Mesh
Each service mesh in Kubernetes has its own way of helping with Blue/Green and Canary deployments. 

* [Open Service Mesh](https://release-v1-0.docs.openservicemesh.io/docs/demos/canary_rollout/)

More content around this coming eventually...