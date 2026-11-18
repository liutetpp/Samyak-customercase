variable "location" {
  type        = string
  description = "Azure region for KUNLUN production resources."
  default     = "Australia East"
}

variable "environment" {
  type        = string
  description = "Environment name."
  default     = "prod"
}

variable "project_prefix" {
  type        = string
  description = "Short resource prefix."
  default     = "kunlun"
}

variable "resource_group_names" {
  type = object({
    network = string
    aks     = string
    data    = string
    ai      = string
    api     = string
    shared  = string
  })

  default = {
    network = "rg-kunlun-network-prod-aue-001"
    aks     = "rg-kunlun-aks-prod-aue-001"
    data    = "rg-kunlun-data-prod-aue-001"
    ai      = "rg-kunlun-ai-prod-aue-001"
    api     = "rg-kunlun-api-prod-aue-001"
    shared  = "rg-kunlun-shared-prod-aue-001"
  }
}

variable "hub_vnet_name" {
  type    = string
  default = "kunlun-hub-vnet-prod-aue-001"
}

variable "hub_vnet_address_space" {
  type    = list(string)
  default = ["10.8.45.0/24"]
}

variable "nfs_subnet_prefix" {
  type        = string
  description = "Hub shared-services or transition subnet."
  default     = "10.8.45.32/28"
}

variable "aks_vnet_name" {
  type    = string
  default = "kunlun-aks-vnet-prod-aue-001"
}

variable "aks_vnet_address_space" {
  type    = list(string)
  default = ["10.8.16.0/20", "172.24.0.0/20"]
}

variable "aks_service_cidr" {
  type    = string
  default = "192.168.6.0/22"
}

variable "aks_dns_service_ip" {
  type    = string
  default = "192.168.6.10"
}

variable "aks_docker_bridge_cidr" {
  type    = string
  default = "172.17.0.1/16"
}

variable "aks_node_subnet_prefix" {
  type    = string
  default = "10.8.16.0/22"
}

variable "aks_pod_subnet_prefix" {
  type    = string
  default = "172.24.0.0/20"
}

variable "internal_lb_subnet_prefix" {
  type    = string
  default = "10.8.35.0/24"
}

variable "db_vnet_name" {
  type    = string
  default = "kunlun-db-vnet-prod-aue-001"
}

variable "db_vnet_address_space" {
  type    = list(string)
  default = ["10.8.28.0/24"]
}

variable "mysql_subnet_prefix" {
  type    = string
  default = "10.8.28.0/24"
}

variable "aks_cluster_name" {
  type    = string
  default = "kunlun-aks-prod-aue-001"
}

variable "kubernetes_version" {
  type    = string
  default = "1.30"
}

variable "aks_node_vm_size" {
  type    = string
  default = "Standard_B8ms"
}

variable "system_node_count" {
  type    = number
  default = 3
}

variable "user_node_count" {
  type    = number
  default = 8
}

variable "aks_os_disk_size_gb" {
  type    = number
  default = 256
}

variable "acr_name" {
  type        = string
  description = "ACR name must be globally unique and contain only alphanumeric characters."
  default     = "kunlunacrpraue001"
}

variable "log_analytics_workspace_name" {
  type    = string
  default = "kunlun-law-prod-aue-001"
}

variable "key_vault_name" {
  type        = string
  description = "Key Vault name must be globally unique."
  default     = "kunlun-kv-prod-aue-001"
}

variable "storage_account_name" {
  type        = string
  description = "Storage account name must be globally unique and lowercase."
  default     = "kunlunstprodaue001"
}

variable "mysql_server_name" {
  type        = string
  description = "MySQL Flexible Server name must be globally unique."
  default     = "kunlun-mysql-prod-aue-001"
}

variable "mysql_database_name" {
  type    = string
  default = "kunlun_content_platform"
}

variable "mysql_admin_username" {
  type        = string
  description = "MySQL administrator login name."
  default     = "kunlunadmin"
}

variable "mysql_admin_password" {
  type        = string
  description = "MySQL administrator password. Use terraform.tfvars or environment variables in real deployments."
  sensitive   = true
}

variable "apim_name" {
  type    = string
  default = "kunlun-apim-prod-aue-001"
}

variable "function_plan_name" {
  type    = string
  default = "kunlun-func-plan-prod-aue-001"
}

variable "function_app_name" {
  type        = string
  description = "Function App name must be globally unique."
  default     = "kunlun-functions-prod-aue-001"
}

variable "openai_account_name" {
  type        = string
  description = "Azure OpenAI account name."
  default     = "kunlun-openai-prod-aue-001"
}

variable "ai_search_name" {
  type        = string
  description = "Azure AI Search service name."
  default     = "kunlun-search-prod-aue-001"
}

variable "ai_foundry_project_name" {
  type        = string
  description = "Logical Azure AI Foundry project name documented for the implementation."
  default     = "kunlun-aifoundry-prod-aue-001"
}
