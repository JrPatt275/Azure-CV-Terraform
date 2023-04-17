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
