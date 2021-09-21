
azsubscriptionid = ""

project = "Outbound"
TAG     = "xom"

//==============================

loc  = "eastus2"
hubvnetcidr = ["10.86.0.0/24"]


hubvnetsubnets = {
  "fgt_public"  = { name = "fgt_public", cidr = "10.86.0.0/26" },
  "fgt_private" = { name = "fgt_private", cidr = "10.86.0.64/26" },
  "RouteServerSubnet" = { name = "RouteServerSubnet", cidr = "10.86.0.128/26" }
}

hubvnetroutetables = {
  "fgt_public"  = { name = "fgt-pub_rt" },
  "fgt_private" = { name = "fgt-priv_rt" },
}

hubnsgs = {
  "pub-nsg"  = { name = "pub-nsg" },
  "priv-nsg" = { name = "priv-nsg" },
}

hubnsgrules = {
  "pub-nsg-inbound"   = { nsgname = "pub-nsg", rulename = "AllInbound", priority = "100", direction = "Inbound", access = "Allow" },
  "pub-nsg-outbound"  = { nsgname = "pub-nsg", rulename = "AllOutbound", priority = "100", direction = "Outbound", access = "Allow" },
  "priv-nsg-inbound"  = { nsgname = "priv-nsg", rulename = "AllInbound", priority = "100", direction = "Inbound", access = "Allow" },
  "priv-nsg-outbound" = { nsgname = "priv-nsg", rulename = "AllOutbound", priority = "100", direction = "Outbound", access = "Allow" },
}

//==============================


spokevnetcidr = ["10.86.1.0/24"]
spokevnetsubnets = {
  "k8s_master"  = { name = "k8s_master", cidr = "10.86.1.0/25" },
  "K8s_nodes"   = { name = "K8s_nodes", cidr = "10.86.1.128/25" },
}

spokevnetroutetables = {
  "K8s_nodes"  = { name = "k8s_nodes_rt" }
}


//==============================

dut_vmsize = "Standard_F4s_v2"
FGT_IMAGE_SKU= "fortinet_fg-vm"
FGT_VERSION = "7.0.1"
FGT_OFFER="fortinet_fortigate-vm_v5"

dut1 = {
  "nic1" = { vmname = "aa-fgt1", name = "port1", subnet = "fgt_public", ip = "10.86.0.4"  , nsgname = "pub-nsg"  },
  "nic2" = { vmname = "aa-fgt1", name = "port2", subnet = "fgt_private", ip = "10.86.0.68", nsgname = "priv-nsg" }

}

dut2 = {
  "nic1" = { vmname = "aa-fgt2", name = "port1", subnet = "fgt_public", ip = "10.86.0.5"   , nsgname = "pub-nsg" },
  "nic2" = { vmname = "aa-fgt2", name = "port2", subnet = "fgt_private", ip = "10.86.0.69" , nsgname = "priv-nsg"}

}
dut3 = {
  "nic1" = { vmname = "aa-fgt3", name = "port1", subnet = "fgt_public", ip = "10.86.0.6"   , nsgname = "pub-nsg" },
  "nic2" = { vmname = "aa-fgt3", name = "port2", subnet = "fgt_private", ip = "10.86.0.70" , nsgname = "priv-nsg"}
}

ilbip = "10.86.0.80"
ilbprob = "8008" 
elbprob = "8008"



//==============================
username = "useryourown"
password =  "useyourown"


//==============================

fgttfaccess = "x.x.x.x"
fgttftoken =  "xxxxxxxxxxxxxxxxxxxxx"
