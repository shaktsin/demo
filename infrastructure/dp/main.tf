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

data "aws_iam_policy" "ebs_csi_policy" {
  arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
}

module "irsa_ebs_csi" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version = "4.7.0"

  create_role                   = true
  role_name                     = "AmazonEKSTFEBSCSIRole-${module.eks.cluster_name}"
  provider_url                  = module.eks.oidc_provider
  role_policy_arns              = [data.aws_iam_policy.ebs_csi_policy.arn]
  oidc_fully_qualified_subjects = ["system:serviceaccount:kube-system:ebs-csi-controller-sa"]
}

resource "aws_eks_addon" "ebs_csi" {
  cluster_name             = module.eks.cluster_name
  addon_name               = "aws-ebs-csi-driver"
  addon_version            = "v1.20.0-eksbuild.1"
  service_account_role_arn = module.irsa_ebs_csi.iam_role_arn
  tags = {
    "eks_addon" = "ebs-csi"
    "terraform" = "true"
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
      "eks.amazonaws.com/role-arn"               = module.irsa_ebs_csi.iam_role_arn
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

# resource "kubernetes_namespace" "test_app" {
#   metadata {
#     name = var.app_namespace
#   }
# }

# resource "helm_release" "test_app" {
#   name       = var.app_name
#   repository = "https://charts.bitnami.com/bitnami"
#   chart      = "nginx"
#   version    = "18.0.0"
#   namespace  = var.app_namespace

#   values = [
#     file("${path.module}/nginx-variables.yaml")
#   ]
# }

# data "kubernetes_service" "test_app" {
#   depends_on = [helm_release.test_app]
#   metadata {
#     name      = var.app_name
#     namespace = var.app_namespace
#   }
# }