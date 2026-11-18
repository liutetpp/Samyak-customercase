locals {
  common_tags = {
    customer       = "KUNLUN GROUP LIMITED"
    partner        = "HONGKONG SAMYAK TECHNOLOGIES LIMITED"
    project        = "KUNLUN Azure AI Platform"
    businessSystem = "Global Internet Content and Interactive Business Platform"
    environment    = var.environment
    managedBy      = "terraform"
  }

  managed_namespaces = [
    "kunlun-system",
    "kunlun-ingress",
    "kunlun-observability",
    "kunlun-prod",
    "kunlun-data",
    "kunlun-ai",
    "kunlun-devops"
  ]
}

data "azurerm_client_config" "current" {}

resource "azurerm_resource_group" "network" {
  name     = var.resource_group_names.network
  location = var.location
  tags     = local.common_tags
}

resource "azurerm_resource_group" "aks" {
  name     = var.resource_group_names.aks
  location = var.location
  tags     = local.common_tags
}

resource "azurerm_resource_group" "data" {
  name     = var.resource_group_names.data
  location = var.location
  tags     = local.common_tags
}

resource "azurerm_resource_group" "ai" {
  name     = var.resource_group_names.ai
  location = var.location
  tags     = local.common_tags
}

resource "azurerm_resource_group" "api" {
  name     = var.resource_group_names.api
  location = var.location
  tags     = local.common_tags
}

resource "azurerm_resource_group" "shared" {
  name     = var.resource_group_names.shared
  location = var.location
  tags     = local.common_tags
}

resource "azurerm_virtual_network" "hub" {
  name                = var.hub_vnet_name
  address_space       = var.hub_vnet_address_space
  location            = azurerm_resource_group.network.location
  resource_group_name = azurerm_resource_group.network.name
  tags                = local.common_tags
}

resource "azurerm_subnet" "nfs" {
  name                 = "nfs-subnet"
  resource_group_name  = azurerm_resource_group.network.name
  virtual_network_name = azurerm_virtual_network.hub.name
  address_prefixes     = [var.nfs_subnet_prefix]
}

resource "azurerm_virtual_network" "aks" {
  name                = var.aks_vnet_name
  address_space       = var.aks_vnet_address_space
  location            = azurerm_resource_group.network.location
  resource_group_name = azurerm_resource_group.network.name
  tags                = local.common_tags
}

resource "azurerm_subnet" "aks_node" {
  name                 = "node-subnet"
  resource_group_name  = azurerm_resource_group.network.name
  virtual_network_name = azurerm_virtual_network.aks.name
  address_prefixes     = [var.aks_node_subnet_prefix]
}

resource "azurerm_subnet" "aks_pod" {
  name                 = "pod-subnet"
  resource_group_name  = azurerm_resource_group.network.name
  virtual_network_name = azurerm_virtual_network.aks.name
  address_prefixes     = [var.aks_pod_subnet_prefix]
}

resource "azurerm_subnet" "internal_lb" {
  name                 = "internal-lb-subnet"
  resource_group_name  = azurerm_resource_group.network.name
  virtual_network_name = azurerm_virtual_network.aks.name
  address_prefixes     = [var.internal_lb_subnet_prefix]
}

resource "azurerm_virtual_network" "db" {
  name                = var.db_vnet_name
  address_space       = var.db_vnet_address_space
  location            = azurerm_resource_group.network.location
  resource_group_name = azurerm_resource_group.network.name
  tags                = local.common_tags
}

resource "azurerm_subnet" "mysql" {
  name                 = "mysql-subnet"
  resource_group_name  = azurerm_resource_group.network.name
  virtual_network_name = azurerm_virtual_network.db.name
  address_prefixes     = [var.mysql_subnet_prefix]

  delegation {
    name = "mysql-flexible-server-delegation"

    service_delegation {
      name = "Microsoft.DBforMySQL/flexibleServers"
      actions = [
        "Microsoft.Network/virtualNetworks/subnets/join/action"
      ]
    }
  }
}

resource "azurerm_virtual_network_peering" "hub_to_aks" {
  name                      = "peer-hub-to-aks"
  resource_group_name       = azurerm_resource_group.network.name
  virtual_network_name      = azurerm_virtual_network.hub.name
  remote_virtual_network_id = azurerm_virtual_network.aks.id
}

