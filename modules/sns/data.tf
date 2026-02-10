data "aws_iam_policy_document" "this" {
  for_each = toset(local.sns_keys)

  policy_id = "sns_publish_alerts_policy"

  statement {
    sid    = "publish_to_alerts_statement"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    actions = [
      "SNS:Publish"
    ]
    resources = [aws_sns_topic.this[each.value].arn]
  }
}
