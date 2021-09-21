//############################ Create VNET  ############################

resource "azurerm_virtual_network" "spokevnet" {
  name                = "${var.TAG}-${var.project}-spoke-${var.loc}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = var.spokevnetcidr

  tags = {
    Project = "${var.project}"
  }
}

//############################ Create VNET Subnets ############################

resource "azurerm_subnet" "spokesubnets" {
  for_each = var.spokevnetsubnets

  name                 = "${var.TAG}-${var.project}-subnet-${each.value.name}"
  resource_group_name  = azurerm_resource_group.rg.name
  address_prefixes     = [each.value.cidr]
  virtual_network_name = azurerm_virtual_network.spokevnet.name

}

//############################  Route Tables ############################
resource "azurerm_route_table" "spoke_vnet_route_tables" {
  for_each = var.spokevnetroutetables

  name                = "${var.TAG}-${var.project}-${each.value.name}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  //disable_bgp_route_propagation = false
  tags = {
    Project = "${var.project}"
  }
}

//############################  RT Associations ############################
resource "azurerm_subnet_route_table_association" "spoke_vnet_rt_assoc" {
  for_each = var.spokevnetroutetables

  subnet_id = azurerm_subnet.spokesubnets[each.key].id
  #subnet_id      = data.azurerm_subnet.pub_subnet.id
  route_table_id = azurerm_route_table.spoke_vnet_route_tables[each.key].id
}

//############################  RT Default Routes ############################
resource "azurerm_route" "vnet_k8s_node_rt_default" {
  name                   = "default"
  resource_group_name    = azurerm_resource_group.rg.name
  route_table_name       = azurerm_route_table.spoke_vnet_route_tables["K8s_nodes"].name
  address_prefix         = "0.0.0.0/0"
  next_hop_type          = "VirtualAppliance"
  next_hop_in_ip_address = var.ilbip
}

