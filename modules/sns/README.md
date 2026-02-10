<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0 |
| aws | >= 6.0.0 |

## Providers

| Name | Version |
|------|---------|
| aws | >= 6.0.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| sns\_env | cloudposse/label/null | 0.25.0 |

## Resources

| Name | Type |
|------|------|
| [aws_sns_topic.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic) | resource |
| [aws_sns_topic_policy.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic_policy) | resource |
| [aws_sns_topic_subscription.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic_subscription) | resource |
| [aws_iam_policy_document.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| env\_vars | Map of environment variables to be used for labeling and tagging resources. Expected keys include: - "namespace": The namespace for resource labeling (default: "alnafi") - "stage": The stage/environment (e.g., "dev", "test", "prod - "delimiter": The delimiter to use in labels (default: "-") | `map(string)` | `{}` | no |
| subscriber\_email\_addresses | Email addresses for sns topics | `map(list(string))` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| alerts\_topic\_arn | The name of topic created for alerts |
| critical\_alerts\_topic\_arn | The name of topic created for critical alerts |
| events\_topic\_arn | The name of the topic created for events |
| pipeline\_events\_topic\_arn | The name of the topic created for pipeline events |
<!-- END_TF_DOCS -->