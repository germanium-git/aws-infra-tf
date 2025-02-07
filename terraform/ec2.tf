locals {
  ec2_instance_configs = {
    ec2-01 = {
      subnet_id              = module.vpc.vpc1.public_subnet_objects[0].id
      vpc_security_group_ids = [module.vpc.vpc1.default_security_group_id]
    }
  }
}


module "ec2_instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "5.7.1"

  for_each = local.ec2_instance_configs

  name = each.key

  associate_public_ip_address = true
  instance_type               = "t2.micro"
  key_name                    = aws_key_pair.ec2_key.key_name
  monitoring                  = false
  vpc_security_group_ids      = each.value.vpc_security_group_ids
  subnet_id                   = each.value.subnet_id

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}


