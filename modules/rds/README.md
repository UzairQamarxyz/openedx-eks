<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| rds\_env | cloudposse/label/null | 0.25.0 |
| rds\_mysql | terraform-aws-modules/rds/aws | 7.1.0 |
| rds\_mysql\_sg | terraform-aws-modules/security-group/aws | 5.3.1 |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| db\_master\_username | Master username for the RDS MySQL database. | `string` | n/a | yes |
| default\_kms\_key\_arn | Default KMS key ARN for logs and performance insights. | `string` | n/a | yes |
| env\_vars | Map of environment variables to be used for labeling and tagging resources. Expected keys include: - "namespace": The namespace for resource labeling (default: "alnafi") - "stage": The stage/environment (e.g., "dev", "test", "prod") - "delimiter": The delimiter to use in labels (default: "-") | `map(string)` | `{}` | no |
| multi\_az\_enabled | Whether to enable Multi-AZ for RDS. | `bool` | `true` | no |
| name | Base name for the RDS resources (e.g., 'mysql'). | `string` | n/a | yes |
| performance\_insights\_enabled | Whether to enable Performance Insights for RDS. | `bool` | `false` | no |
| private\_subnets | List of private subnet IDs for RDS. | `list(string)` | n/a | yes |
| rds\_kms\_key\_arn | KMS key ARN for RDS encryption. | `string` | n/a | yes |
| rds\_mysql\_allocated\_storage | Allocated storage for RDS MySQL in GB. | `number` | n/a | yes |
| rds\_mysql\_db\_name | Name of the RDS MySQL database. | `string` | n/a | yes |
| rds\_mysql\_engine\_version | MySQL engine version for RDS. | `string` | n/a | yes |
| rds\_mysql\_family | RDS MySQL family. | `string` | `"mysql8.4"` | no |
| rds\_mysql\_instance\_class | Instance class for RDS MySQL. | `string` | n/a | yes |
| rds\_mysql\_major\_engine\_version | RDS MySQL major engine version. | `string` | `"8.4"` | no |
| vpc\_cidr | CIDR block of the VPC for RDS security group rules. | `string` | n/a | yes |
| vpc\_id | ID of the VPC where RDS will be created. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| db\_instance\_endpoint | RDS MySQL instance endpoint |
| db\_instance\_master\_secret\_arn | RDS MySQL instance master secret ARN |
| db\_instance\_port | RDS MySQL instance port |
| db\_instance\_username | RDS MySQL instance master username |
| security\_group\_id | Security group ID for RDS MySQL |
<!-- END_TF_DOCS -->