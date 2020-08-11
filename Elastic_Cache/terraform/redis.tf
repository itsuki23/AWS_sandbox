# Elastic Cache parameter group
resource "aws_elastic_parameter_group" "main" {
  name    = "main"
  family  = "redis5.0"

  parameter {
    name  = "cluster-enabled"
    value = "no"
  }
}

# Subnet group
resource "aws_elasticache_subnet_group" "main" {
  name = "main"
  subnet_ids = [
    aws_subnet.private_1a.id,
    aws_subnet.private_1c.id  
  ]
}

# Replication group
resource "aws_elasticache_replication_group" "main" {
  replication_group_id = "main"
  replication_group_description = "Cluster Disabled"
  engine                        = "redis"
  engin_version                 = "5.0.4"
  number_cache_clusters         = 3
  node_type                     = "cache.m3.micro"
  snapshot_window               = "09:10-10:10"
  snapshot_retention_limit      = 7
  maintenance_window            = "mon:10:40-mon:11:40"
  automatic_failover_enabled    = true
  port                          = 6379
  apply_immediately             = false
  security_group_name           = [module.redis_sg.security_group_id]
  parameter_group_name          = aws_elasticache_parameter_group.main.name
  subnet_group_name             = aws_elasticache_subnet_group.main.name
}