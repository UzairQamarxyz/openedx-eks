variable "env_vars" {
  type        = map(string)
  description = <<EOT
Map of environment variables to be used for labeling and tagging resources.
Expected keys include:
- "namespace": The namespace for resource labeling (default: "alnafi")
- "stage": The stage/environment (e.g., "dev", "test", "prod
- "delimiter": The delimiter to use in labels (default: "-")
EOT
  default     = {}
}


variable "backup_vaults" {
  description = "Backup vault configuration. Defines the actual vaults that will be created."
  type = map(object({
    vault_name = string # Actual AWS vault name
    vault_type = string # "short" or "long" for categorization
  }))
  default = {
    "short-vault" = {
      vault_name = "daily-weekly-monthly-quarterly-yearly-mqy-24months"
      vault_type = "short"
    }
    "long-vault" = {
      vault_name = "daily-weekly-monthly-quarterly-yearly-mqy-5years"
      vault_type = "long"
    }
  }

  validation {
    condition = alltrue([
      for vault_key, vault in var.backup_vaults : contains(["short", "long"], vault.vault_type)
    ])
    error_message = "All vault_type values must be either 'short' or 'long'."
  }
}

variable "backup_plans" {
  description = "Dynamic backup plans configuration. Each plan can be enabled/disabled and customized."
  nullable    = false
  type = map(object({
    enabled     = bool
    description = optional(string, "Backup plan managed by backup-workload module")

    # Plan naming
    plan_name  = string # The actual AWS backup plan name
    vault_type = string

    # Schedule configuration
    backup_time_offset = optional(number, 0)   # Minutes offset from base backup_time
    use_rds_schedule   = optional(bool, false) # Use RDS backup time instead of regular backup time

    # Rules configuration - each rule can be individually customized
    rules = map(object({
      enabled                 = optional(bool, true)
      rule_name               = string # User-defined rule name (AWS limit: 1-50 characters)
      retention_days          = number
      cold_storage_after_days = optional(number, null)
      schedule_expression     = string # cron expression for the backup schedule
      recovery_point_tags     = optional(map(string), {})

      # Copy action for cross-account/cross-region backups
      copy_action = optional(object({
        enabled                 = optional(bool, false)
        destination_vault_arn   = optional(string, null) # If null, will auto-generate
        retention_days          = number
        cold_storage_after_days = optional(number, null)
      }), null)
    }))

    # Tags configuration
    selection_tag_key   = string
    selection_tag_value = string
    plan_tags           = optional(map(string), {})
  }))

  # Default: the 12 pre-refactor hardcoded backup plans
  default = {
    # ──────────────────────────────────────────────────────────────
    # Short backup plan (24 months / 730 days)
    # ──────────────────────────────────────────────────────────────
    short = {
      enabled             = true
      description         = "Short-term backup plan (24 months retention)"
      plan_name           = "daily-weekly-monthly-quarterly-yearly-mqy-24months"
      vault_type          = "short"
      backup_time_offset  = 0
      use_rds_schedule    = false
      selection_tag_key   = "backup"
      selection_tag_value = "short"
      plan_tags           = { "backup" = "short" }
      rules = {
        daily = {
          rule_name           = "24Months-daily"
          retention_days      = 7
          schedule_expression = "cron(15 01 * * ? *)"
          recovery_point_tags = { "backup-rule" = "24Months-daily" }
          copy_action = {
            enabled        = true
            retention_days = 7
          }
        }
        weekly = {
          rule_name           = "24Months-weekly"
          retention_days      = 30
          schedule_expression = "cron(15 01 ? * SAT *)"
          recovery_point_tags = { "backup-rule" = "24Months-weekly" }
          copy_action = {
            enabled        = true
            retention_days = 30
          }
        }
        monthly = {
          rule_name               = "24Months-monthly"
          retention_days          = 365
          cold_storage_after_days = 91
          schedule_expression     = "cron(15 01 1 1/1 ? *)"
          recovery_point_tags     = { "Backup-rule" = "24Months-monthly" }
          copy_action = {
            enabled                 = true
            retention_days          = 365
            cold_storage_after_days = 91
          }
        }
        quarterly = {
          rule_name               = "24Months-quarterly"
          retention_days          = 730
          cold_storage_after_days = 91
          schedule_expression     = "cron(15 01 15 1/4 ? *)"
          recovery_point_tags     = { "backup-rule" = "24Months-quarterly" }
          copy_action = {
            enabled                 = true
            retention_days          = 730
            cold_storage_after_days = 91
          }
        }
        yearly = {
          rule_name               = "24Months-yearly"
          retention_days          = 730
          cold_storage_after_days = 91
          schedule_expression     = "cron(15 01 1 1 ? *)"
          recovery_point_tags     = { "backup-rule" = "24Months-yearly" }
          copy_action = {
            enabled                 = true
            retention_days          = 730
            cold_storage_after_days = 91
          }
        }
      }
    }

    # ──────────────────────────────────────────────────────────────
    # Long backup plan (5 years / 1825 days)
    # ──────────────────────────────────────────────────────────────
    long = {
      enabled             = true
      description         = "Long-term backup plan (5 years retention)"
      plan_name           = "daily-weekly-monthly-quarterly-yearly-mqy-5years"
      vault_type          = "long"
      backup_time_offset  = 0
      use_rds_schedule    = false
      selection_tag_key   = "backup"
      selection_tag_value = "long"
      plan_tags           = { "backup" = "long" }
      rules = {
        daily = {
          rule_name           = "60Months-daily"
          retention_days      = 7
          schedule_expression = "cron(15 01 * * ? *)"
          recovery_point_tags = { "backup" = "60Months-daily" }
          copy_action = {
            enabled        = true
            retention_days = 7
          }
        }
        weekly = {
          rule_name           = "60Months-weekly"
          retention_days      = 30
          schedule_expression = "cron(15 01 ? * SAT *)"
          recovery_point_tags = { "backup" = "60Months-weekly" }
          copy_action = {
            enabled        = true
            retention_days = 30
          }
        }
        monthly = {
          rule_name               = "60Months-monthly"
          retention_days          = 730
          cold_storage_after_days = 91
          schedule_expression     = "cron(15 01 1 1/1 ? *)"
          recovery_point_tags     = { "backup" = "60Months-monthly" }
          copy_action = {
            enabled                 = true
            retention_days          = 730
            cold_storage_after_days = 91
          }
        }
        quarterly = {
          rule_name               = "60Months-quarterly"
          retention_days          = 1825
          cold_storage_after_days = 91
          schedule_expression     = "cron(15 01 15 1/4 ? *)"
          recovery_point_tags     = { "backup" = "60Months-quarterly" }
          copy_action = {
            enabled                 = true
            retention_days          = 1825
            cold_storage_after_days = 91
          }
        }
        yearly = {
          rule_name               = "60Months-yearly"
          retention_days          = 1825
          cold_storage_after_days = 91
          schedule_expression     = "cron(15 01 1 1 ? *)"
          recovery_point_tags     = { "backup" = "60Months-yearly" }
          copy_action = {
            enabled                 = true
            retention_days          = 1825
            cold_storage_after_days = 91
          }
        }
      }
    }
  }

  validation {
    condition = alltrue([
      for plan_key, plan in var.backup_plans : contains(["short", "long"], plan.vault_type)
    ])
    error_message = "All backup plan vault_type values must be either 'short' or 'long'."
  }

  validation {
    condition = alltrue([
      for plan_key, plan in var.backup_plans :
      alltrue([
        for rule_key, rule in plan.rules :
        rule.retention_days > 0
      ])
    ])
    error_message = "All backup plan rules must have retention_days greater than 0."
  }

  validation {
    condition = alltrue([
      for plan_key, plan in var.backup_plans :
      alltrue([
        for rule_key, rule in plan.rules :
        rule.copy_action != null ? rule.copy_action.retention_days > 0 : true
      ])
    ])
    error_message = "All copy actions must have retention_days greater than 0 when enabled."
  }

  validation {
    condition = alltrue([
      for plan_key, plan in var.backup_plans :
      alltrue([
        for rule_key, rule in plan.rules :
        length(rule.rule_name) >= 1 && length(rule.rule_name) <= 50
      ])
    ])
    error_message = "All backup rule names must be between 1 and 50 characters long (AWS limit)."
  }
}

variable "additional_tags" {
  description = "Additional tags to apply to all resources"
  type        = map(string)
  default     = {}
}

variable "use_sqs_for_notifications" {
  description = "Use SQS instead of SNS for backup notifications"
  type        = bool
  default     = true
}

variable "sns_topic_arn" {
  description = "SNS topic ARN for backup notifications"
  type        = string
}

variable "max_backup_runtime" {
  description = "Maximum runtime for backup jobs in minutes"
  type        = number
  default     = 720
}

variable "opt_in_settings" {
  description = "Resource type opt-in preferences for AWS Backup"
  type        = map(bool)
  default = {
    "Aurora"                 = true
    "DocumentDB"             = true
    "DynamoDB"               = true
    "EBS"                    = true
    "EFS"                    = true
    "FSx"                    = true
    "Redshift"               = true
    "S3"                     = true
    "CloudFormation"         = false
    "EC2"                    = true
    "Neptune"                = true
    "RDS"                    = true
    "VirtualMachine"         = true
    "Timestream"             = true
    "Storage Gateway"        = true
    "SAP HANA on Amazon EC2" = false
    "EKS"                    = true
  }
}

variable "enable_advanced_features_for_dynamodb_backups" {
  description = "Enable advanced features for DynamoDB backups (e.g., point-in-time recovery)"
  type        = bool
  default     = true
}

variable "enable_advanced_features_for_efs_backups" {
  description = "Enable advanced features for EFS backups (e.g., backup policies)"
  type        = bool
  default     = true
}
