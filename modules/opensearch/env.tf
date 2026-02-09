module "opensearch_env" {
  source    = "cloudposse/label/null"
  version   = "0.25.0"
  namespace = lookup(var.env_vars, "namespace", "alnafi")
  stage     = lookup(var.env_vars, "stage", "test")
  name      = local.module_name
  delimiter = lookup(var.env_vars, "delimiter", "-")

  tags = {
    "TF-Module" = local.module_name
  }
}

