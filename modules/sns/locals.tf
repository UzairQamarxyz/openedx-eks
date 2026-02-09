locals {
  module_name = "sns"
  sns_keys    = ["alerts", "critical_alerts", "events", "pipeline_events"]

  sns_topics_config = flatten([
    for types in local.sns_keys : {
      type         = types
      name         = format("${module.sns_env.id}-AWS-%s", title(replace(types, "_", "-")))
      display_name = title(replace(types, "_", " "))
    }
  ])
  email_nums = flatten([
    for types in local.sns_keys : {
      numbers = lookup(var.subscriber_email_addresses, types)[0] == null ? 0 : length(lookup(var.subscriber_email_addresses, types))
      type    = types
    }
  ])
  sns_emails_config = flatten([
    for ind, types in local.sns_keys : [
      for num in range(0, local.email_nums[ind].numbers, 1) : {
        email_id = element(lookup(var.subscriber_email_addresses, types), num)
        type     = types
      }
    ]
  ])
}
