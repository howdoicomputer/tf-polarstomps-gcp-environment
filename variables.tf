variable "project_id" {
  type = string
}

variable "region" {
  type    = string
  default = "us-west1"
}

variable "vpc_enable_my_ip_ingress_rule" {
  description = "Whether or not to create an ingress rule for a home IP address. Is added to var.vpc_firewall_rules. If set then you need to set var.vpc_public_subnet_cidr to your public subnet cidr block."
  type        = bool
  default     = true
}

variable "my_ip_address" {
  description = "A source IP used to connect to the k8s control plane"
  type        = string
}

variable "env" {
  description = "What to name a logical environment"
  type        = string
}

variable "nat_ip_allocate_option" {
  description = "https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_router_nat#nat_ip_allocate_option"
  type        = string
  default     = "AUTO_ONLY"
}

variable "nat_source_subnetwork_ip_ranges_to_nat" {
  description = "https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_router_nat#source_subnetwork_ip_ranges_to_nat"
  type        = string
  default     = "ALL_SUBNETWORKS_ALL_IP_RANGES"
}

variable "vpc_public_subnet_name" {
  description = "The name of the VPC public subnet. Default: infra-$(env)-public-01"
  type        = string
  default     = ""
}

variable "vpc_private_subnet_name" {
  description = "The name of the VPC private subnet. Default: infra-$(env)-private-01"
  type        = string
  default     = ""
}

variable "vpc_subnets" {
  description = "Use to override the creation of the default subnets. There be dragons here."

  type = list(object({
    subnet_name   = string
    subnet_ip     = string
    subnet_region = string
    description   = string
  }))

  default = []
}

variable "vpc_private_subnet_secondary_ranges" {
  description = "Use to override the creation of secondary subnet ranges for GKE worker node allocations."

  type = list(object({
    range_name    = string
    ip_cidr_range = string
  }))

  default = []
}

variable "vpc_firewall_rules" {
  description = "Use to define firewall rules"

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
  description = "https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_network#routing_mode"
  type        = string
  default     = "GLOBAL"
}

variable "vpc_public_subnet_cidr" {
  description = "The cidr block for the public subnet"
  type        = string
  default     = "10.10.10.0/26"
}

variable "vpc_private_subnet_cidr" {
  description = "The cidr block for the private subnet"
  type        = string
  default     = "10.10.20.0/26"
}

variable "vpc_auto_create_subnets" {
  description = "Whether or not to automatically create VPC subnets. This should almost always be off."
  type        = bool
  default     = false
}

variable "vpc_shared_vpc_host" {
  description = "Whether or not to setup a VPC as a 'shared VPC.'"
  type        = bool
  default     = false
}

variable "vpc_routes" {
  description = "Use to override the default VPC routes."

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
  description = "The cidr block for the GKE control plane."
  type        = string
  default     = "10.10.30.0/28"
}

variable "gke_pods_range_cidr" {
  description = "The cidr block for the GKE pods"
  type        = string
  default     = "192.168.0.0/18"
}

variable "gke_svc_range_cidr" {
  description = "The cidr block for GKE services"
  type        = string
  default     = "192.168.64.0/18"
}

variable "gke_node_subnet_name" {
  description = "The subnet name for nodes created by GKE autopilot"
  type        = string
}

variable "gke_release_channel" {
  description = "The release channel for GKE versions"
  type        = string
  default     = "REGULAR"
}

variable "gke_enable_vertical_pod_autoscaling" {
  description = "Enabling GKE vertical pod autoscaling."
  type        = bool
  default     = true
}

variable "gke_horizontal_pod_autoscaling" {
  description = "Enabling GKE horizontal pod autoscaling."
  type        = bool
  default     = true
}

variable "gke_kubernetes_version" {
  description = "Which Kubernetes version to use for the cluster."
  type        = string
  default     = "latest"
}

variable "gke_enable_private_endpoint" {
  description = "Whether or not to make the control plane endpoint private to a subnet"
  type        = string
  default     = false
}

variable "gke_enable_private_nodes" {
  description = "Hide them nodes."
  type        = string
  default     = true
}

variable "gke_deletion_protection" {
  description = "Deletino protection. I'm not made of money so this is false by default."
  type        = string
  default     = false
}

variable "gke_network_tags" {
  description = "GKE network tags."
  type        = list(string)
  default     = []
}

variable "gke_master_authorized_networks" {
  description = "Use to override the default ingress rule that is constructed from var.my_ip_address"

  type = list(object({
    cidr_block   = string
    display_name = string
  }))

  default = []
}
