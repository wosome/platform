provider "google" {
  credentials = file("../auth/.gcp")
  project = var.project
  region = var.region
  zone = var.zone
}

provider "google-beta" {
  credentials = file("../auth/.gcp")
  project = var.project
  region = var.region
  zone = var.zone
}

provider "kubernetes" {}
provider "helm" {}

terraform {
  backend "gcs" {
    credentials = "../auth/.gcp"
    bucket = "wosome-tf"
  }
}

module "platform-vpc" {
  source = "./modules/vpc"
  project = var.project
  name = "platform"
  subnets = [
    {
        subnet_name           = "subnet-01"
        subnet_ip             = "10.10.10.0/24"
        subnet_ip             = "10.10.10.0/24"
        subnet_region         = "us-east1"
    }
  ]
  routes = [
    {
      name                   = "egress-internet"
      description            = "route through IGW to access internet"
      destination_range      = "0.0.0.0/0"
      tags                   = "egress-inet"
      next_hop_internet      = "true"
    },
  ]
}

module "platform" {
  source = "./modules/gke-cluster"
  project = var.project
  region = var.region
  network = {
    name = module.platform-vpc.name
    subnetwork = module.platform-vpc.subnetwork
  }
  name = "platform"
}

resource "kubernetes_pod" "nginx" {
  metadata {
    name = "nginx-example"
    labels = {
      App = "nginx"
    }
  }

  spec {
    container {
      image = "nginx:1.7.8"
      name  = "example"

      port {
        container_port = 80
      }
    }
  }
}
