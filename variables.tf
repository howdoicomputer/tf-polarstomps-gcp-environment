variable "project_id" {
  type = string
}

variable "region" {
  type    = string
  default = "us-west1"
}

variable "my_ip_address" {
  type = string
}

variable "env" {
  type = string
}

variable "nat_ip_allocate_option" {
  type    = string
  default = "AUTO_ONLY"
}

variable "nat_source_subnetwork_ip_ranges_to_nat" {
  type    = string
  default = "ALL_SUBNETWORKS_ALL_IP_RANGES"
}

variable "vpc_public_subnet_name" {
  type    = string
  default = ""
}

variable "vpc_private_subnet_name" {
  type    = string
  default = ""
}

variable "vpc_subnets" {
  type = list(object({
    subnet_name   = string
    subnet_ip     = string
    subnet_region = string
    description   = string
  }))

  default = []
}

variable "vpc_private_subnet_secondary_ranges" {
  type = list(object({
    range_name    = string
    ip_cidr_range = string
  }))

  default = []
}

variable "vpc_firewall_rules" {
  type = list(object({
    name = string
    description        = string
    direction          = string
    priority           = number
    destination_ranges = list(string)
    source_ranges      = list(string)

    allow = list(object({
      protocol = string
      ports    = list(string)
    }))
  }))

  default = []
}

variable "vpc_routing_mode" {
  type    = string
  default = "GLOBAL"
}

variable "vpc_public_subnet_cidr" {
  type    = string
  default = "10.10.10.0/26"
}

variable "vpc_private_subnet_cidr" {
  type    = string
  default = "10.10.20.0/26"
}

variable "vpc_auto_create_subnets" {
  type    = bool
  default = false
}

variable "vpc_shared_vpc_host" {
  type    = bool
  default = false
}

variable "vpc_routes" {
  type = list(object({
    name              = string
    description       = string
    destination_range = string
    tags              = string
    next_hop_internet = string
  }))

  default = []
}

variable "gke_control_plane_cidr" {
  type    = string
  default = "10.10.30.0/28"
}

variable "gke_pods_range_cidr" {
  type    = string
  default = "192.168.0.0/18"
}

variable "gke_svc_range_cidr" {
  type    = string
  default = "192.168.64.0/18"
}

variable "gke_release_channel" {
  type    = string
  default = "REGULAR"
}

variable "gke_enable_vertical_pod_autoscaling" {
  type    = bool
  default = true
}

variable "gke_horizontal_pod_autoscaling" {
  type    = bool
  default = true
}

variable "gke_kubernetes_version" {
  type    = string
  default = "latest"
}

# I'm making the control plane endpoint public so that I can manage it from my
# couch without needing a bastion host.
#
variable "gke_enable_private_endpoint" {
  type    = string
  default = false
}

variable "gke_enable_private_nodes" {
  type    = string
  default = true
}

variable "gke_deletion_protection" {
  type    = string
  default = false
}

variable "gke_network_tags" {
  type    = list(string)
  default = []
}

variable "gke_master_authorized_networks" {
  type = list(object({
    cidr_block   = string
    display_name = string
  }))

  default = []
}
