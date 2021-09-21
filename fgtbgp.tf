variable "fgttfaccess" {
}
variable "fgttftoken" {
}

resource "fortios_router_bgp" "arsbgp" {
  as             = 64686
  ebgp_multipath = "enable"
  always_compare_med                 = "disable"
  log_neighbour_changes              = "enable"

  redistribute {
    name   = "connected"
    status = "disable"
  }
  redistribute {
    name   = "rip"
    status = "disable"
  }
  redistribute {
    name   = "ospf"
    status = "disable"
  }
  redistribute {
    name   = "static"
    status = "disable"
  }
  redistribute {
    name   = "isis"
    status = "disable"
  }
  redistribute6 {
    name   = "connected"
    status = "disable"
  }
  redistribute6 {
    name   = "rip"
    status = "disable"
  }
  redistribute6 {
    name   = "ospf"
    status = "disable"
  }
  redistribute6 {
    name   = "static"
    status = "disable"
  }
  redistribute6 {
    name   = "isis"
    status = "disable"
  }
}

resource "fortios_routerbgp_neighbor" "ars1" {
  ip             = "10.86.0.132"
  activate = "enable"
  ebgp_enforce_multihop = "enable"
  remote_as = 65515
  description = "Azure Route Server"

}

resource "fortios_routerbgp_neighbor" "ars2" {
  ip             = "10.86.0.133"
  activate = "enable"
  ebgp_enforce_multihop = "enable"
  remote_as = 65515
  description = "Azure Route Server"

}