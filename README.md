# 🏗️ terraform-aws-security-group

[![OpsStation](https://img.shields.io/badge/Made%20by-OpsStation-blue?style=flat-square&logo=terraform)](https://www.opsstation.com)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Terraform](https://img.shields.io/badge/Terraform-1.13%2B-purple.svg?logo=terraform)](#)
[![CI](https://github.com/OpsStation/terraform-multicloud-labels/actions/workflows/ci.yml/badge.svg)](https://github.com/OpsStation/terraform-multicloud-labels/actions/workflows/ci.yml)

> 🌩️ **A production-grade, reusable AWS Subnet module by [OpsStation](https://www.opsstation.com)**
> Designed for reliability, performance, and security — following AWS networking best practices.
---

## 🏢 About OpsStation

**OpsStation** delivers **Cloud & DevOps excellence** for modern teams:
- 🚀 **Infrastructure Automation** with Terraform, Ansible & Kubernetes
- 💰 **Cost Optimization** via scaling & right-sizing
- 🛡️ **Security & Compliance** baked into CI/CD pipelines
- ⚙️ **Fully Managed Operations** across AWS, Azure, and GCP

> 💡 Need enterprise-grade DevOps automation?
> 👉 Visit [**www.opsstation.com**](https://www.opsstation.com) or email **hello@opsstation.com**

---

🌟 Features

- Creates and manages AWS Security Groups
- Supports new and existing Security Groups
- Flexible ingress and egress rule management
- Allows rules with CIDR blocks, prefix lists, and security group references
- Supports both IPv4 and IPv6 traffic rules
- Enables fine-grained control for TCP, UDP, and ICMP protocols
- Compatible with VPC and cross-VPC setups
- Automatically tags resources using the Labels module
- Fully compatible with other OpsStation Terraform modules


## ⚙️ Usage Example

module "security_group" {
source      = "git::https://github.com/opsstation/terraform-aws-security-group.git?ref=v1.0.0"
name        = "app"
environment = "test"
vpc_id      = "vpc-0a1b2c3d4e5f6g7h8"

ingress_rules = [
{
description = "Allow HTTP traffic"
from_port   = 80
to_port     = 80
protocol    = "tcp"
cidr_blocks = ["0.0.0.0/0"]
},
{
description = "Allow HTTPS traffic"
from_port   = 443
to_port     = 443
protocol    = "tcp"
cidr_blocks = ["0.0.0.0/0"]
}
]

egress_rules = [
{
description = "Allow all outbound traffic"
from_port   = 0
to_port     = 0
protocol    = "-1"
cidr_blocks = ["0.0.0.0/0"]
}
]

module "security_group" {
source      = "git::https://github.com/opsstation/terraform-aws-security-group.git?ref=v1.0.0"
name        = "db"
environment = "prod"
vpc_id      = "vpc-0a1b2c3d4e5f6g7h8"

ingress_rules = [
{
description     = "Allow MySQL from self SG"
from_port       = 3306
to_port         = 3306
protocol        = "tcp"
self            = true
}
]

module "security_group" {
source      = "git::https://github.com/opsstation/terraform-aws-security-group.git?ref=v1.0.0"
name        = "backend"
environment = "staging"
vpc_id      = "vpc-0a1b2c3d4e5f6g7h8"

ingress_rules = [
{
description     = "Allow API access from ALB SG"
from_port       = 8080
to_port         = 8080
protocol        = "tcp"
security_groups = ["sg-0ab12cd34ef56gh78"]
}
]

### 🔐 Outputs (AWS KMS Module)

| Name                  | Description                                                                 |
|-----------------------|-----------------------------------------------------------------------------|
| security_group_id	    | The ID of the created or referenced Security Group.                         |
| security_group_arn	   | The ARN of the Security Group.                                           |
| security_group_name	  | The name of the Security Group.                                           |
| ingress_rule_ids	     | List of all created ingress rule IDs.                                      |
| egress_rule_ids	      | List of all created egress rule IDs.                                      |
| vpc_id	               | The VPC ID where the Security Group resides.                             |
| managedby	            | Tag identifying the managing entity (e.g., OpsStation).                     |
| tags	                 | Key-value pairs of all resource tags applied.                               |

### ☁️ Tag Normalization Rules (AWS)

| Cloud | Case      | Allowed Characters | Example                            |
|--------|-----------|------------------|------------------------------------|
| **AWS** | TitleCase | Any              | `Name`, `Environment`, `CostCenter` |

---

### 💙 Maintained by [OpsStation](https://www.opsstation.com)
> OpsStation — Simplifying Cloud, Securing Scale.