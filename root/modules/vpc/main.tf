module "vpc" {
  source  = "terraform-google-modules/network/google"

  project_id   = var.project
  network_name = var.name
  routing_mode = "REGIONAL"

  routes = var.routes
  subnets = var.subnets
}
