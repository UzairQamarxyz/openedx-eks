<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0 |
| aws | >= 6.0.0 |

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| ingress\_nginx\_env | cloudposse/label/null | 0.25.0 |
| public\_ingress\_nginx | aws-ia/eks-blueprints-addons/aws | 1.23.0 |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| cluster\_endpoint | EKS Cluster Endpoint URL | `string` | n/a | yes |
| cluster\_name | EKS Cluster name | `string` | n/a | yes |
| cluster\_version | The Kubernetes version for the cluster | `string` | n/a | yes |
| env\_vars | Map of environment variables to be used for labeling and tagging resources. Expected keys include: - "namespace": The namespace for resource labeling (default: "alnafi") - "stage": The stage/environment (e.g., "dev", "test", "prod - "delimiter": The delimiter to use in labels (default: "-") | `map(string)` | `{}` | no |
| oidc\_provider\_arn | EKS OIDC Provider ARN | `string` | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->