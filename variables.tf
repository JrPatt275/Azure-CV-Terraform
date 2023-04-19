variable "resource_group_location" {
  default     = "uksouth"
  description = "Location of the resource group."
}

variable "resource_group_name_suffix" {
  default     = "rg"
  description = "Suffix of the resource group name that's combined with a random ID so name is unique in your Azure subscription."
}

variable "storage_account_name" {
  default = "jrpcvstorageaccount"
  description = "Name of the storage account"
}

variable "app_service_name" {
  default = "jrpcvappserviceplan"
  description = "Name of the app service plan"
}

variable "function_app_name" {
  default = "jrpcvfunctionapp"
  description = "Name of the function app"
}

variable "tags" {
  type = map
  default = {
    source = "Terraform"
    deployment = "Terraform Cloud"
    purpose = "Azure CV"
  }
}

variable "database_name" {
  default = "jrpcvcosmosdb"
  description = "Name of the CosmosDB"
}