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
| backup\_workload\_env | cloudposse/label/null | 0.25.0 |

## Resources

| Name | Type |
|------|------|
| [aws_backup_plan.backup_plans](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/backup_plan) | resource |
| [aws_backup_region_settings.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/backup_region_settings) | resource |
| [aws_backup_selection.backup_selections](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/backup_selection) | resource |
| [aws_backup_vault.backup_vaults](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/backup_vault) | resource |
| [aws_backup_vault_notifications.backup_notifications](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/backup_vault_notifications) | resource |
| [aws_backup_vault_policy.backup_policies](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/backup_vault_policy) | resource |
| [aws_cloudwatch_event_rule.backup_copy_restore_job_rule](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_rule) | resource |
| [aws_cloudwatch_event_rule.backup_fail_event_rule](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_rule) | resource |
| [aws_iam_policy.s3_backup_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.s3_restore_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.s3_view_bucket_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.backup_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.backup_role_service_backup](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.backup_role_service_restores](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.backup_role_service_s3_backup](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.backup_role_service_s3_restore](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.backup_role_service_s3_view](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| additional\_tags | Additional tags to apply to all resources | `map(string)` | `{}` | no |
| backup\_plans | Dynamic backup plans configuration. Each plan can be enabled/disabled and customized. | ```map(object({ enabled = bool description = optional(string, "Backup plan managed by backup-workload module") # Plan naming plan_name = string # The actual AWS backup plan name vault_type = string # Schedule configuration backup_time_offset = optional(number, 0)   # Minutes offset from base backup_time use_rds_schedule = optional(bool, false) # Use RDS backup time instead of regular backup time # Rules configuration - each rule can be individually customized rules = map(object({ enabled = optional(bool, true) rule_name = string # User-defined rule name (AWS limit: 1-50 characters) retention_days = number cold_storage_after_days = optional(number, null) schedule_expression = string # cron expression for the backup schedule recovery_point_tags = optional(map(string), {}) # Copy action for cross-account/cross-region backups copy_action = optional(object({ enabled = optional(bool, false) destination_vault_arn = optional(string, null) # If null, will auto-generate retention_days = number cold_storage_after_days = optional(number, null) }), null) })) # Tags configuration selection_tag_key = string selection_tag_value = string plan_tags = optional(map(string), {}) }))``` | ```{ "long": { "backup_time_offset": 0, "description": "Long-term backup plan (5 years retention)", "enabled": true, "plan_name": "daily-weekly-monthly-quarterly-yearly-mqy-5years", "plan_tags": { "backup": "long" }, "rules": { "daily": { "copy_action": { "enabled": true, "retention_days": 7 }, "recovery_point_tags": { "backup": "60Months-daily" }, "retention_days": 7, "rule_name": "60Months-daily", "schedule_expression": "cron(15 01 * * ? *)" }, "monthly": { "cold_storage_after_days": 91, "copy_action": { "cold_storage_after_days": 91, "enabled": true, "retention_days": 730 }, "recovery_point_tags": { "backup": "60Months-monthly" }, "retention_days": 730, "rule_name": "60Months-monthly", "schedule_expression": "cron(15 01 1 1/1 ? *)" }, "quarterly": { "cold_storage_after_days": 91, "copy_action": { "cold_storage_after_days": 91, "enabled": true, "retention_days": 1825 }, "recovery_point_tags": { "backup": "60Months-quarterly" }, "retention_days": 1825, "rule_name": "60Months-quarterly", "schedule_expression": "cron(15 01 15 1/4 ? *)" }, "weekly": { "copy_action": { "enabled": true, "retention_days": 30 }, "recovery_point_tags": { "backup": "60Months-weekly" }, "retention_days": 30, "rule_name": "60Months-weekly", "schedule_expression": "cron(15 01 ? * SAT *)" }, "yearly": { "cold_storage_after_days": 91, "copy_action": { "cold_storage_after_days": 91, "enabled": true, "retention_days": 1825 }, "recovery_point_tags": { "backup": "60Months-yearly" }, "retention_days": 1825, "rule_name": "60Months-yearly", "schedule_expression": "cron(15 01 1 1 ? *)" } }, "selection_tag_key": "backup", "selection_tag_value": "long", "use_rds_schedule": false, "vault_type": "long" }, "short": { "backup_time_offset": 0, "description": "Short-term backup plan (24 months retention)", "enabled": true, "plan_name": "daily-weekly-monthly-quarterly-yearly-mqy-24months", "plan_tags": { "backup": "short" }, "rules": { "daily": { "copy_action": { "enabled": true, "retention_days": 7 }, "recovery_point_tags": { "backup-rule": "24Months-daily" }, "retention_days": 7, "rule_name": "24Months-daily", "schedule_expression": "cron(15 01 * * ? *)" }, "monthly": { "cold_storage_after_days": 91, "copy_action": { "cold_storage_after_days": 91, "enabled": true, "retention_days": 365 }, "recovery_point_tags": { "Backup-rule": "24Months-monthly" }, "retention_days": 365, "rule_name": "24Months-monthly", "schedule_expression": "cron(15 01 1 1/1 ? *)" }, "quarterly": { "cold_storage_after_days": 91, "copy_action": { "cold_storage_after_days": 91, "enabled": true, "retention_days": 730 }, "recovery_point_tags": { "backup-rule": "24Months-quarterly" }, "retention_days": 730, "rule_name": "24Months-quarterly", "schedule_expression": "cron(15 01 15 1/4 ? *)" }, "weekly": { "copy_action": { "enabled": true, "retention_days": 30 }, "recovery_point_tags": { "backup-rule": "24Months-weekly" }, "retention_days": 30, "rule_name": "24Months-weekly", "schedule_expression": "cron(15 01 ? * SAT *)" }, "yearly": { "cold_storage_after_days": 91, "copy_action": { "cold_storage_after_days": 91, "enabled": true, "retention_days": 730 }, "recovery_point_tags": { "backup-rule": "24Months-yearly" }, "retention_days": 730, "rule_name": "24Months-yearly", "schedule_expression": "cron(15 01 1 1 ? *)" } }, "selection_tag_key": "backup", "selection_tag_value": "short", "use_rds_schedule": false, "vault_type": "short" } }``` | no |
| backup\_vaults | Backup vault configuration. Defines the actual vaults that will be created. | ```map(object({ vault_name = string # Actual AWS vault name vault_type = string # "short" or "long" for categorization }))``` | ```{ "long-vault": { "vault_name": "daily-weekly-monthly-quarterly-yearly-mqy-5years", "vault_type": "long" }, "short-vault": { "vault_name": "daily-weekly-monthly-quarterly-yearly-mqy-24months", "vault_type": "short" } }``` | no |
| enable\_advanced\_features\_for\_dynamodb\_backups | Enable advanced features for DynamoDB backups (e.g., point-in-time recovery) | `bool` | `false` | no |
| enable\_advanced\_features\_for\_efs\_backups | Enable advanced features for EFS backups (e.g., backup policies) | `bool` | `false` | no |
| env\_vars | Map of environment variables to be used for labeling and tagging resources. Expected keys include: - "namespace": The namespace for resource labeling (default: "alnafi") - "stage": The stage/environment (e.g., "dev", "test", "prod - "delimiter": The delimiter to use in labels (default: "-") | `map(string)` | `{}` | no |
| max\_backup\_runtime | Maximum runtime for backup jobs in minutes | `number` | `720` | no |
| opt\_in\_settings | Resource type opt-in preferences for AWS Backup | `map(bool)` | ```{ "Aurora": true, "CloudFormation": false, "DocumentDB": true, "DynamoDB": true, "EBS": true, "EC2": true, "EFS": true, "EKS": true, "FSx": true, "Neptune": true, "RDS": true, "Redshift": true, "S3": true, "SAP HANA on Amazon EC2": false, "Storage Gateway": true, "Timestream": true, "VirtualMachine": true }``` | no |
| sns\_topic\_arn | SNS topic ARN for backup notifications | `string` | n/a | yes |
| use\_sqs\_for\_notifications | Use SQS instead of SNS for backup notifications | `bool` | `true` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->