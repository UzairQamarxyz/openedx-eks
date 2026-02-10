<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0 |
| aws | >= 6.0.0 |

## Providers

| Name | Version |
|------|---------|
| aws | 6.31.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| aoss\_kms | terraform-aws-modules/kms/aws | 4.2.0 |
| default\_kms | terraform-aws-modules/kms/aws | 4.2.0 |
| ebs\_kms | terraform-aws-modules/kms/aws | 4.2.0 |
| efs\_kms | terraform-aws-modules/kms/aws | 4.2.0 |
| elasticache\_kms | terraform-aws-modules/kms/aws | 4.2.0 |
| firewall\_kms | terraform-aws-modules/kms/aws | 4.2.0 |
| kms\_env | cloudposse/label/null | 0.25.0 |
| rds\_kms | terraform-aws-modules/kms/aws | 4.2.0 |
| s3\_kms | terraform-aws-modules/kms/aws | 4.2.0 |

## Resources

| Name | Type |
|------|------|
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy_document.aoss_kms_key_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.default_kms_key_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.ebs_kms_key_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.efs_kms_key_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.elasticache_kms_key_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.firewall_kms_key_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.rds_kms_key_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.s3_kms_key_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| create\_aoss\_key | Set to true if you want to create an amazon opensearch serverless service KMS CMK. | `bool` | `false` | no |
| create\_default\_key | Set to true if you want to create a default KMS CMK. | `bool` | `true` | no |
| create\_ebs\_key | Set to true if you want to create an EBS KMS CMK. | `bool` | `true` | no |
| create\_efs\_key | Set to true if you want to create an EFS KMS CMK. | `bool` | `false` | no |
| create\_elasticache\_key | Set to true if you want to create an Elasticache KMS CMK. | `bool` | `false` | no |
| create\_firewall\_key | Set to true if you want to create a Firewall KMS CMK. | `bool` | `false` | no |
| create\_rds\_key | Set to true if you want to create a RDS KMS CMK. | `bool` | `false` | no |
| create\_s3\_key | Set to true if you want to create a S3 KMS CMK. | `bool` | `true` | no |
| env\_vars | Map of environment variables to be used for labeling and tagging resources. Expected keys include: - "namespace": The namespace for resource labeling (default: "alnafi") - "stage": The stage/environment (e.g., "dev", "test", "prod - "delimiter": The delimiter to use in labels (default: "-") | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| aoss\_key\_arn | Terraform aoss KMS key arn |
| aoss\_key\_id | Terraform aoss KMS key id |
| default\_key\_arn | Terraform default KMS key arn |
| default\_key\_id | Terraform default KMS key id |
| ebs\_key\_arn | Terraform EBS KMS key arn |
| ebs\_key\_id | Terraform EBS KMS key id |
| efs\_key\_arn | Terraform EFS KMS key arn |
| efs\_key\_id | Terraform EFS KMS key id |
| elasticache\_key\_arn | Terraform Elasticache KMS key arn |
| elasticache\_key\_id | Terraform Elasticache KMS key id |
| firewall\_key\_arn | Terraform firewall KMS key arn |
| firewall\_key\_id | Terraform firewall KMS key id |
| rds\_key\_arn | Terraform RDS KMS key arn |
| rds\_key\_id | Terraform RDS KMS key id |
| s3\_key\_arn | Terraform s3 KMS key arn |
| s3\_key\_id | Terraform s3 KMS key id |
<!-- END_TF_DOCS -->