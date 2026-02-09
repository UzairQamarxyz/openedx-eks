# Changelog

All notable changes to this example will be documented in this file.

## [Latest] - 2025-02-09

### Changed

- **S3 Bucket Naming**: Replaced account ID with random 8-character suffix
  - Old format: `ex-auto-mode-community-logs-123456789012`
  - New format: `ex-auto-mode-community-logs-a7b3c9d2`
  - Benefits:
    - No account ID exposure in bucket names
    - Still globally unique
    - Shorter bucket names
    - More secure

### Added

- Random provider (>= 3.6) for bucket suffix generation
- `random_string` resource for generating unique bucket suffixes
- `random_suffix` local variable for consistent suffix usage
- Documentation about random suffix in README and POLICY_VERIFICATION

### Removed

- Account ID from S3 bucket names (still used internally for KMS policies)
- Null provider (not needed, replaced with random provider)

### Technical Details

#### Before

```hcl
bucket = "${local.name}-${each.key}-${data.aws_caller_identity.current.account_id}"
# Result: ex-auto-mode-community-logs-123456789012
```

#### After

```hcl
resource "random_string" "bucket_suffix" {
  length  = 8
  special = false
  upper   = false
}

bucket = "${local.name}-${each.key}-${local.random_suffix}"
# Result: ex-auto-mode-community-logs-a7b3c9d2
```

### Security Improvements

- ✅ No account ID exposure in resource names
- ✅ Random suffix prevents predictable bucket names
- ✅ Maintains global uniqueness requirement for S3
- ✅ Account ID still used where needed (KMS policies, IAM)

### Migration Notes

If you have existing infrastructure deployed with the old naming:

1. **Option 1: Recreate (Recommended for test environments)**

   ```bash
   terraform destroy
   terraform apply
   ```

2. **Option 2: State Migration (For production)**

   ```bash
   # Export data from old buckets
   aws s3 sync s3://old-bucket-name s3://new-bucket-name
   
   # Update state
   terraform state rm module.s3_buckets[\"logs\"]
   terraform import module.s3_buckets[\"logs\"].aws_s3_bucket.this[0] new-bucket-name
   ```

3. **Option 3: Keep Old Names**
   - Override the bucket name in terraform.auto.tfvars
   - Not recommended as it defeats the purpose of the change

## Version History

### Initial Release

- EKS Auto Mode example with community modules
- Consolidated S3 bucket module with for_each
- Enhanced KMS policies
- Comprehensive documentation
