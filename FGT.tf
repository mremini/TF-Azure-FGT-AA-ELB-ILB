//############################ NIC  ############################

resource "azurerm_network_interface" "dut1nics" {
  for_each                      = var.dut1
  name                          = "${each.value.vmname}-${each.value.name}"
  location                      = azurerm_resource_group.rg.location
  resource_group_name           = azurerm_resource_group.rg.name
  enable_ip_forwarding          = true
  enable_accelerated_networking = true

  ip_configuration {
    name      = "ipconfig1"
    subnet_id = azurerm_subnet.subnets[each.value.subnet].id
    #subnet_id                     = data.azurerm_subnet.dut1subnetid[each.key].id
    private_ip_address_allocation = "static"
    private_ip_address            = each.value.ip
    #public_ip_address_id          = (each.value.name == "port1" ? azurerm_public_ip.FGTPublicIp.id : null)
  }
}

resource "azurerm_network_interface" "dut2nics" {
  for_each                      = var.dut2
  name                          = "${each.value.vmname}-${each.value.name}"
  location                      = azurerm_resource_group.rg.location
  resource_group_name           = azurerm_resource_group.rg.name
  enable_ip_forwarding          = true
  enable_accelerated_networking = true

  ip_configuration {
    name      = "ipconfig1"
    subnet_id = azurerm_subnet.subnets[each.value.subnet].id
    #subnet_id                     = data.azurerm_subnet.dut1subnetid[each.key].id
    private_ip_address_allocation = "static"
    private_ip_address            = each.value.ip
    #public_ip_address_id          = (each.value.name == "port1" ? azurerm_public_ip.FGTPublicIp.id : null)
  }
}

resource "azurerm_network_interface" "dut3nics" {
  for_each                      = var.dut3
  name                          = "${each.value.vmname}-${each.value.name}"
  location                      = azurerm_resource_group.rg.location
  resource_group_name           = azurerm_resource_group.rg.name
  enable_ip_forwarding          = true
  enable_accelerated_networking = true

  ip_configuration {
    name      = "ipconfig1"
    subnet_id = azurerm_subnet.subnets[each.value.subnet].id
    #subnet_id                     = data.azurerm_subnet.dut1subnetid[each.key].id
    private_ip_address_allocation = "static"
    private_ip_address            = each.value.ip
    #public_ip_address_id          = (each.value.name == "port1" ? azurerm_public_ip.FGTPublicIp.id : null)
  }
}

//############################  FGT NSGs ##################

