resource "aws_kms_key" "kms_key" {
  description         = "KMS Key for Backup Plan Vaults Encryption"
  is_enabled          = true
  enable_key_rotation = false
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "Allow administration of the key",
        "Effect" : "Allow",
        "Principal" : {
          "AWS" : "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        },
        "Action" : ["kms:*"],
        "Resource" : "*"
      },
      {
        "Sid" : "Allow use of the key",
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "backup.amazonaws.com"
        },
        "Action" : [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:DescribeKey"
        ],
        "Resource" : "*"
      }
    ]
  })
  multi_region = false

  tags = merge(module.backup_workload_env.tags, var.additional_tags)
}

# Dynamic Backup Vaults (only create unique vaults)
resource "aws_backup_vault" "backup_vaults" {
  for_each    = local.backup_vaults
  name        = each.value.name
  kms_key_arn = each.value.kms_key_arn
  tags = merge(module.backup_workload_env.tags, tomap({
    "backup-vault" : each.value.name
  }), tomap(var.additional_tags))
}

# Backup Vault Notifications
resource "aws_backup_vault_notifications" "backup_notifications" {
  for_each = { for k, v in local.backup_vaults : k => v if !var.use_sqs_for_notifications }

  backup_vault_name   = aws_backup_vault.backup_vaults[each.key].id
  sns_topic_arn       = var.sns_topic_arn
  backup_vault_events = ["COPY_JOB_FAILED", "RESTORE_JOB_COMPLETED"]
}

# Backup Vault Policies
resource "aws_backup_vault_policy" "backup_policies" {
  for_each = local.backup_vaults

  backup_vault_name = aws_backup_vault.backup_vaults[each.key].name

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "Deny deletion of aws backup recovery points",
        "Effect" : "Deny",
        "Principal" : "*",
        "Action" : [
          "backup:DeleteRecoveryPoint",
          "backup:UpdateRecoveryPointLifecycle",
          "backup:PutBackupVaultAccessPolicy"
        ],
        "Resource" : "*"
      }
    ]
  })
}

# Dynamic Backup Plans
resource "aws_backup_plan" "backup_plans" {
  for_each = local.backup_plans_grouped

  name = each.value.plan.plan_name

  # Dynamic rules block
  dynamic "rule" {
    for_each = each.value.rules
    content {
      completion_window = var.max_backup_runtime
      start_window      = 60
      target_vault_name = aws_backup_vault.backup_vaults[each.value.plan.vault_type].name

      # Lifecycle retention: shorten source if copy exists (example retains 30 days before copy lifecycle overtakes)
      lifecycle {
        delete_after       = (rule.value.copy_action != null) ? 30 : rule.value.retention_days
        cold_storage_after = (rule.value.copy_action != null) ? null : rule.value.cold_storage_after_days
      }

      recovery_point_tags = rule.value.recovery_point_tags

      # Use user-provided rule name (validated to be 1-50 characters)
      rule_name = rule.value.rule_name

      schedule = rule.value.schedule_expression
    }
  }

  tags = merge(module.backup_workload_env.tags, each.value.plan.plan_tags, var.additional_tags)
}

# Dynamic Backup Selections
resource "aws_backup_selection" "backup_selections" {
  for_each = local.enabled_backup_plans

  lifecycle {
    ignore_changes = all
  }

  iam_role_arn = aws_iam_role.backup_role.arn
  plan_id      = aws_backup_plan.backup_plans[each.key].id

  # Ensure name length <= 50 (truncate plan_name to 30 chars and append hash if needed)
  name = length("${each.value.plan_name}-selection") <= 50 ? "${each.value.plan_name}-selection" : "${substr(each.value.plan_name, 0, 30)}-sel-${substr(md5(each.value.plan_name), 0, 6)}"

  selection_tag {
    type  = "STRINGEQUALS"
    key   = each.value.selection_tag_key
    value = each.value.selection_tag_value
  }
}

