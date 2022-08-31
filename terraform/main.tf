terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.20.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "=3.1.0"
    }
  }
}

provider "azurerm" {
  features {
  }
  subscription_id = var.subscription_id
}

locals {
    cluster_name = "akstestbgc${random_string.test.result}"
    tags = {
        "managed_by" = "terraform"
        "purpose" = "testing Blue/Green and Canary deployments"
    }
}

data "azurerm_client_config" "current" {}

resource "random_string" "test" {
  length  = 8
  special = false
  upper   = false
}

resource "azurerm_resource_group" "rg" {
  name     = "rg-aks-test-bgc-${random_string.test.result}"
  location = "East US"
  tags = local.tags
}


resource "azurerm_virtual_network" "default" {
  name                = "${local.cluster_name}-vnet-eastus"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = ["10.0.0.0/22"]

  tags = local.tags
}


resource "azurerm_subnet" "default" {
  name                 = "default-subnet-eastus"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.default.name
  address_prefixes     = ["10.0.0.0/24"]
}

data "azurerm_kubernetes_service_versions" "current" {
  location = azurerm_resource_group.rg.location
}


resource "azurerm_subnet" "cluster" {
  name                 = "${local.cluster_name}-subnet-eastus"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.default.name
  address_prefixes     = ["10.0.2.0/23"]

}

resource "azurerm_kubernetes_cluster" "aks" {
  name                    = local.cluster_name
  location                = azurerm_resource_group.rg.location
  resource_group_name     = azurerm_resource_group.rg.name
  dns_prefix              = local.cluster_name
  kubernetes_version      = data.azurerm_kubernetes_service_versions.current.latest_version
  private_cluster_enabled = false
  default_node_pool {
    name            = "default"
    node_count      = 1
    vm_size         = "Standard_B2s"
    os_disk_size_gb = "128"
    vnet_subnet_id  = azurerm_subnet.cluster.id


  }
  network_profile {
    network_plugin     = "azure"
    network_policy     = "azure"
    service_cidr       = "10.255.252.0/22"
    dns_service_ip     = "10.255.252.10"
    docker_bridge_cidr = "172.17.0.1/16"
  }

  role_based_access_control_enabled = true

  identity {
    type = "SystemAssigned"
  }
  
  tags = local.tags

}


resource "azurerm_role_assignment" "example" {
  scope                = azurerm_resource_group.rg.id
  role_definition_name = "Network Contributor"
  principal_id         = azurerm_kubernetes_cluster.aks.identity.0.principal_id
}

output "resource_group_name" {
    value = azurerm_resource_group.rg.name
}

output "cluster_name" {
    value = azurerm_kubernetes_cluster.aks.name
}