resource "azurerm_kubernetes_cluster" "this" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  dns_prefix          = var.dns_prefix
  tags                = var.tags

  default_node_pool {
    name                         = var.default_node_pool.name
    node_count                   = var.default_node_pool.node_count
    vm_size                      = var.default_node_pool.vm_size
    vnet_subnet_id               = var.default_node_pool.vnet_subnet_id
    only_critical_addons_enabled = var.default_node_pool.only_critical_addons_enabled
  }

  network_profile {
    network_plugin = var.network_profile.network_plugin
    service_cidr   = var.network_profile.service_cidr
    dns_service_ip = var.network_profile.dns_service_ip
  }

  identity {
    type = var.identity_type
  }

  oidc_issuer_enabled       = var.oidc_issuer_enabled
  workload_identity_enabled = var.workload_identity_enabled
}

resource "azurerm_kubernetes_cluster_node_pool" "this" {
  for_each = var.user_node_pools

  name                  = each.value.name
  kubernetes_cluster_id = azurerm_kubernetes_cluster.this.id
  vm_size               = each.value.vm_size
  mode                  = each.value.mode
  vnet_subnet_id        = each.value.vnet_subnet_id
  priority              = each.value.priority
  eviction_policy       = each.value.eviction_policy
  spot_max_price        = each.value.spot_max_price

  enable_auto_scaling = each.value.enable_auto_scaling
  min_count           = each.value.min_count
  max_count           = each.value.max_count
  node_count          = each.value.node_count

  node_labels = each.value.node_labels
  node_taints = each.value.node_taints
}
