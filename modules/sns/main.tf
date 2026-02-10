resource "aws_sns_topic" "this" {
  for_each     = { for topics in local.sns_topics_config : topics.type => topics }
  name         = each.value.name
  display_name = "${each.value.display_name}-${module.sns_env.namespace}-${module.sns_env.stage}"
  tags         = module.sns_env.tags
}

resource "aws_sns_topic_subscription" "this" {
  for_each  = { for idx, emails in local.sns_emails_config : idx => emails }
  topic_arn = aws_sns_topic.this[each.value.type].arn
  protocol  = "email"
  endpoint  = each.value.email_id
}

resource "aws_sns_topic_policy" "this" {
  for_each = toset(local.sns_keys)
  arn      = aws_sns_topic.this[each.value].arn
  policy   = data.aws_iam_policy_document.this[each.value].json
}
