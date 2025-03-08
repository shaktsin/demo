module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.0.0"

  name = var.cluster_name

  cidr = var.vpc_cidr
  azs  = ["${var.region}a", "${var.region}b", "${var.region}c"]

  private_subnets = slice(cidrsubnets(var.vpc_cidr, var.subnet_addbits, var.subnet_addbits, var.subnet_addbits, var.subnet_addbits, var.subnet_addbits, var.subnet_addbits), 0, 3)
  public_subnets  = slice(cidrsubnets(var.vpc_cidr, var.subnet_addbits, var.subnet_addbits, var.subnet_addbits, var.subnet_addbits, var.subnet_addbits, var.subnet_addbits), 3, 6)

  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true

  public_subnet_tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                    = 1
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"           = 1
  }
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "19.15.3"

  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version

  vpc_id                         = module.vpc.vpc_id
  subnet_ids                     = module.vpc.private_subnets
  cluster_endpoint_public_access = true

  eks_managed_node_group_defaults = {
    ami_type = var.eks_ami_type

  }

  eks_managed_node_groups = {
    one = {
      name = "node-group-1"

      instance_types = [var.eks_ami_variant]

      min_size     = var.eks_node_group.min_size
      max_size     = var.eks_node_group.max_size
      desired_size = var.eks_node_group.desired_size
    }

    two = {
      name = "node-group-2"

      instance_types = [var.eks_ami_variant]

      min_size     = var.eks_node_group.min_size
      max_size     = var.eks_node_group.max_size
      desired_size = var.eks_node_group.desired_size
    }
  }
}

resource "kubernetes_service_account" "service_account" {
  metadata {
    name      = "aws-load-balancer-controller"
    namespace = "kube-system"
    labels = {
      "app.kubernetes.io/name"      = "aws-load-balancer-controller"
      "app.kubernetes.io/component" = "controller"
    }
    annotations = {
      "eks.amazonaws.com/role-arn"               = aws_iam_role.ingress-roless.arn
      "eks.amazonaws.com/sts-regional-endpoints" = "true"
    }
  }
}

resource "helm_release" "alb_controller" {
  name       = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  namespace  = "kube-system"
  depends_on = [
    kubernetes_service_account.service_account
  ]

  set {
    name  = "region"
    value = var.region
  }

  set {
    name  = "vpcId"
    value = module.vpc.vpc_id
  }

  set {
    name  = "image.repository"
    value = "${var.eks_add_on_repo}.dkr.ecr.${var.region}.amazonaws.com/amazon/aws-load-balancer-controller"
  }

  set {
    name  = "serviceAccount.create"
    value = "false"
  }

  set {
    name  = "serviceAccount.name"
    value = "aws-load-balancer-controller"
  }

  set {
    name  = "clusterName"
    value = var.cluster_name
  }
}