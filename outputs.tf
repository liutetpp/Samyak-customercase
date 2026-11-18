output "resource_groups" {
  value = {
    network = azurerm_resource_group.network.name
    aks     = azurerm_resource_group.aks.name
    data    = azurerm_resource_group.data.name
    ai      = azurerm_resource_group.ai.name
    api     = azurerm_resource_group.api.name
    shared  = azurerm_resource_group.shared.name
  }
}

output "network_plan" {
  value = {
    hub_vnet        = azurerm_virtual_network.hub.address_space
    nfs_subnet      = azurerm_subnet.nfs.address_prefixes
    aks_vnet        = azurerm_virtual_network.aks.address_space
    service_cidr    = var.aks_service_cidr
    pod_subnet      = azurerm_subnet.aks_pod.address_prefixes
    node_subnet     = azurerm_subnet.aks_node.address_prefixes
    internal_lb     = azurerm_subnet.internal_lb.address_prefixes
    mysql_subnet    = azurerm_subnet.mysql.address_prefixes
  }
}

output "aks_cluster_name" {
  value = azurerm_kubernetes_cluster.aks.name
}

output "container_registry_name" {
  value = azurerm_container_registry.main.name
}

output "mysql_server_fqdn" {
  value = azurerm_mysql_flexible_server.main.fqdn
}

output "api_management_gateway_url" {
  value = azurerm_api_management.main.gateway_url
}

output "function_app_default_hostname" {
  value = azurerm_linux_function_app.main.default_hostname
}

output "azure_openai_endpoint" {
  value = azurerm_cognitive_account.openai.endpoint
}

output "azure_ai_search_service" {
  value = azurerm_search_service.main.name
}

output "azure_ai_foundry_project_name" {
  value = var.ai_foundry_project_name
}

output "log_analytics_workspace_id" {
  value = azurerm_log_analytics_workspace.main.workspace_id
}

output "managed_namespaces" {
  value = keys(kubernetes_namespace.workloads)
}
