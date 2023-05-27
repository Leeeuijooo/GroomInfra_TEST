module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "19.10.0"

  cluster_name    = var.eks_name # variables.tf 에 있는 변수선언
  cluster_version = "1.24"


  vpc_id                         = module.vpc.vpc_id # vpc.tf 에 있는 vpc id 끌어오기
  subnet_ids                     = module.vpc.private_subnets
  cluster_endpoint_public_access = true

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
      subnets = module.vpc.private_subnets[0]
    }

    two = {
      name = "node-group-2"

      instance_types = ["t2.medium"]

      min_size     = 1
      max_size     = 2
      desired_size = 1
      subnets = module.vpc.private_subnets[1]
    }
  }
}