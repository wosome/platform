output "name" {
  value = module.vpc.network_name
}
output "subnetwork" {
  value = module.vpc.subnets_self_links[0]
}
