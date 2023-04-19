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

resource "azurerm_cdn_profile" "cdnprofile" {
  location = "westeurope"
  name = var.cdn_profile_name
  resource_group_name = azurerm_resource_group.rg.name
  sku = var.cdn_sku
}

locals {
  temp = trimprefix(azurerm_storage_account.storage.primary_web_endpoint, "https://")
  originurl = trimsuffix(local.temp, "/")
}
resource "azurerm_cdn_endpoint" "endpoint" {
  location = "westeurope"
  name = "jrpcvendpoint"
  profile_name = azurerm_cdn_profile.cdnprofile.name
  resource_group_name = azurerm_resource_group.rg.name
  origin_host_header = local.originurl
  is_https_allowed = true
  origin {
    host_name = local.originurl
    name = "jrpcvendpointorigin"
  }
  
}

resource "azurerm_cdn_endpoint_custom_domain" "domain" {
  cdn_endpoint_id = azurerm_cdn_endpoint.endpoint.id
  host_name = var.custom_domain
  name = var.custom_domain
  cdn_managed_https {
    certificate_type = "Shared"
    protocol_type = "ServerNameIndication"
  }
  depends_on = [
    azurerm_cdn_profile.cdnprofile,
    azurerm_cdn_endpoint.endpoint
  ]
}
resource "azurerm_service_plan" "appserviceplan" {
  location = var.resource_group_location
  name = var.app_service_name
  resource_group_name = azurerm_resource_group.rg.name
  os_type = "Windows"
  sku_name = "Y1"
  tags = var.tags
}

resource "azurerm_windows_function_app" "functionapp" {
  service_plan_id = azurerm_service_plan.appserviceplan.id
  storage_account_name = azurerm_storage_account.storage.name
  storage_account_access_key = azurerm_storage_account.storage.primary_access_key
  location = azurerm_service_plan.appserviceplan.location
  name = var.function_app_name
  resource_group_name = azurerm_resource_group.rg.name
  site_config { }
  tags = var.tags
}

resource "azurerm_function_app_function" "pythonfunction" {
  function_app_id = azurerm_windows_function_app.functionapp.id
  name = var.function_name
  language = "Python"

  file {
    name = "increment.py"
    content = file("increment.py")
  }

  config_json = jsonencode({
    "bindings" = [
      {
      "authLevel" = "function"
      "direction" = "in"
      "methods" = [
        "get",
        "post",
      ]
      "name" = "req"
      "type" = "httpTrigger"
      },
      {
        "direction" = "out"
        "name" = "$return"
        "type" = "http"
      },
    ]
  })
}