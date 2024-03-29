# ------------------
# General
# ------------------
variable "resource_group_name" {
  type        = string
  description = "The resource group name for the AKS Cluster"
}

variable "location" {
  type        = string
  description = "Location (Azure Region) that will be used for resources"
}

variable "prefix" {
  type        = string
  description = "The prefix for the resources created in the specified Azure Resource Group"
}

variable "environment" {
  type        = string
  description = "The environment name that will be used for tagging"
}

variable "color" {
  type        = string
  default     = ""
  description = "(optional) The color of the environment"
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Any tags that should be present on the resources"
}

# ------------------
# AKS
# ------------------
variable "kubernetes_version" {
  type        = string
  default     = "1.23.12" // The old version is not available in the Westeurope region
  description = "Version of Kubernetes to install"
}

variable "outbound_ip_address_ids" {
  type        = list(string)
  description = "IDs of the public IP(s) for egress"
}

variable "min_count" {
  default     = 2
  description = "The minimum number of Agents that should exist in the Agent Pool"
}

variable "max_count" {
  default     = 4
  description = "The maximum number of Agents that should exist in the Agent Pool"
}

variable "vm_size" {
  type        = string
  description = "The Azure VM Size of the Virtual Machines used in the Agent Pool"
}

variable "node_disk_size_gb" {
  description = "The Azure AKS node disk size in GB"
  default     = 30
}

variable "vnet_subnet_id" {
  description = "Subnet Id of the Kubernetes default node pool"
}

variable "availability_zones" {
  type        = list(string)
  description = "AKS Availability Zones"
  default     = ["1", "2", "3"]
}

variable "cluster_user_roles" {
  description = "Cluster user Permissions"
  default = {
    acr    = ["AcrPull"]
    aks    = ["Azure Kubernetes Service Cluster User Role"]
    env_rg = ["Reader"]
  }
}

variable "log_analytics_workspace_id" {
  type        = string
  description = "Log Analytics Workspace ID generated by base script"
}

variable "log_retention_days" {
  type        = number
  default     = 60
  description = "Days how long the diagnostic settings should be set"
}

variable "admin_group_object_ids" {
  type        = list(string)
  default     = []
  description = "A list of Object IDs of Azure Active Directory Groups which should have Admin Role on the Cluster."
}

variable "api_server_authorized_ip_ranges" {
  type        = list(string)
  default     = []
  description = "The IP ranges to whitelist for incoming traffic to the masters."
}

variable "helm_service_principal_object_id" {
  type        = string
  description = "Helm service principle object id which should be able to deploy to aks"
}

variable "container_registry_id" {
  type        = string
  description = "Container registry id where aks images should be pulled from"
}

variable "key_vault_id" {
  type        = string
  description = "Key vault id where aks should pull secrets from"
}

variable "resource_group_network" {
  description = "Ressource groupe of the network groups"
}

variable "action_group_id" {
  type        = string
  description = "The ID of the Action Group can be sourced from the azurerm_monitor_action_group resource"
}