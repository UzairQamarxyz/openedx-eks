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
| redis | cloudposse/elasticache-redis/aws | 2.0.0 |
| redis\_env | cloudposse/label/null | 0.25.0 |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| db\_master\_password | Master password used as Redis auth token. | `string` | n/a | yes |
| eks\_node\_security\_group\_id | Security group ID for EKS nodes allowed to access Redis. | `string` | n/a | yes |
| elasticache\_kms\_key\_arn | KMS key ARN for ElastiCache encryption. | `string` | n/a | yes |
| env\_vars | Map of environment variables to be used for labeling and tagging resources. Expected keys include: - "namespace": The namespace for resource labeling (default: "alnafi") - "stage": The stage/environment (e.g., "dev", "test", "prod") - "delimiter": The delimiter to use in labels (default: "-") | `map(string)` | `{}` | no |
| name | Name of the Redis cluster. | `string` | n/a | yes |
| private\_subnets | List of private subnet IDs for Redis. | `list(string)` | n/a | yes |
| redis\_cluster\_size | Number of nodes for Redis. | `number` | n/a | yes |
| redis\_engine\_version | Redis engine version. | `string` | n/a | yes |
| redis\_instance\_type | Instance class for ElastiCache Redis. | `string` | n/a | yes |
| vpc\_id | ID of the VPC where Redis will be created. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| primary\_endpoint\_address | Redis primary endpoint address |
| redis\_endpoint | Redis primary endpoint for cache and message broker |
| redis\_port | Redis port |
<!-- END_TF_DOCS -->