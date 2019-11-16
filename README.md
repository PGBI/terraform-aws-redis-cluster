# AWS Redis Cluster Module

## Description

This module is used to create a Redis AWS elasticache replication group. In AWS, an elasticache replication group is a 
collection of shards (aka "cluster" or "node group"). Each shard is composed of a master node and may have read replica 
nodes.

## Usage

```hcl
/**
 * Initialize the project
 */
module "project" {
  source  = "PGBI/project/aws"
  version = "~>0.1.0"

  name     = "myproject"
  vcs_repo = "github.com/account/project"
}

module "redis_cluster" {
  source  = "PGBI/redis-cluster/aws"
  version = "~>0.1.0"

  project = module.project
  
  name                       = "cache"
  num_shards                 = 1
  replicas_per_shard         = 0
  allowed_security_group_ids = ["sg-12345"]
  vpc_id                     = "vpc-12345"
  subnet_ids                 = [
    "subnet-abc",
    "subnet-def",
  ]
}
```
