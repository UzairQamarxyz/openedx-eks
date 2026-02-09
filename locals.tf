locals {
  name = "openedx"

  vpc_cidr = "10.0.0.0/16"
  azs      = slice(data.aws_availability_zones.available.names, 0, 3)

  # Random suffix for S3 bucket uniqueness
  random_suffix = random_string.bucket_suffix.result
}