resource "azurerm_network_security_group" "fgt_nsgs" {
  for_each = var.hubnsgs

  name                = "${var.TAG}-${var.project}-${each.value.name}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_network_security_rule" "fgt_nsg_rules" {
  for_each = var.hubnsgrules

  name                        = each.value.rulename
  resource_group_name         = azurerm_resource_group.rg.name
  network_security_group_name = azurerm_network_security_group.fgt_nsgs[each.value.nsgname].name
  priority                    = each.value.priority
  direction                   = each.value.direction
  access                      = each.value.access
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"

}



//############################ NIC to NSG  ############################


resource "azurerm_network_interface_security_group_association" "dut1nsg" {
  for_each = var.dut1
  network_interface_id      = azurerm_network_interface.dut1nics[each.key].id
  network_security_group_id = azurerm_network_security_group.fgt_nsgs[each.value.nsgname].id
}

resource "azurerm_network_interface_security_group_association" "dut2nsg" {
  for_each = var.dut2
  network_interface_id      = azurerm_network_interface.dut2nics[each.key].id
  network_security_group_id = azurerm_network_security_group.fgt_nsgs[each.value.nsgname].id
}

resource "azurerm_network_interface_security_group_association" "dut3nsg" {
  for_each = var.dut3
  network_interface_id      = azurerm_network_interface.dut3nics[each.key].id
  network_security_group_id = azurerm_network_security_group.fgt_nsgs[each.value.nsgname].id
}



//############################ NIC to POOL  ############################


resource "azurerm_network_interface_backend_address_pool_association" "dut1elb" {
  network_interface_id    = azurerm_network_interface.dut1nics["nic1"].id
  ip_configuration_name   = "ipconfig1"
  backend_address_pool_id = azurerm_lb_backend_address_pool.elbbackend.id
}

resource "azurerm_network_interface_backend_address_pool_association" "dut2elb" {
  network_interface_id    = azurerm_network_interface.dut2nics["nic1"].id
  ip_configuration_name   = "ipconfig1"
  backend_address_pool_id = azurerm_lb_backend_address_pool.elbbackend.id
}

resource "azurerm_network_interface_backend_address_pool_association" "dut3elb" {
  network_interface_id    = azurerm_network_interface.dut3nics["nic1"].id
  ip_configuration_name   = "ipconfig1"
  backend_address_pool_id = azurerm_lb_backend_address_pool.elbbackend.id
}


resource "azurerm_network_interface_backend_address_pool_association" "dut1ilb" {
  network_interface_id    = azurerm_network_interface.dut1nics["nic2"].id
  ip_configuration_name   = "ipconfig1"
  backend_address_pool_id = azurerm_lb_backend_address_pool.ilbbackend.id
}

resource "azurerm_network_interface_backend_address_pool_association" "dut2ilb" {
  network_interface_id    = azurerm_network_interface.dut2nics["nic2"].id
  ip_configuration_name   = "ipconfig1"
  backend_address_pool_id = azurerm_lb_backend_address_pool.ilbbackend.id
}
resource "azurerm_network_interface_backend_address_pool_association" "dut3ilb" {
  network_interface_id    = azurerm_network_interface.dut3nics["nic2"].id
  ip_configuration_name   = "ipconfig1"
  backend_address_pool_id = azurerm_lb_backend_address_pool.ilbbackend.id
}


////////////////////////////////////////DUT1//////////////////////////////
data "template_file" "dut1_customdata" {
  template = file ("./assets/fgt-aa-userdata.tpl")
  vars = {
    fgt_id              = element ( values(var.dut1)[*].vmname , 0)
    fgt_license_file    = "./assets/lic/fgt1.lic"
    fgt_username        = var.username
    fgt_config_ha       = false
    fgt_config_autoscale = true
    fgt_config_probe = true
    role = "primary"
    masterip = ""
    sync-port = "port1"
    psk = var.password

    fgt_ssh_public_key  = ""

    fgt_port1_gw     = cidrhost (element(azurerm_subnet.subnets["fgt_public"].address_prefixes , 0 ), 1) 
    fgt_port2_gw     = cidrhost (element(azurerm_subnet.subnets["fgt_private"].address_prefixes , 0 ), 1) 

  }
}

resource "azurerm_virtual_machine" "dut1" {
  name                         = "${var.TAG}-${var.project}-fgt1"
  location                      = azurerm_resource_group.rg.location
  resource_group_name           = azurerm_resource_group.rg.name
  network_interface_ids        =  [for nic in azurerm_network_interface.dut1nics: nic.id ]
  primary_network_interface_id = element ( values(azurerm_network_interface.dut1nics)[*].id , 0)
  vm_size                      = var.dut_vmsize

  identity {
    type = "SystemAssigned"
  }

  storage_image_reference {
    publisher = "fortinet"
    offer     = var.FGT_OFFER
    sku       = var.FGT_IMAGE_SKU
    version   = var.FGT_VERSION
  }

  plan {
    publisher = "fortinet"
    product   = var.FGT_OFFER
    name      = var.FGT_IMAGE_SKU
  }

  storage_os_disk {
    name              = "${var.TAG}-${var.project}-fgt1_OSDisk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  storage_data_disk {
    name = "${var.TAG}-${var.project}-fgt1_DataDisk"
    managed_disk_type = "Premium_LRS"
    create_option = "Empty"
    lun = 0
    disk_size_gb = "20"
  }
  os_profile {
    computer_name  = "${var.TAG}-${var.project}-fgt1"
    admin_username = var.username
    admin_password = var.password
    custom_data    = data.template_file.dut1_customdata.rendered
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }

  tags = {
    Project = "${var.project}"
  }

}

////////////////////////////////////////IAM/////////////////////////////

resource "azurerm_role_assignment" "fgt_reader_role" {
  scope                = "/subscriptions/${var.azsubscriptionid}"
  role_definition_name = "Reader"
  principal_id         = azurerm_virtual_machine.dut1.identity[0].principal_id  
  depends_on = [
    azurerm_virtual_machine.dut1
  ]
}


////////////////////////////////////////DUT2//////////////////////////////
data "template_file" "dut2_customdata" {
  template = file ("./assets/fgt-aa-userdata.tpl")
  vars = {
    fgt_id              = element ( values(var.dut2)[*].vmname , 0)
    fgt_license_file    = "./assets/lic/fgt2.lic"
    fgt_username        = var.username
    fgt_config_ha       = false
    fgt_config_autoscale = true
    fgt_config_probe = true
    role = "secondary"
    masterip = var.dut1["nic1"]["ip"]
    sync-port = "port1"
    psk = var.password

    fgt_ssh_public_key  = ""

    fgt_port1_gw     = cidrhost (element(azurerm_subnet.subnets["fgt_public"].address_prefixes , 0 ), 1) 
    fgt_port2_gw     = cidrhost (element(azurerm_subnet.subnets["fgt_private"].address_prefixes , 0 ), 1) 

  }
}



resource "azurerm_virtual_machine" "dut2" {
  name                         = "${var.TAG}-${var.project}-fgt2"
  location                      = azurerm_resource_group.rg.location
  resource_group_name           = azurerm_resource_group.rg.name
  network_interface_ids        =  [for nic in azurerm_network_interface.dut2nics: nic.id]
  primary_network_interface_id = element ( values(azurerm_network_interface.dut2nics)[*].id , 0)
  vm_size                      = var.dut_vmsize

  identity {
    type = "SystemAssigned"
  }

  storage_image_reference {
    publisher = "fortinet"
    offer     = var.FGT_OFFER
    sku       = var.FGT_IMAGE_SKU
    version   = var.FGT_VERSION
  }

  plan {
    publisher = "fortinet"
    product   = var.FGT_OFFER
    name      = var.FGT_IMAGE_SKU
  }

  storage_os_disk {
    name              = "${var.TAG}-${var.project}-fgt2_OSDisk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  storage_data_disk {
    name = "${var.TAG}-${var.project}-fgt2_DataDisk"
    managed_disk_type = "Premium_LRS"
    create_option = "Empty"
    lun = 0
    disk_size_gb = "20"
  }
  os_profile {
    computer_name  = "${var.TAG}-${var.project}-fgt2"
    admin_username = var.username
    admin_password = var.password
    custom_data    = data.template_file.dut2_customdata.rendered
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }

  tags = {
    Project = "${var.project}"
  }

}

////////////////////////////////////////IAM/////////////////////////////

resource "azurerm_role_assignment" "fgt2_reader_role" {
  scope                = "/subscriptions/${var.azsubscriptionid}"
  role_definition_name = "Reader"
  principal_id         = azurerm_virtual_machine.dut2.identity[0].principal_id  
  depends_on = [
    azurerm_virtual_machine.dut2
  ]
}

////////////////////////////////////////DUT3//////////////////////////////

data "template_file" "dut3_customdata" {
  template = file ("./assets/fgt-aa-userdata.tpl")
  vars = {
    fgt_id              = element ( values(var.dut3)[*].vmname , 0)
    fgt_license_file    = "./assets/lic/fgt3.lic"
    fgt_username        = var.username
    fgt_config_ha       = false
    fgt_config_autoscale = true
    fgt_config_probe = true
    role = "secondary"
    masterip = var.dut1["nic1"]["ip"]
    sync-port = "port1"
    psk = var.password

    fgt_ssh_public_key  = ""

    fgt_port1_gw     = cidrhost (element(azurerm_subnet.subnets["fgt_public"].address_prefixes , 0 ), 1) 
    fgt_port2_gw     = cidrhost (element(azurerm_subnet.subnets["fgt_private"].address_prefixes , 0 ), 1) 

  }
}

resource "azurerm_virtual_machine" "dut3" {
  name                         = "${var.TAG}-${var.project}-fgt3"
  location                      = azurerm_resource_group.rg.location
  resource_group_name           = azurerm_resource_group.rg.name
  network_interface_ids        =  [for nic in azurerm_network_interface.dut3nics: nic.id]
  primary_network_interface_id = element ( values(azurerm_network_interface.dut3nics)[*].id , 0)
  vm_size                      = var.dut_vmsize

  identity {
    type = "SystemAssigned"
  }

  storage_image_reference {
    publisher = "fortinet"
    offer     = var.FGT_OFFER
    sku       = var.FGT_IMAGE_SKU
    version   = var.FGT_VERSION
  }

  plan {
    publisher = "fortinet"
    product   = var.FGT_OFFER
    name      = var.FGT_IMAGE_SKU
  }

  storage_os_disk {
    name              = "${var.TAG}-${var.project}-fgt3_OSDisk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  storage_data_disk {
    name = "${var.TAG}-${var.project}-fgt3_DataDisk"
    managed_disk_type = "Premium_LRS"
    create_option = "Empty"
    lun = 0
    disk_size_gb = "20"
  }
  os_profile {
    computer_name  = "${var.TAG}-${var.project}-fgt3"
    admin_username = var.username
    admin_password = var.password
    custom_data    = data.template_file.dut3_customdata.rendered
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }

  tags = {
    Project = "${var.project}"
  }

}

////////////////////////////////////////IAM/////////////////////////////

resource "azurerm_role_assignment" "fgt3_reader_role" {
  scope                = "/subscriptions/${var.azsubscriptionid}"
  role_definition_name = "Reader"
  principal_id         = azurerm_virtual_machine.dut3.identity[0].principal_id  
  depends_on = [
    azurerm_virtual_machine.dut3
  ]
}
