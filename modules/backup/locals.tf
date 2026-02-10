locals {
  module_name = "backup-workload"

  enabled_backup_plans = {
    for plan_key, plan in var.backup_plans : plan_key => plan if plan.enabled
  }

  needed_vault_types = distinct([for plan_key, plan in local.enabled_backup_plans : plan.vault_type])
  backup_vaults = {
    for vault_key, vault in var.backup_vaults : vault.vault_type => {
      name       = vault.vault_name
      vault_type = vault.vault_type
    } if contains(local.needed_vault_types, vault.vault_type)
  }

  backup_plans_grouped = {
    for plan_key, plan in local.enabled_backup_plans : plan_key => {
      plan = plan
      rules = [
        for rule_key, rule in plan.rules : merge(rule, {
          rule_key = rule_key
        })
      ]
    }
  }
}
