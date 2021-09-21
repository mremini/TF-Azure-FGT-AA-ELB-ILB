//############################ Resource Group ############################

resource "azurerm_resource_group" "rg" {
  name     = "${var.TAG}-${var.project}"
  location = var.loc

  tags = {
    Project = "${var.project}"
  }
}

//############################ Create VNET  ############################

resource "azurerm_virtual_network" "vnet" {
  name                = "${var.TAG}-${var.project}-hub-${var.loc}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = var.hubvnetcidr

  tags = {
    Project = "${var.project}"
  }
}

//############################ Create VNET Subnets ############################

resource "azurerm_subnet" "subnets" {
  for_each = var.hubvnetsubnets

  name                 = (each.value.name == "RouteServerSubnet" ? each.value.name : "${var.TAG}-${var.project}-subnet-${each.value.name}")
  resource_group_name  = azurerm_resource_group.rg.name
  address_prefixes     = [each.value.cidr]
  virtual_network_name = azurerm_virtual_network.vnet.name

}

//############################  Route Tables ############################
resource "azurerm_route_table" "vnet_route_tables" {
  for_each = var.hubvnetroutetables

  name                = "${var.TAG}-${var.project}-${each.value.name}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  //disable_bgp_route_propagation = false
  tags = {
    Project = "${var.project}"
  }
}

//############################  RT Associations ############################
resource "azurerm_subnet_route_table_association" "vnet_rt_assoc" {
  for_each = var.hubvnetroutetables

  subnet_id = azurerm_subnet.subnets[each.key].id
  #subnet_id      = data.azurerm_subnet.pub_subnet.id
  route_table_id = azurerm_route_table.vnet_route_tables[each.key].id
}

//############################  RT Default Routes ############################
resource "azurerm_route" "vnet_fgt_pub_rt_default" {
  name                = "defaultInternet"
  resource_group_name = azurerm_resource_group.rg.name
  route_table_name    = azurerm_route_table.vnet_route_tables["fgt_public"].name
  address_prefix      = "0.0.0.0/0"
  next_hop_type       = "Internet"
}

//############################  Ext LB ############################

resource "azurerm_public_ip" "elbpip" {
  name                = "${var.TAG}-${var.project}-PublicIP"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku = "Standard"

  tags = {
    Project = "${var.project}"
  }

}

resource "azurerm_lb" "elb" {
  name                = "${var.TAG}-${var.project}-elb"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "Standard"

  frontend_ip_configuration {
    name                 = "${var.TAG}-${var.project}-elbpip"
    public_ip_address_id = azurerm_public_ip.elbpip.id
  }
}

resource "azurerm_lb_backend_address_pool" "elbbackend" {
  resource_group_name = azurerm_resource_group.rg.name
  loadbalancer_id     = azurerm_lb.elb.id
  name                = "FGT-AA"
}

resource "azurerm_lb_probe" "elbprobe" {
  resource_group_name = azurerm_resource_group.rg.name
  loadbalancer_id     = azurerm_lb.elb.id
  name                = "fgt-lbprobe"
  port                = var.elbprob
}

resource "azurerm_lb_outbound_rule" "elbfgtaaoutbound" {
  resource_group_name = azurerm_resource_group.rg.name
  loadbalancer_id     = azurerm_lb.elb.id
  name                    = "fgt-aa-outbound"
  protocol                = "All"
  backend_address_pool_id = azurerm_lb_backend_address_pool.elbbackend.id

  frontend_ip_configuration {
    name = "${var.TAG}-${var.project}-elbpip"
  }
}


resource "azurerm_lb_nat_rule" "fgttfaccess" {
  resource_group_name = azurerm_resource_group.rg.name
  loadbalancer_id     = azurerm_lb.elb.id
  name                           = "TFAccess"
  protocol                       = "Tcp"
  frontend_port                  = 443
  backend_port                   = 34443
  frontend_ip_configuration_name = "${var.TAG}-${var.project}-elbpip"
}

resource "azurerm_network_interface_nat_rule_association" "fgtmastertfaccess" {
  network_interface_id  = azurerm_network_interface.dut1nics["nic1"].id
  ip_configuration_name = "ipconfig1"
  nat_rule_id           = azurerm_lb_nat_rule.fgttfaccess.id
}

//############################  Int LB ############################

resource "azurerm_lb" "ilb" {
  name                = "${var.TAG}-${var.project}-ilb"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "Standard"


  frontend_ip_configuration {
    name                          = "${var.TAG}-${var.project}-ilbpip"
    subnet_id                     = azurerm_subnet.subnets["fgt_private"].id
    private_ip_address            = var.ilbip
    private_ip_address_allocation = "Static"
  }
}

resource "azurerm_lb_backend_address_pool" "ilbbackend" {
  resource_group_name = azurerm_resource_group.rg.name
  loadbalancer_id     = azurerm_lb.ilb.id
  name                = "FGT-AA"
}

resource "azurerm_lb_probe" "ilbprobe" {
  resource_group_name = azurerm_resource_group.rg.name
  loadbalancer_id     = azurerm_lb.ilb.id
  name                = "fgt-lbprobe"
  port                = var.ilbprob
}

resource "azurerm_lb_rule" "lb_haports_rule" {
  resource_group_name = azurerm_resource_group.rg.name
  loadbalancer_id     = azurerm_lb.ilb.id
  name                           = "FGT-AA-haports"
  protocol                       = "All"
  frontend_port                  = 0
  backend_port                   = 0
  frontend_ip_configuration_name = "${var.TAG}-${var.project}-ilbpip"
  probe_id                       = azurerm_lb_probe.ilbprobe.id
  backend_address_pool_id        = azurerm_lb_backend_address_pool.ilbbackend.id
}

//############################  ARS PIP ############################

resource "azurerm_public_ip" "arspip" {
  name                = "${var.TAG}-${var.project}-ARS-PublicIP"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku = "Standard"

  tags = {
    Project = "${var.project}"
  }

}