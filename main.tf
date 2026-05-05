locals {
  region_map = {
    "polandcentral" = "pl"
  }

  reg = lookup(local.region_map, var.region, "null")



  subnets_vars = flatten([
    for vnet_name, vnet_address in var.vnets :
    [

      for i in range(1, 4) : {
        vnet_key  = vnet_name
        sub_index = i
        vnet_name = "vnet-${local.reg}-${vnet_name}"

        sub_name = "snet-${local.reg}-${vnet_name}-${i}"

        address = cidrsubnet(vnet_address, 8, i)
      }
    ]
  ])

  subnets_map = {
    for s in local.subnets_vars :
    "${s.vnet_name}-${s.sub_index}" => s
  }


}


resource "azurerm_resource_group" "rg" {
  name     = "rg-test-szymon"
  location = var.region
}

resource "azurerm_virtual_network" "vnet" {
  for_each            = var.vnets
  name                = "vnet-${local.reg}-${each.key}"
  address_space       = [each.value]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_subnet" "subnet" {
  for_each = local.subnets_map

  name                = each.value.sub_name
  resource_group_name = azurerm_resource_group.rg.name

  virtual_network_name = azurerm_virtual_network.vnet[each.value.vnet_key].name

  address_prefixes = [each.value.address]
}

resource "azurerm_network_security_group" "nsg" {
  for_each = local.subnets_map

  name = "nsg-${each.value.sub_name}"

  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name


}

resource "azurerm_route_table" "rt" {
  for_each = local.subnets_map

  name = "rt-${each.value.sub_name}"

  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_subnet_network_security_group_association" "nsg_assoc" {
  for_each = local.subnets_map

  subnet_id = azurerm_subnet.subnet[each.key].id

  network_security_group_id = azurerm_network_security_group.nsg[each.key].id

}

resource "azurerm_subnet_route_table_association" "rt_assoc" {
  for_each = local.subnets_map

  subnet_id = azurerm_subnet.subnet[each.key].id

  route_table_id = azurerm_route_table.rt[each.key].id

}