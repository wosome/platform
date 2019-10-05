

resource "google_container_cluster" "cluster" {
  name     = var.name
  location = var.region
  network  = var.network.name
  subnetwork = var.network.subnetwork

  remove_default_node_pool = true
  initial_node_count = 1

  # Setting an empty username and password explicitly disables basic auth
  master_auth {
    username = ""
    password = ""
  }

  addons_config {
    network_policy_config {
      disabled = "false"
    }
  }

  network_policy {
    enabled = "true"
    provider = "CALICO"
  }
}

module "node_pool_00" {
  source = "../gke-cluster-pool"

  cluster = google_container_cluster.cluster.name

  machine_type = var.pool_machine_type
  max_node_count = var.pool_max_node_count
  min_node_count = var.pool_min_node_count

  name = "${var.name}-node-pool-00"

  project = var.project
  region = var.region
}

resource "kubernetes_service_account" "tiller" {
  metadata {
    name      = "tiller"
    namespace = local.tiller_namespace
  }
}

locals {
  tiller_namespace = "kube-system"

  # For this example, we setup Tiller to manage the default Namespace.
  resource_namespace = "default"

  tiller_version = "v2.11.0"

  tls_ca_secret_namespace = "kube-system"

  tls_ca_secret_name   = "${local.tiller_namespace}-namespace-tiller-ca-certs"
  tls_secret_name      = "tiller-certs"
  tls_algorithm_config = "--tls-private-key-algorithm ${var.private_key_algorithm} ${var.private_key_algorithm == "ECDSA" ? "--tls-private-key-ecdsa-curve ${var.private_key_ecdsa_curve}" : "--tls-private-key-rsa-bits ${var.private_key_rsa_bits}"}"

  # These will be filled in by the shell environment
  kubectl_auth_config = "--kubectl-server-endpoint \"$KUBECTL_SERVER_ENDPOINT\" --kubectl-certificate-authority \"$KUBECTL_CA_DATA\" --kubectl-token \"$KUBECTL_TOKEN\""
}