# IAM Role (unchanged)
resource "aws_iam_role" "backup_role" {
  name                  = "backup-role"
  force_detach_policies = true

  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Service" : ["backup.amazonaws.com"]
        },
        "Action" : ["sts:AssumeRole"]
      }
    ]
  })

  tags = merge(module.backup_workload_env.tags, var.additional_tags)
}

resource "aws_iam_role_policy_attachment" "backup_role_service_backup" {
  role       = aws_iam_role.backup_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForBackup"
}

resource "aws_iam_role_policy_attachment" "backup_role_service_restores" {
  role       = aws_iam_role.backup_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForRestores"
}

resource "aws_iam_role_policy_attachment" "backup_role_service_s3_view" {
  role       = aws_iam_role.backup_role.name
  policy_arn = aws_iam_policy.s3_view_bucket_policy.arn
}

resource "aws_iam_role_policy_attachment" "backup_role_service_s3_backup" {
  role       = aws_iam_role.backup_role.name
  policy_arn = aws_iam_policy.s3_backup_policy.arn
}

resource "aws_iam_role_policy_attachment" "backup_role_service_s3_restore" {
  role       = aws_iam_role.backup_role.name
  policy_arn = aws_iam_policy.s3_restore_policy.arn
}

# S3 IAM Policies (unchanged)
resource "aws_iam_policy" "s3_view_bucket_policy" {
  name = "s3-view-bucket-policy"

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "S3BucketViewPermissions",
        "Action" : [
          "s3:GetBucketLocation",
          "s3:GetBucketVersioning",
          "s3:ListBucket",
          "s3:ListBucketVersions"
        ],
        "Effect" : "Allow",
        "Resource" : [
          "arn:aws:s3:::*"
        ]
      },
      {
        "Sid" : "S3ObjectViewPermissions",
        "Action" : [
          "s3:GetObject",
          "s3:GetObjectAcl",
          "s3:GetObjectTagging",
          "s3:GetObjectVersion",
          "s3:GetObjectVersionAcl"
        ],
        "Effect" : "Allow",
        "Resource" : [
          "arn:aws:s3:::*/*"
        ]
      }
    ]
  })
  tags = merge(module.backup_workload_env.tags, var.additional_tags)
}

resource "aws_iam_policy" "s3_backup_policy" {
  name = "s3-backup-policy"

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "S3BucketBackupPermissions",
        "Action" : [
          "s3:GetInventoryConfiguration",
          "s3:PutInventoryConfiguration",
          "s3:GetBucketNotification",
          "s3:PutBucketNotification",
          "s3:GetBucketTagging"
        ],
        "Effect" : "Allow",
        "Resource" : [
          "arn:aws:s3:::*"
        ]
      },
      {
        "Sid" : "S3ObjectBackupPermissions",
        "Action" : [
          "s3:GetObjectVersionTagging"
        ],
        "Effect" : "Allow",
        "Resource" : [
          "arn:aws:s3:::*/*"
        ]
      },
      {
        "Sid" : "S3GlobalPermissions",
        "Action" : [
          "s3:ListAllMyBuckets"
        ],
        "Effect" : "Allow",
        "Resource" : [
          "*"
        ]
      },
      {
        "Sid" : "KMSBackupPermissions",
        "Action" : [
          "kms:Decrypt",
          "kms:DescribeKey"
        ],
        "Effect" : "Allow",
        "Resource" : "*",
        "Condition" : {
          "StringLike" : {
            "kms:ViaService" : "s3.*.amazonaws.com"
          }
        }
      },
      {
        "Sid" : "EventsPermissions",
        "Action" : [
          "events:DescribeRule",
          "events:EnableRule",
          "events:PutRule",
          "events:DeleteRule",
          "events:PutTargets",
          "events:RemoveTargets",
          "events:ListTargetsByRule",
          "events:DisableRule"
        ],
        "Effect" : "Allow",
        "Resource" : "arn:aws:events:*:*:rule/AwsBackupManagedRule*"
      },
      {
        "Sid" : "EventsMetricsGlobalPermissions",
        "Action" : [
          "cloudwatch:GetMetricData",
          "events:ListRules"
        ],
        "Effect" : "Allow",
        "Resource" : "*"
      }
    ]
  })
  tags = merge(module.backup_workload_env.tags, var.additional_tags)
}

