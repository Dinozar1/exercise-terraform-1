resource "azurerm_resource_group" "rg" {
  name     = "rg-test-szymon"
  location = var.region
}

module "net_1" {
    source = "./modules/network"

    region = azurerm_resource_group.rg.location
    rg_name = azurerm_resource_group.rg.name

    vnets = var.vnet1.default


}

module "net_2" {
    source = "./modules/network"

    region = azurerm_resource_group.rg.location
    rg_name = azurerm_resource_group.rg.name

    vnets = var.vnet2.default
    
}

locals {
    hub_vnet = values(module.net_2.vnets)[0]
}

resource "azure_virtual_network_peering" "peer" {
    for_each module.net_1.vnets

    name = "peer-${each.value.name}"
    resource_group_name = azurerm_resource_group.rg.name
    remote_virtual_network_id = local.hub_vnet.id
}