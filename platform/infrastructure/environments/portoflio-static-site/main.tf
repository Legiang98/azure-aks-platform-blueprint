locals {
  tags = var.tags
}

module "resource_group" {
  source = "../../modules/resource-group"

  name     = var.resource_group_name
  location = var.location
  tags     = local.tags
}

module "static_web_app" {
  source = "../../modules/static-web-app"

  name                = var.static_web_app_name
  resource_group_name = module.resource_group.name
  location            = var.static_web_app_location
  sku_tier            = var.static_web_app_sku_tier
  sku_size            = var.static_web_app_sku_size
  tags                = local.tags
}