resource "aws_iam_policy" "s3_restore_policy" {
  name = "s3-restore-policy"

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "S3BucketRestorePermissions",
        "Action" : [
          "s3:CreateBucket",
          "s3:PutBucketVersioning",
          "s3:GetBucketOwnershipControls"
        ],
        "Effect" : "Allow",
        "Resource" : [
          "arn:aws:s3:::*"
        ]
      },
      {
        "Sid" : "S3ObjectRestorePermissions",
        "Action" : [
          "s3:DeleteObject",
          "s3:PutObjectVersionAcl",
          "s3:PutObjectTagging",
          "s3:PutObjectAcl",
          "s3:PutObject",
          "s3:ListMultipartUploadParts"
        ],
        "Effect" : "Allow",
        "Resource" : [
          "arn:aws:s3:::*/*"
        ]
      },
      {
        "Sid" : "S3KMSPermissions",
        "Action" : [
          "kms:Decrypt",
          "kms:DescribeKey",
          "kms:GenerateDataKey"
        ],
        "Effect" : "Allow",
        "Resource" : "*",
        "Condition" : {
          "StringLike" : {
            "kms:ViaService" : "s3.*.amazonaws.com"
          }
        }
      }
    ]
  })
  tags = merge(module.backup_workload_env.tags, var.additional_tags)
} # EventBridge Rules and Monitoring (Part 2 of dynamic main.tf)

# CloudWatch Event Rules for backup monitoring
resource "aws_cloudwatch_event_rule" "backup_fail_event_rule" {
  name        = "automatic-aws-backup-fail-alert"
  description = "EventRule for backup failures"

  event_pattern = jsonencode({
    "source" : ["aws.backup"],
    "detail-type" : ["Backup Job State Change"],
    "detail" : {
      "backupVaultName" : [
        for vault_key, vault in aws_backup_vault.backup_vaults : vault.name
      ],
      "state" : ["FAILED", "COMPLETED", "EXPIRED"]
    }
  })

  tags = merge(module.backup_workload_env.tags, var.additional_tags)
}

resource "aws_cloudwatch_event_rule" "backup_copy_restore_job_rule" {
  name        = "automatic-aws-backup-copy-restore-alert"
  description = "EventRule for backup copy and restore jobs"

  event_pattern = jsonencode({
    "source" : ["aws.backup"],
    "detail-type" : ["Copy Job State Change", "Restore Job State Change"],
  })

  tags = merge(module.backup_workload_env.tags, var.additional_tags)
}

# Backup region settings
resource "aws_backup_region_settings" "this" {
  resource_type_opt_in_preference = var.opt_in_settings
  resource_type_management_preference = {
    "DynamoDB" = var.enable_advanced_features_for_dynamodb_backups
    "EFS"      = var.enable_advanced_features_for_efs_backups
  }

  lifecycle {
    ignore_changes = [
      resource_type_opt_in_preference["Aurora"],
      resource_type_opt_in_preference["CloudFormation"],
      resource_type_opt_in_preference["DSQL"],
      resource_type_opt_in_preference["DocumentDB"],
      resource_type_opt_in_preference["DynamoDB"],
      resource_type_opt_in_preference["EBS"],
      resource_type_opt_in_preference["EC2"],
      resource_type_opt_in_preference["EFS"],
      resource_type_opt_in_preference["EKS"],
      resource_type_opt_in_preference["FSx"],
      resource_type_opt_in_preference["Neptune"],
      resource_type_opt_in_preference["RDS"],
      resource_type_opt_in_preference["Redshift"],
      resource_type_opt_in_preference["Redshift Serverless"],
      resource_type_opt_in_preference["S3"],
      resource_type_opt_in_preference["SAP HANA on Amazon EC2"],
      resource_type_opt_in_preference["Storage Gateway"],
      resource_type_opt_in_preference["Timestream"],
      resource_type_opt_in_preference["VirtualMachine"]
    ]
  }
}
