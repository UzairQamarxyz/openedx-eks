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
| documentdb | cloudposse/documentdb-cluster/aws | 1.0.0 |
| documentdb\_env | cloudposse/label/null | 0.25.0 |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| db\_master\_username | Master username for DocumentDB. | `string` | n/a | yes |
| default\_kms\_key\_arn | Default KMS key ARN for DocumentDB encryption. | `string` | n/a | yes |
| documentdb\_cluster\_family | DocumentDB cluster family. | `string` | `"docdb5.0"` | no |
| documentdb\_engine\_version | DocumentDB engine version. | `string` | `"5.0.0"` | no |
| documentdb\_instance\_class | Instance class for DocumentDB. | `string` | `"db.t3.medium"` | no |
| documentdb\_instance\_count | Number of DocumentDB instances. | `number` | `0` | no |
| env\_vars | Map of environment variables to be used for labeling and tagging resources. Expected keys include: - "namespace": The namespace for resource labeling (default: "alnafi") - "stage": The stage/environment (e.g., "dev", "test", "prod") - "delimiter": The delimiter to use in labels (default: "-") | `map(string)` | `{}` | no |
| name | Name of the documentdb cluster. | `string` | n/a | yes |
| private\_subnets | List of private subnet IDs for DocumentDB. | `list(string)` | n/a | yes |
| vpc\_cidr | CIDR block of the VPC for allowed CIDRs. | `string` | n/a | yes |
| vpc\_id | ID of the VPC where DocumentDB will be created. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| cluster\_endpoint | DocumentDB cluster endpoint |
| master\_username | DocumentDB master username |
| primary\_endpoint\_address | DocumentDB primary endpoint address |
| primary\_endpoint\_port | DocumentDB primary endpoint port |
<!-- END_TF_DOCS -->