locals {
  name = "openedx"

  cluster_name    = "eks-${var.env_vars["stage"]}-01"
  rds_name        = "rds-${var.env_vars["stage"]}-01"
  documentdb_name = "documentdb-${var.env_vars["stage"]}-01"
  redis_name      = "redis-${var.env_vars["stage"]}-01"
  domain_name     = "opensearch"
}
