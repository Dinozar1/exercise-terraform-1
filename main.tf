resource "azurerm_resource_group" "rg" {
  name     = "rg-test-szymon"
  location = var.region
}

module "net_1" {
  source = "./modules/network"

  region  = azurerm_resource_group.rg.location
  rg_name = azurerm_resource_group.rg.name

  vnets_map = var.vnet1

  subnet_count = 3


}

module "net_2" {
  source = "./modules/network"

  region  = azurerm_resource_group.rg.location
  rg_name = azurerm_resource_group.rg.name

  vnets_map = var.vnet2

  subnet_count = 1

}

locals {
  hub_vnet = values(module.net_2.created_vnets)[0]
}

resource "azurerm_virtual_network_peering" "peer_spoke" {
  for_each = module.net_1.created_vnets

  name = "peer-${each.value.name}-to-hub"

  virtual_network_name      = each.value.name
  resource_group_name       = azurerm_resource_group.rg.name
  remote_virtual_network_id = local.hub_vnet.id
}

resource "azurerm_virtual_network_peering" "peer_hub" {
  for_each = module.net_1.created_vnets

  name = "peer-hub-to-${each.value.name}"

  virtual_network_name      = local.hub_vnet.name
  resource_group_name       = azurerm_resource_group.rg.name
  remote_virtual_network_id = each.value.id
}