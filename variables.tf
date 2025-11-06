variable "aws_region" { default = "us-east-1" }
variable "project_name" { default = "java-springboot-app" }
variable "bastion_key_name" { description = "Existing EC2 keypair name" }

variable "vpc_cidr" { default = "10.0.0.0/16" }
variable "private_subnets" { default = ["10.0.1.0/24", "10.0.2.0/24"] }
variable "public_subnets" { default = ["10.0.101.0/24", "10.0.102.0/24"] }

variable "eks_node_instance_type" { default = "t3.medium" }
variable "eks_node_desired_capacity" { default = 2 }
variable "eks_node_min_capacity" { default = 1 }
variable "eks_node_max_capacity" { default = 3 }

variable "bastion_instance_type" { default = "t3.micro" }
variable "bastion_ami" { default = "ami-0dc2d3e4c0f9ebd18" } # Ubuntu 22.04 LTS
