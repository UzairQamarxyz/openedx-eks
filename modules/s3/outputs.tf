output "bucket_id" {
  value       = var.force_destroy ? aws_s3_bucket.not_protected_bucket[0].id : aws_s3_bucket.bucket[0].id
  description = "S3 bucket ID."
}

output "bucket_arn" {
  value       = var.force_destroy ? aws_s3_bucket.not_protected_bucket[0].arn : aws_s3_bucket.bucket[0].arn
  description = "S3 bucket Arn."
}