resource "azurerm_virtual_network_peering" "aks_to_hub" {
  name                      = "peer-aks-to-hub"
  resource_group_name       = azurerm_resource_group.network.name
  virtual_network_name      = azurerm_virtual_network.aks.name
  remote_virtual_network_id = azurerm_virtual_network.hub.id
}

resource "azurerm_virtual_network_peering" "aks_to_db" {
  name                      = "peer-aks-to-db"
  resource_group_name       = azurerm_resource_group.network.name
  virtual_network_name      = azurerm_virtual_network.aks.name
  remote_virtual_network_id = azurerm_virtual_network.db.id
}

resource "azurerm_virtual_network_peering" "db_to_aks" {
  name                      = "peer-db-to-aks"
  resource_group_name       = azurerm_resource_group.network.name
  virtual_network_name      = azurerm_virtual_network.db.name
  remote_virtual_network_id = azurerm_virtual_network.aks.id
}

resource "azurerm_log_analytics_workspace" "main" {
  name                = var.log_analytics_workspace_name
  location            = azurerm_resource_group.shared.location
  resource_group_name = azurerm_resource_group.shared.name
  sku                 = "PerGB2018"
  retention_in_days   = 90
  tags                = local.common_tags
}

resource "azurerm_container_registry" "main" {
  name                = var.acr_name
  location            = azurerm_resource_group.aks.location
  resource_group_name = azurerm_resource_group.aks.name
  sku                 = "Standard"
  admin_enabled       = false
  tags                = local.common_tags
}

resource "azurerm_kubernetes_cluster" "aks" {
  name                = var.aks_cluster_name
  location            = azurerm_resource_group.aks.location
  resource_group_name = azurerm_resource_group.aks.name
  dns_prefix          = "kunlun-aks-prod"
  kubernetes_version  = var.kubernetes_version
  tags                = local.common_tags

  default_node_pool {
    name                 = "systemnp"
    vm_size              = var.aks_node_vm_size
    node_count           = var.system_node_count
    os_disk_size_gb      = var.aks_os_disk_size_gb
    vnet_subnet_id       = azurerm_subnet.aks_node.id
    pod_subnet_id        = azurerm_subnet.aks_pod.id
    type                 = "VirtualMachineScaleSets"
    orchestrator_version = var.kubernetes_version
  }

  identity {
    type = "SystemAssigned"
  }

  network_profile {
    network_plugin     = "azure"
    network_policy     = "azure"
    service_cidr       = var.aks_service_cidr
    dns_service_ip     = var.aks_dns_service_ip
    docker_bridge_cidr = var.aks_docker_bridge_cidr
    load_balancer_sku  = "standard"
  }

  oms_agent {
    log_analytics_workspace_id = azurerm_log_analytics_workspace.main.id
  }
}

resource "azurerm_kubernetes_cluster_node_pool" "user" {
  name                  = "usernp"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.aks.id
  vm_size               = var.aks_node_vm_size
  node_count            = var.user_node_count
  os_disk_size_gb       = var.aks_os_disk_size_gb
  vnet_subnet_id        = azurerm_subnet.aks_node.id
  pod_subnet_id         = azurerm_subnet.aks_pod.id
  mode                  = "User"
  orchestrator_version  = var.kubernetes_version
  tags                  = local.common_tags
}

resource "azurerm_role_assignment" "aks_acr_pull" {
  scope                = azurerm_container_registry.main.id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_kubernetes_cluster.aks.kubelet_identity[0].object_id
}

resource "kubernetes_namespace" "workloads" {
  for_each = toset(local.managed_namespaces)

  metadata {
    name = each.key
    labels = {
      customer    = "kunlun"
      environment = var.environment
    }
  }

  depends_on = [azurerm_kubernetes_cluster_node_pool.user]
}

