locals {
  az_subnet_mapping = {
    "ap-northeast-2a" = "20.0.1.0/24"
    "ap-northeast-2c" = "20.0.2.0/24"
  }
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "19.10.0"

  cluster_name    = var.eks_name # variables.tf 에 있는 변수선언
  cluster_version = "1.24"


  vpc_id                         = module.vpc.vpc_id # vpc.tf 에 있는 vpc id 끌어오기
  subnet_ids                     = module.vpc.private_subnets
  cluster_endpoint_public_access = true

  cluster_addons = {
    coredns = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent = true
    }
    aws-ebs-csi-driver = {
      most_recent = true
    }
    
  }
  eks_managed_node_group_defaults = {
    ami_type = "AL2_x86_64"
  }

  eks_managed_node_groups = {
    one = {
      name = "node-group-1"

      instance_types = ["t2.medium"]

      min_size     = 1
      max_size     = 2
      desired_size = 1
      subnets = [local.az_subnet_mapping["ap-northeast-2a"]]
    }

    two = {
      name = "node-group-2"

      instance_types = ["t2.medium"]

      min_size     = 1
      max_size     = 2
      desired_size = 1
      subnets = [local.az_subnet_mapping["ap-northeast-2c"]]
    }
  }
}

resource "aws_security_group_rule" "allow_ingress" {
  type        = "ingress"
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = module.eks.cluster_security_group_id
}
