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
| s3\_env | cloudposse/label/null | 0.25.0 |

## Resources

| Name | Type |
|------|------|
| [aws_s3_bucket.bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket.not_protected_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket_lifecycle_configuration.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_lifecycle_configuration) | resource |
| [aws_s3_bucket_policy.cloudwatch_logs_write_access](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_policy) | resource |
| [aws_s3_bucket_public_access_block.block_public_access](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block) | resource |
| [aws_s3_bucket_server_side_encryption_configuration.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_server_side_encryption_configuration) | resource |
| [aws_s3_bucket_versioning.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_versioning) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_kms_alias.aws_managed_s3_key](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/kms_alias) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| backup\_type | AWS backup plan for S3 buckets. Short Backup plan retains backup for 2 years(24 months) and long backup plan retains backup for 5 years if cold storage is supported on product being provisioned | `string` | `"short"` | no |
| block\_public\_access | Block public access to S3 bucket. | `bool` | `true` | no |
| bucket\_duty | Specify bucket duty from assets, logs, dbbackup. | `string` | n/a | yes |
| bucket\_key\_enabled | Whether or not to use Amazon S3 Bucket Keys for SSE-KMS. | `bool` | `true` | no |
| bucket\_versioning | Enable bucket versioning (Valid values: Enabled or Disabled). | `string` | `"Enabled"` | no |
| enable\_noncurrent\_version\_expiration | Enble/disable to include noncurrent\_version\_expiration in s3 lifecycle. | `bool` | `true` | no |
| enable\_noncurrent\_version\_transition | Enble/disable to include noncurrent\_version\_transition in s3 lifecycle. | `bool` | `true` | no |
| env\_vars | Map of environment variables to be used for labeling and tagging resources. Expected keys include: - "namespace": The namespace for resource labeling (default: "alnafi") - "stage": The stage/environment (e.g., "dev", "test", "prod - "delimiter": The delimiter to use in labels (default: "-") | `map(string)` | `{}` | no |
| expired\_objects\_deletion\_days | No of days after which expired object delete markers or incomplete multipart uploads should be deleted. | `number` | `30` | no |
| force\_destroy | Choose whether you want to create a destroy able bucket. | `bool` | `false` | no |
| intelligent\_tiering | Enable intelligent tiering life cycle policy for all objects. | `string` | `"Enabled"` | no |
| kms\_key\_id | KMS key id to encrypt s3 bucket. If left empty, the default AWS managed key will be used. | `string` | `""` | no |
| non\_current\_version\_expiration\_in\_days | Expiration in days for previous versions of objects in bucket if versioning is enabled. | `number` | `365` | no |
| non\_current\_version\_transition\_in\_days | Transition in days for previous versions of objects in bucket to glacier storage if versioning is enabled. | `number` | `30` | no |

## Outputs

| Name | Description |
|------|-------------|
| bucket\_arn | S3 bucket Arn. |
| bucket\_id | S3 bucket ID. |
<!-- END_TF_DOCS -->