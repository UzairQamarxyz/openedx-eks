resource "aws_s3_bucket" "bucket" {
  count  = var.force_destroy == false ? 1 : 0
  bucket = "${var.bucket_duty}-${module.s3_env.id}-${lookup(local.region_mappings, data.aws_region.current.region, local.module_name)}"

  force_destroy = var.force_destroy
  lifecycle {
    prevent_destroy = true
  }
  tags = merge(module.s3_env.tags, tomap(
    var.bucket_versioning == "Enabled" ? {
      "backup" = var.backup_type
    } :
    {
      "backup"               = var.backup_type
      "no_versioning_needed" = "true"
    }
  ))
}

resource "aws_s3_bucket" "not_protected_bucket" {
  count  = var.force_destroy == true ? 1 : 0
  bucket = "${var.bucket_duty}-${module.s3_env.id}-${lookup(local.region_mappings, data.aws_region.current.region, local.module_name)}"

  force_destroy = var.force_destroy
  tags = merge(module.s3_env.tags, tomap(
    var.bucket_versioning == "Enabled" ? {
      "backup" = var.backup_type
    } :
    {
      "backup"               = var.backup_type
      "no_versioning_needed" = "true"
    }
  ))
}

resource "aws_s3_bucket_lifecycle_configuration" "this" {
  bucket = var.force_destroy ? aws_s3_bucket.not_protected_bucket[0].id : aws_s3_bucket.bucket[0].id

  rule {
    id     = "non-current-version-transition"
    status = var.bucket_versioning

    filter {
      prefix = ""
    }

    dynamic "noncurrent_version_transition" {
      for_each = var.enable_noncurrent_version_transition ? [1] : []
      content {
        noncurrent_days = var.non_current_version_transition_in_days
        storage_class   = "GLACIER"

      }
    }

    dynamic "noncurrent_version_expiration" {
      for_each = var.enable_noncurrent_version_expiration ? [1] : []
      content {
        noncurrent_days = var.non_current_version_expiration_in_days

      }
    }
    abort_incomplete_multipart_upload {
      days_after_initiation = var.expired_objects_deletion_days
    }
    expiration {
      expired_object_delete_marker = true
    }
  }
  rule {
    id     = "intelligent-tiering"
    status = var.intelligent_tiering

    filter {
      prefix = ""
    }

    transition {
      days          = 0
      storage_class = "INTELLIGENT_TIERING"
    }
  }
  dynamic "rule" {
    for_each = var.bucket_duty == "logs" ? [1] : []
    content {
      id     = "expire-canary-logs"
      status = "Enabled"

      filter {
        prefix = "canary/"
      }

      expiration {
        days = 60
      }
    }
  }
}

resource "aws_s3_bucket_versioning" "this" {
  bucket = var.force_destroy ? aws_s3_bucket.not_protected_bucket[0].id : aws_s3_bucket.bucket[0].id

  versioning_configuration {
    status = var.bucket_versioning
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  bucket = var.force_destroy ? aws_s3_bucket.not_protected_bucket[0].id : aws_s3_bucket.bucket[0].id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = var.kms_key_id != "" ? var.kms_key_id : data.aws_kms_alias.aws_managed_s3_key.target_key_arn
      sse_algorithm     = "aws:kms"
    }
    bucket_key_enabled = var.bucket_key_enabled
  }
}

resource "aws_s3_bucket_public_access_block" "block_public_access" {
  count                   = var.block_public_access ? 1 : 0
  bucket                  = var.force_destroy ? aws_s3_bucket.not_protected_bucket[0].id : aws_s3_bucket.bucket[0].id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_policy" "cloudwatch_logs_write_access" {
  count  = var.bucket_duty == "logs" ? 1 : 0
  bucket = var.force_destroy ? aws_s3_bucket.not_protected_bucket[0].id : aws_s3_bucket.bucket[0].id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "s3:GetBucketAcl"
        Effect = "Allow"
        Principal = {
          Service = "cloudtrail.amazonaws.com"
        }
        Resource = "arn:aws:s3:::${var.force_destroy ? aws_s3_bucket.not_protected_bucket[0].id : aws_s3_bucket.bucket[0].id}"
      },
      {
        Action = "s3:PutObject"
        Effect = "Allow"
        Principal = {
          Service = "cloudtrail.amazonaws.com"
        }
        Resource = ["arn:aws:s3:::${var.force_destroy ? aws_s3_bucket.not_protected_bucket[0].id : aws_s3_bucket.bucket[0].id}/AWSLogs/${data.aws_caller_identity.current.account_id}/*"],
      },
      {
        Action = "s3:PutObject"
        Effect = "Allow"
        Principal = {
          Service = ["delivery.logs.amazonaws.com", "logs.amazonaws.com"]
        }
        Condition = {
          StringEquals = {
            "s3:x-amz-acl" = "bucket-owner-full-control"
          }
        }
        Resource = "${var.force_destroy ? aws_s3_bucket.not_protected_bucket[0].arn : aws_s3_bucket.bucket[0].arn}/*"
      },
      {
        Action = "s3:GetBucketAcl"
        Effect = "Allow"
        Principal = {
          Service = ["delivery.logs.amazonaws.com", "logs.amazonaws.com"]
        }
        Resource = var.force_destroy ? aws_s3_bucket.not_protected_bucket[0].arn : aws_s3_bucket.bucket[0].arn
      }
    ]
  })
}
