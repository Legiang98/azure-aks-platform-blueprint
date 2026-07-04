output "resource_group_name" {
  description = "Portfolio Static Web App resource group name."
  value       = module.resource_group.name
}

output "static_web_app_name" {
  description = "Static Web App name."
  value       = module.static_web_app.name
}

output "static_web_app_default_host_name" {
  description = "Default Static Web App hostname."
  value       = module.static_web_app.default_host_name
}
