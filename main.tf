module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "4.0.2"

  name                 = var.project_name
  cidr                 = var.vpc_cidr
  azs                  = ["${var.aws_region}a", "${var.aws_region}b"]
  public_subnets       = var.public_subnets
  private_subnets      = var.private_subnets
  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = { Project = var.project_name }
}

resource "aws_security_group" "bastion_sg" {
  name   = "${var.project_name}-bastion-sg"
  vpc_id = module.vpc.vpc_id

  ingress {
    description = "SSH from my IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/32"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "bastion" {
  ami                         = var.bastion_ami
  instance_type               = var.bastion_instance_type
  key_name                    = var.bastion_key_name
  subnet_id                   = module.vpc.public_subnets[0]
  vpc_security_group_ids      = [aws_security_group.bastion_sg.id]
  associate_public_ip_address = true
  tags = { Name = "${var.project_name}-bastion" }
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "20.3.0"

  cluster_name    = "${var.project_name}-eks"
  cluster_version = "1.28"
  subnets         = module.vpc.private_subnets
  vpc_id          = module.vpc.vpc_id

  node_groups = {
    eks_nodes = {
      desired_capacity = var.eks_node_desired_capacity
      min_capacity     = var.eks_node_min_capacity
      max_capacity     = var.eks_node_max_capacity
      instance_type    = var.eks_node_instance_type
      key_name         = var.bastion_key_name
      subnet_ids       = module.vpc.private_subnets
    }
  }

  tags = { Project = var.project_name }
}

resource "aws_ecr_repository" "this" {
  name                 = "${var.project_name}-repo"
  image_tag_mutability = "MUTABLE"
  tags                 = { Project = var.project_name }
}

resource "aws_codeartifact_domain" "this" {
  domain = "${var.project_name}-domain"
  tags   = { Project = var.project_name }
}

resource "aws_codeartifact_repository" "this" {
  repository = "${var.project_name}-repo"
  domain     = aws_codeartifact_domain.this.domain
  tags       = { Project = var.project_name }
}

