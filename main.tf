locals {
  vpc_name            = "infra-${var.env}-vpc"
  gke_cluster_name    = "infra-${var.env}-gke-cluster"
  pods_range_name     = "infra-${var.env}-private-gke-pods"
  svc_range_name      = "infra-${var.env}-private-gke-svc"

  gke_master_authorized_networks = coalescelist(
    var.gke_master_authorized_networks,
    [
      {
        cidr_block: var.my_ip_address, display_name: "Literally where I live"
      }
    ]
  )

  gke_node_subnet_name = coalesce(var.gke_node_subnet_name, local.vpc_private_subnet_name)

  my_ip_ingress_rule = {
    name               = "infra-${var.env}-allow-ssh-ingress"
    description        = "let me innnnnnn"
    direction          = "INGRESS"
    priority           = 0
    destination_ranges = [var.vpc_public_subnet_cidr]
    source_ranges      = [var.my_ip_address]

    allow = [{
      protocol = "tcp"
      ports    = ["22"]
    }]
  }

  vpc_firewall_rules = var.vpc_enable_my_ip_ingress_rule ? concat(var.vpc_firewall_rules, [local.my_ip_ingress_rule]) : var.vpc_firewall_rules

  vpc_subnets = coalescelist(
    var.vpc_subnets,
    [
      {
        subnet_name   = local.vpc_public_subnet_name
        subnet_ip     = var.vpc_public_subnet_cidr
        subnet_region = var.region
        description   = "Public internet facing services"
      },
      {
        subnet_name   = local.vpc_private_subnet_name
        subnet_ip     = var.vpc_private_subnet_cidr
        subnet_region = var.region
        description   = "Internal services"
      }
    ]
  )

  vpc_private_subnet_secondary_ranges = coalescelist(
    var.vpc_private_subnet_secondary_ranges,
    [
      {
        range_name    = "infra-${var.env}-private-gke-pods",
        ip_cidr_range = var.gke_pods_range_cidr
      },
      {
        range_name    = "infra-${var.env}-private-gke-svc"
        ip_cidr_range = var.gke_svc_range_cidr
      }
    ]
  )

  vpc_public_subnet_name  = coalesce(var.vpc_public_subnet_name, "infra-${var.env}-public-01")
  vpc_private_subnet_name = coalesce(var.vpc_private_subnet_name, "infra-${var.env}-private-01")

  vpc_routes = coalescelist(
    var.vpc_routes,
    [
      {
        name              = "infra-${var.env}-egress-internet",
        description       = "route to access internet"
        destination_range = "0.0.0.0/0"
        tags              = "egress-inet"
        next_hop_internet = "true"
      }
    ]
  )
}

module "vpc" {
  source  = "terraform-google-modules/network/google//modules/vpc"
  version = "~> 9.0.0"

  project_id   = var.project_id
  network_name = local.vpc_name

  auto_create_subnetworks = var.vpc_auto_create_subnets
  shared_vpc_host         = var.vpc_shared_vpc_host
  description             = "infra-${var.env} VPC"
  routing_mode            = var.vpc_routing_mode
}

module "subnets" {
  source  = "terraform-google-modules/network/google//modules/subnets"
  version = "~> 9.0.0"

  project_id   = var.project_id
  network_name = module.vpc.network_self_link
  subnets      = local.vpc_subnets

  secondary_ranges = {
    (local.gke_node_subnet_name) = local.vpc_private_subnet_secondary_ranges
  }
}

module "routes" {
  source  = "terraform-google-modules/network/google//modules/routes"
  version = "~> 9.0.0"

  project_id   = var.project_id
  network_name = module.vpc.network_self_link

  routes = var.vpc_routes
}

module "firewall_rules" {
  source  = "terraform-google-modules/network/google//modules/firewall-rules"
  version = "~> 9.0.0"

  project_id    = var.project_id
  network_name  = module.vpc.network_self_link
  ingress_rules = local.vpc_firewall_rules
}

resource "google_compute_router" "router" {
  name    = "infra-${var.env}-router"
  project = var.project_id
  network = local.vpc_name
  region  = var.region

  depends_on = [
    module.vpc
  ]
}

resource "google_compute_router_nat" "nat" {
  name                               = "infra-${var.env}-router-nat"
  router                             = google_compute_router.router.name
  region                             = var.region
  nat_ip_allocate_option             = var.nat_ip_allocate_option
  source_subnetwork_ip_ranges_to_nat = var.nat_source_subnetwork_ip_ranges_to_nat
  project                            = var.project_id
}

data "google_client_config" "default" {}

provider "kubernetes" {
  host                   = "https://${module.gke_cluster.endpoint}"
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(module.gke_cluster.ca_certificate)
}

module "gke_cluster" {
  # The standard k8s module does not support autopilot but autopilot is very cool so we're
  # going to use the beta.
  #
  source  = "terraform-google-modules/kubernetes-engine/google//modules/beta-autopilot-private-cluster"
  version = "~> 33.0"

  project_id = var.project_id

  name                            = local.gke_cluster_name
  network                         = module.vpc.network_name
  subnetwork                      = local.gke_node_subnet_name
  region                          = var.region
  master_ipv4_cidr_block          = var.gke_control_plane_cidr
  ip_range_services               = local.svc_range_name
  ip_range_pods                   = local.pods_range_name
  release_channel                 = var.gke_release_channel
  enable_vertical_pod_autoscaling = var.gke_enable_vertical_pod_autoscaling
  horizontal_pod_autoscaling      = var.gke_horizontal_pod_autoscaling
  kubernetes_version              = var.gke_kubernetes_version
  enable_private_endpoint         = var.gke_enable_private_endpoint
  enable_private_nodes            = var.gke_enable_private_nodes
  deletion_protection             = var.gke_deletion_protection

  network_tags = concat(var.gke_network_tags, ["infra-${var.env}-gke"])
  master_authorized_networks = local.gke_master_authorized_networks

  # There is a race condition where the GKE cluster starts being created before
  # the subnets have finished. This explicit dependency fixes that.
  #
  depends_on = [
    module.subnets
  ]
}
