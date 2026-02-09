data "aws_caller_identity" "current" {}
data "aws_region" "current" {}
data "aws_kms_alias" "aws_managed_s3_key" {
  name = "alias/aws/s3"
}
