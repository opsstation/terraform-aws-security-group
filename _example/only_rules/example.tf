provider "aws" {
  region = "eu-west-1"
}

locals {
  name        = "app1"
  environment = "test"
}

##-----------------------------------------------------------------------------
## VPC Module Call.
##-----------------------------------------------------------------------------
module "vpc" {
  source      = "git::https://github.com/opsstation/terraform-aws-vpc.git?ref=v1.0.0"
  name        = "app11"
  environment = "test"
  cidr_block  = "10.0.0.0/16"
}

##-----------------------------------------------------------------------------
## Security Group Rules Module Call.
##-----------------------------------------------------------------------------
module "security_group_rules" {
  source      = "./../../."
  name        = local.name
  environment = local.environment
  vpc_id      = module.vpc.id
  new_sg      = true

  ## INGRESS Rules
  existing_sg_ingress_rules_with_cidr_blocks = [{
    rule_count  = 1
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["10.9.0.0/16"]
    description = "Allow ssh traffic."
    },
    {
      rule_count  = 2
      from_port   = 27017
      to_port     = 27017
      protocol    = "tcp"
      cidr_blocks = ["10.9.0.0/16"]
      description = "Allow Mongodb traffic."
    }
  ]

  ## EGRESS Rules
  existing_sg_egress_rules_with_cidr_blocks = [{
    rule_count  = 1
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["10.9.0.0/16"]
    description = "Allow ssh outbound traffic."
    },
    {
      rule_count  = 2
      from_port   = 27017
      to_port     = 27017
      protocol    = "tcp"
      cidr_blocks = ["10.9.0.0/16"]
      description = "Allow Mongodb outbound traffic."
  }]

}
