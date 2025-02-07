# Declare the data source
data "aws_availability_zones" "available" {
  state = "available"
}



locals {
  my_ip = "185.230.172.74/32"
  vpc_configs = {
    vpc1 = {
      cidr            = "10.0.0.0/16"
      public_subnets  = [cidrsubnet("10.0.0.0/16", 8, 1)]
      private_subnets = [cidrsubnet("10.0.0.0/16", 8, 128)]
      default_security_group_ingress = [
        {
          cidr_blocks = local.my_ip
          description = "SSH"
          from_port   = 22
          to_port     = 22
          protocol    = "tcp"
        }
      ]
    }
    vpc2 = {
      cidr           = "10.1.0.0/16"
      public_subnets = [cidrsubnet("10.1.0.0/16", 8, 1)]
    }
  }
}


module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.18.1"

  for_each                       = local.vpc_configs
  name                           = each.key
  cidr                           = each.value.cidr
  azs                            = data.aws_availability_zones.available.names
  public_subnets                 = lookup(each.value, "public_subnets", [])
  private_subnets                = lookup(each.value, "private_subnets", [])
  default_security_group_ingress = lookup(each.value, "default_security_group_ingress", [])
}