resource "azurerm_private_dns_zone" "mysql" {
  name                = "privatelink.mysql.database.azure.com"
  resource_group_name = azurerm_resource_group.network.name
  tags                = local.common_tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "mysql_db" {
  name                  = "mysql-db-vnet-link"
  resource_group_name   = azurerm_resource_group.network.name
  private_dns_zone_name = azurerm_private_dns_zone.mysql.name
  virtual_network_id    = azurerm_virtual_network.db.id
  tags                  = local.common_tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "mysql_aks" {
  name                  = "mysql-aks-vnet-link"
  resource_group_name   = azurerm_resource_group.network.name
  private_dns_zone_name = azurerm_private_dns_zone.mysql.name
  virtual_network_id    = azurerm_virtual_network.aks.id
  tags                  = local.common_tags
}

resource "azurerm_mysql_flexible_server" "main" {
  name                   = var.mysql_server_name
  resource_group_name    = azurerm_resource_group.data.name
  location               = azurerm_resource_group.data.location
  administrator_login    = var.mysql_admin_username
  administrator_password = var.mysql_admin_password
  delegated_subnet_id    = azurerm_subnet.mysql.id
  private_dns_zone_id    = azurerm_private_dns_zone.mysql.id
  sku_name               = "GP_Standard_D4ds_v4"
  version                = "8.0.21"
  zone                   = "1"
  backup_retention_days  = 7
  tags                   = local.common_tags

  depends_on = [azurerm_private_dns_zone_virtual_network_link.mysql_db]
}

resource "azurerm_mysql_flexible_database" "app" {
  name                = var.mysql_database_name
  resource_group_name = azurerm_resource_group.data.name
  server_name         = azurerm_mysql_flexible_server.main.name
  charset             = "utf8mb4"
  collation           = "utf8mb4_unicode_ci"
}

resource "azurerm_storage_account" "main" {
  name                     = var.storage_account_name
  location                 = azurerm_resource_group.data.location
  resource_group_name      = azurerm_resource_group.data.name
  account_tier             = "Standard"
  account_replication_type = "LRS"
  min_tls_version          = "TLS1_2"
  tags                     = local.common_tags
}

resource "azurerm_storage_container" "object_files" {
  name                  = "object-files"
  storage_account_name  = azurerm_storage_account.main.name
  container_access_type = "private"
}

resource "azurerm_key_vault" "main" {
  name                       = var.key_vault_name
  location                   = azurerm_resource_group.shared.location
  resource_group_name        = azurerm_resource_group.shared.name
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  sku_name                   = "standard"
  soft_delete_retention_days = 7
  purge_protection_enabled   = true
  tags                       = local.common_tags
}

resource "azurerm_service_plan" "functions" {
  name                = var.function_plan_name
  location            = azurerm_resource_group.api.location
  resource_group_name = azurerm_resource_group.api.name
  os_type             = "Linux"
  sku_name            = "Y1"
  tags                = local.common_tags
}

resource "azurerm_linux_function_app" "main" {
  name                       = var.function_app_name
  location                   = azurerm_resource_group.api.location
  resource_group_name        = azurerm_resource_group.api.name
  service_plan_id            = azurerm_service_plan.functions.id
  storage_account_name       = azurerm_storage_account.main.name
  storage_account_access_key = azurerm_storage_account.main.primary_access_key
  https_only                 = true
  tags                       = local.common_tags

  identity {
    type = "SystemAssigned"
  }

  site_config {
    application_stack {
      python_version = "3.11"
    }
  }
}

resource "azurerm_api_management" "main" {
  name                = var.apim_name
  location            = azurerm_resource_group.api.location
  resource_group_name = azurerm_resource_group.api.name
  publisher_name      = "HONGKONG SAMYAK TECHNOLOGIES LIMITED"
  publisher_email     = "cloudops@samyakai.net"
  sku_name            = "Consumption_0"
  tags                = local.common_tags
}

resource "azurerm_search_service" "main" {
  name                = var.ai_search_name
  resource_group_name = azurerm_resource_group.ai.name
  location            = azurerm_resource_group.ai.location
  sku                 = "standard"
  replica_count       = 1
  partition_count     = 1
  tags                = local.common_tags
}

resource "azurerm_cognitive_account" "openai" {
  name                  = var.openai_account_name
  location              = azurerm_resource_group.ai.location
  resource_group_name   = azurerm_resource_group.ai.name
  kind                  = "OpenAI"
  sku_name              = "S0"
  custom_subdomain_name = var.openai_account_name
  tags                  = local.common_tags
}

