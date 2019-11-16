output "dns_name" {
  description = "Endpoint dns name."
  value       = local.cluster_mode_enabled ? aws_elasticache_replication_group.main.configuration_endpoint_address : aws_elasticache_replication_group.main.primary_endpoint_address
}

output "sg_id" {
  description = "ID of the security group the elasticache cluster belongs to."
  value       = module.sg.id
}
