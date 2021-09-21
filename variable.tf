variable "TAG" {
  description = "Customer or personal Prefix TAG of the created ressources"
  type        = string
}

variable "project" {
  description = "project Prefix TAG of the created ressources"
  type        = string
}

variable "azsubscriptionid" {
  description = "Azure Subscription id"
}

//----------------Hub VNET-----------

variable "loc" {
  description = "Deployment Location"

}
variable "hubvnetcidr" {
  description = "VNET CIDRs"
  type        = list(string)

}
variable "hubvnetsubnets" {
  description = "VNET Subnets names and CIDRs"
}

variable "hubvnetroutetables" {
  description = "VNET Route Table names"
}

variable "hubnsgs" {
  description = "Network Security Groups"
}

variable "hubnsgrules" {
  description = "Network Security Group Rules"
}

//----------------Spoke VNET------

variable "spokevnetcidr" {
  description = "VNET CIDRs"
  type        = list(string)

}
variable "spokevnetsubnets" {
  description = "VNET Subnets names and CIDRs"
}

variable "spokevnetroutetables" {
  description = "VNET Route Table names"
}

/*
variable "spokensgs" {
  description = "Network Security Groups"
}

variable "spokensgrules" {
  description = "Network Security Group Rules"
}*/

//--------------------------------
variable "dut_vmsize" {
  description = "FortiGate VM size"
}
variable "FGT_IMAGE_SKU" {
  description = "Azure Marketplace default image sku hourly (PAYG 'fortinet_fg-vm_payg_20190624') or byol (Bring your own license 'fortinet_fg-vm')"
}
variable "FGT_VERSION" {
  description = "FortiGate version by default the 'latest' available version in the Azure Marketplace is selected"
}
variable "FGT_OFFER" {
  description = "FortiGate version by default the 'latest' available version in the Azure Marketplace is selected"
}

variable "dut1" {
  description = "FGT1 Nics and IP"
}

variable "dut2" {
  description = "FGT2 Nics and IP"
}

variable "dut3" {
  description = "FGT3 Nics and IP"
}
//------------------------------

variable "ilbip" {
  description = "iLB IP"
}
variable "ilbprob" {
  description = "iLB Probe port"
}
variable "elbprob" {
  description = "eLB Probe port"
}
//------------------------------

variable "username" {
}
variable "password" {
}

//------------------------------


