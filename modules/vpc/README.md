<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| aws | 6.31.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| vpc | terraform-aws-modules/vpc/aws | 6.6.0 |
| vpc\_env | cloudposse/label/null | 0.25.0 |

## Resources

| Name | Type |
|------|------|
| [aws_security_group.additional](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_availability_zones.available](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/availability_zones) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| additional\_private\_subnet\_tags | Additional tags for public subnets | `map(any)` | `{}` | no |
| additional\_public\_subnet\_tags | Additional tags for public subnets | `map(any)` | `{}` | no |
| env\_vars | Map of environment variables to be used for labeling and tagging resources. Expected keys include: - "namespace": The namespace for resource labeling (default: "alnafi") - "stage": The stage/environment (e.g., "dev", "test", "prod - "delimiter": The delimiter to use in labels (default: "-") | `map(string)` | `{}` | no |
| flow\_log\_s3\_bucket\_arn | ARN of the S3 bucket to store VPC Flow Logs. | `string` | n/a | yes |
| name | VPC name. | `string` | n/a | yes |
| vpc\_cidr | CIDR block for the VPC. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| private\_subnets | List of IDs of private subnets |
| public\_subnets | List of IDs of public subnets |
| vpc\_cidr | VPC CIDR |
| vpc\_id | VPC ID |
<!-- END_TF_DOCS -->