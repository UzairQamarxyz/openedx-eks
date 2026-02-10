data "aws_route53_zone" "selected" {
  name         = var.dns_hosted_zone_name
  private_zone = false
}

