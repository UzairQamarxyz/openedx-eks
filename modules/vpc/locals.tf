locals {
  module_name = "vpc"
  azs         = slice(data.aws_availability_zones.available.names, 0, 3)
}
