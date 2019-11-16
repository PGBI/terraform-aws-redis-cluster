variable "project" {
  description = "Reference to a \"project\" module. See: https://registry.terraform.io/modules/PGBI/project/aws/"
}

variable "name" {
  description = "Name for the cluster"
  type        = string
}

variable "node_type" {
  default     = "cache.t2.micro"
  type        = string
  description = "The size of the node instances."
}

variable "engine_version" {
  default     = "5.0.4"
  type        = string
  description = "Engine version to use. See https://docs.aws.amazon.com/AmazonElastiCache/latest/red-ug/supported-engine-versions.html"
}

variable "vpc_id" {
  type        = string
  description = "The VPC the redis cluster will belong to."
}

variable "replicas_per_shard" {
  default     = 0
  type        = number
  description = "Each shard may be composed of a primary node and replica nodes. This is the number of desired replica nodes per shard."
}

variable "num_shards" {
  default     = 1
  type        = number
  description = "Number of shards that will compose the redis cluster."
}

variable "subnet_ids" {
  type        = set(string)
  description = "The subnets in which to deploy the cluster."
}

variable "allowed_security_group_ids" {
  type        = set(string)
  description = "List of security group IDs that will be allowed to connect to the redis instance."
  default     = []
}

locals {
  engine_version_to_family = {
    "5.0.4"  = "redis5.0"
    "5.0.3"  = "redis5.0"
    "5.0.0"  = "redis5.0"
    "4.0.10" = "redis4.0"
    "3.2.10" = "redis3.2"
    "3.2.6"  = "redis3.2"
    "3.2.4"  = "redis3.2"
  }

  memory_per_node_type = {
    "cache.t2.micro"  = 0.555
    "cache.t2.small"  = 1.55
    "cache.t2.medium" = 3.22
    "cache.m4.large"  = 6.42
    "cache.m4.xlarge" = 14.28
    "cache.m5.large"  = 6.38
    "cache.m5.xlarge" = 12.93
    "cache.r4.large"  = 12.3
    "cache.r4.xlarge" = 25.05
  }
}
