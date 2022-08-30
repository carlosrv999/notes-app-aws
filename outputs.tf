output "db_endpoint" {
  value = module.database.endpoint
}

output "load_balancer_dns_name" {
  value = module.loadbalancer.dns_name
}
