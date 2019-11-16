locals {
  cluster_mode_enabled = var.replicas_per_shard > 0
}

/**
 * The security group the cluster will belong to.
 */
module "sg" {
  source  = "PGBI/security-group/aws"
  version = "~>0.1.0"

  project     = var.project
  name        = "${var.name}-redis-cluster"
  description = "Security group for the ${var.project.name_prefix}-${var.name} redis cluster."
  vpc_id      = var.vpc_id
}

/**
 * Adding ingress rules to the security group.
 */
resource "aws_security_group_rule" "redis_ingress" {
  for_each = var.allowed_security_group_ids

  source_security_group_id = each.value
  description              = "Managed by terraform."
  from_port                = 6379
  protocol                 = "tcp"
  security_group_id        = module.sg.id
  to_port                  = 6379
  type                     = "ingress"
}


/**
 * Create a parameter group for the cluster.
 */
resource "aws_elasticache_parameter_group" "main" {
  name   = "${var.project.name_prefix}-${var.name}"
  family = local.engine_version_to_family[var.engine_version]

  parameter {
    name  = "cluster-enabled"
    value = local.cluster_mode_enabled ? "yes" : "no"
  }
}

/**
 * Create a subnet group for the redis replication group
 */
resource "aws_elasticache_subnet_group" "main" {
  name       = "${var.project.name_prefix}-${var.name}"
  subnet_ids = length(var.subnet_ids) > 0 ? var.subnet_ids : var.project.default_subnet_ids
}

/**
 * The Redis cluster
 */
resource "aws_elasticache_replication_group" "main" {
  automatic_failover_enabled    = var.replicas_per_shard > 0
  replication_group_id          = "${var.project.name_prefix}-${var.name}"
  replication_group_description = "Managed by Terraform."
  engine                        = "redis"
  node_type                     = var.node_type
  engine_version                = var.engine_version
  at_rest_encryption_enabled    = true
  security_group_ids            = [module.sg.id]
  apply_immediately             = true
  subnet_group_name             = aws_elasticache_subnet_group.main.name
  snapshot_retention_limit      = 30
  parameter_group_name          = aws_elasticache_parameter_group.main.name
  number_cache_clusters         = local.cluster_mode_enabled ? null : var.num_shards

  # Add a cluster_mode block only if cluster mode is enabled.
  dynamic "cluster_mode" {
    for_each = local.cluster_mode_enabled ? ["yo"] : []
    content {
      replicas_per_node_group = var.replicas_per_shard
      num_node_groups         = var.num_shards
    }
  }

  tags = var.project.tags
}
