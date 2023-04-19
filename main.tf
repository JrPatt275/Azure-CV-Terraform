resource "azurerm_resource_group" "rg" {
  location = var.resource_group_location
  name     = "jrpazurecv${var.resource_group_name_suffix}"
  tags = var.tags
}

resource "azurerm_storage_account" "storage" {
  account_replication_type = "LRS"
  account_tier = "Standard"
  account_kind = "StorageV2"
  location = var.resource_group_location
  name = var.storage_account_name
  resource_group_name = azurerm_resource_group.rg.name
  static_website {
    index_document = "index.html"
  }
  tags = var.tags
}

resource "azurerm_storage_blob" "index" {
  name = "index.html"
  storage_account_name = azurerm_storage_account.storage.name
  storage_container_name = "$web"
  type = "Block"
  content_type = "text/html"
  source = "index.html"
}

resource "azurerm_app_service_plan" "appserviceplan" {
  location = var.resource_group_location
  name = var.app_service_name
  resource_group_name = azurerm_resource_group.rg.name
  kind = "FunctionApp"
  sku {
    size = "Y1"
    tier = "Dynamic"
  }
  tags = var.tags
}

resource "azurerm_function_app" "functionapp" {
  app_service_plan_id = azurerm_app_service_plan.appserviceplan.id
  storage_account_name = azurerm_storage_account.storage.name
  storage_account_access_key = azurerm_storage_account.storage.primary_access_key
  location = azurerm_app_service_plan.appserviceplan.location
  name = var.function_app_name
  resource_group_name = azurerm_resource_group.rg.name
  tags = var.tags
}

resource "azurerm_cosmosdb_account" "cosmos" {
  location = var.resource_group_location
  name = var.database_name
  offer_type = "Standard"
  resource_group_name = azurerm_resource_group.rg.name
  kind = "GlobalDocumentDB"
  enable_automatic_failover = false
  enable_free_tier = true
  
  consistency_policy {
    consistency_level = "BoundedStaleness"
    max_interval_in_seconds = 300
    max_staleness_prefix = 100000
  }
  geo_location {
    failover_priority = 0
    location = var.resource_group_location
  }
  depends_on = [
    azurerm_resource_group.rg
  ]
}

resource "azurerm_cosmosdb_table" "table" {
  account_name = azurerm_cosmosdb_account.cosmos.name
  name = var.table_name
  resource_group_name = azurerm_resource_group.rg.name
  
}