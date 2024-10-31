variable "project_id" {
  type = string
}

variable "my_ip_address" {
  type = string
}

module "environment" {
  source        = "../../"
  env           = "dev"
  project_id    = var.project_id
  my_ip_address = var.my_ip_address

  # The GKE node subnet name has to match one of the subnets you create
  # so that GKE autopilot knows which subnet you want to create nodes
  # in.
  #
  gke_node_subnet_name = "private"

  # Let's override the default subnets with some of our own.
  #
  vpc_subnets = [
    {
      subnet_name   = "public"
      subnet_ip     = "10.0.10.0/26"
      subnet_region = "us-west1"
      description   = "public"
    },
    {
      subnet_name   = "private",
      subnet_ip     = "10.0.20.0/26"
      subnet_region = "us-west1"
      description   = "private"
    }
  ]

  # Add an egress route to the routing table.
  #
  vpc_routes = [{
    name              = "egress"
    description       = "egress"
    destination_range = "0.0.0.0/0"
    tags              = "egress-inet"
    next_hop_internet = "true"
  }]

  # As well we should provide our own custom firewall rules.
  #
  vpc_firewall_rules = [{
    name               = "foobar"
    description        = "foobar"
    direction          = "INGRESS"
    priority           = 100
    destination_ranges = ["0.0.0.0/16"]
    source_ranges      = ["1.1.1.1/32"]

    allow = [{
      protocol = "tcp"
      ports    = ["22"]
    }]
  }]

  # Let's also customize the k8s cluster a bit by giving it
  # a spicier, more latest version.
  #
  gke_release_channel = "RAPID"
}
