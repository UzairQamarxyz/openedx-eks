locals {
  name = "openedx"

  # Random suffix for S3 bucket uniqueness
  random_suffix = random_string.bucket_suffix.result

  cluster_name    = "eks-${var.env_vars["stage"]}-01"
  rds_name        = "rds-${var.env_vars["stage"]}-01"
  documentdb_name = "documentdb-${var.env_vars["stage"]}-01"
}
