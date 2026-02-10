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
| opensearch | terraform-aws-modules/opensearch/aws | 2.5.0 |
| opensearch\_env | cloudposse/label/null | 0.25.0 |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| db\_master\_password | Master password for OpenSearch internal user database. | `string` | n/a | yes |
| db\_master\_username | Master username for OpenSearch internal user database. | `string` | n/a | yes |
| domain\_name | Name of the OpenSearch domain. | `string` | n/a | yes |
| eks\_node\_security\_group\_id | Security group ID for EKS nodes allowed to access OpenSearch. | `string` | n/a | yes |
| env\_vars | Map of environment variables to be used for labeling and tagging resources. Expected keys include: - "namespace": The namespace for resource labeling (default: "alnafi") - "stage": The stage/environment (e.g., "dev", "test", "prod") - "delimiter": The delimiter to use in labels (default: "-") | `map(string)` | `{}` | no |
| opensearch\_ebs\_volume\_size | EBS volume size for OpenSearch in GB. | `number` | n/a | yes |
| opensearch\_engine\_version | OpenSearch engine version. | `string` | n/a | yes |
| opensearch\_instance\_count | Number of OpenSearch instances. | `number` | n/a | yes |
| opensearch\_instance\_type | Instance type for OpenSearch. | `string` | n/a | yes |
| opensearch\_kms\_key\_arn | KMS key ARN for OpenSearch encryption at rest. | `string` | n/a | yes |
| private\_subnets | List of private subnet IDs for OpenSearch. | `list(string)` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| domain\_endpoint | OpenSearch domain endpoint |
<!-- END_TF_DOCS -->