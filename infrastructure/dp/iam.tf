# LB-role.tf
resource "aws_iam_policy" "ingress" {
  name        = "AWSLoadBalancerControllerIAMPolicy"
  description = "AWS Load Balancer Controller IAM Policy"
  policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Effect" : "Allow",
          "Action" : [
            "iam:CreateServiceLinkedRole"
          ],
          "Resource" : "*",
          "Condition" : {
            "StringEquals" : {
              "iam:AWSServiceName" : "elasticloadbalancing.amazonaws.com"
            }
          }
        },
        {
          "Effect" : "Allow",
          "Action" : [
            "ec2:DescribeSecurityGroups",
            "ec2:GetSecurityGroupsForVpc",
            "ec2:DescribeVpcs",
            "ec2:DescribeSubnets",
            "ec2:DescribeInternetGateways"
          ],
          "Resource" : "*"
        },
        {
          "Effect" : "Allow",
          "Action" : [
            "ec2:DescribeAccountAttributes",
            "ec2:DescribeAddresses",
            "ec2:DescribeAvailabilityZones",
            "ec2:DescribeInternetGateways",
            "ec2:DescribeVpcs",
            "ec2:DescribeVpcPeeringConnections",
            "ec2:DescribeSubnets",
            "ec2:DescribeSecurityGroups",
            "ec2:DescribeInstances",
            "ec2:DescribeNetworkInterfaces",
            "ec2:DescribeTags",
            "ec2:GetCoipPoolUsage",
            "ec2:DescribeCoipPools",
            "elasticloadbalancing:DescribeLoadBalancers",
            "elasticloadbalancing:DescribeLoadBalancerAttributes",
            "elasticloadbalancing:DescribeListeners",
            "elasticloadbalancing:DescribeListenerCertificates",
            "elasticloadbalancing:DescribeSSLPolicies",
            "elasticloadbalancing:DescribeRules",
            "elasticloadbalancing:DescribeTargetGroups",
            "elasticloadbalancing:DescribeTargetGroupAttributes",
            "elasticloadbalancing:DescribeTargetHealth",
            "elasticloadbalancing:DescribeTags"
          ],
          "Resource" : "*"
        },
        {
          "Effect" : "Allow",
          "Action" : [
            "elasticloadbalancing:DescribeListeners",
            "elasticloadbalancing:DescribeListenerAttributes",
            "elasticloadbalancing:DescribeRules",
            "elasticloadbalancing:DescribeSSLPolicies",
            "elasticloadbalancing:DescribeLoadBalancers",
            "elasticloadbalancing:DescribeTargetGroups",
            "elasticloadbalancing:DescribeTargetGroupAttributes",
            "elasticloadbalancing:DescribeTags"
          ],
          "Resource" : "*"
        },
        {
          "Effect" : "Allow",
          "Action" : [
            "cognito-idp:DescribeUserPoolClient",
            "acm:ListCertificates",
            "acm:DescribeCertificate",
            "iam:ListServerCertificates",
            "iam:GetServerCertificate",
            "waf-regional:GetWebACL",
            "waf-regional:GetWebACLForResource",
            "waf-regional:AssociateWebACL",
            "waf-regional:DisassociateWebACL",
            "wafv2:GetWebACL",
            "wafv2:GetWebACLForResource",
            "wafv2:AssociateWebACL",
            "wafv2:DisassociateWebACL",
            "shield:GetSubscriptionState",
            "shield:DescribeProtection",
            "shield:CreateProtection",
            "shield:DeleteProtection"
          ],
          "Resource" : "*"
        },
        {
          "Effect" : "Allow",
          "Action" : [
            "ec2:AuthorizeSecurityGroupIngress",
            "ec2:RevokeSecurityGroupIngress"
          ],
          "Resource" : "*"
        },
        {
          "Effect" : "Allow",
          "Action" : [
            "ec2:CreateSecurityGroup"
          ],
          "Resource" : "*"
        },
        {
          "Effect" : "Allow",
          "Action" : [
            "ec2:CreateTags"
          ],
          "Resource" : "arn:aws:ec2:*:*:security-group/*",
          "Condition" : {
            "StringEquals" : {
              "ec2:CreateAction" : "CreateSecurityGroup"
            },
            "Null" : {
              "aws:RequestTag/elbv2.k8s.aws/cluster" : "false"
            }
          }
        },
        {
          "Effect" : "Allow",
          "Action" : [
            "ec2:CreateTags",
            "ec2:DeleteTags"
          ],
          "Resource" : "arn:aws:ec2:*:*:security-group/*",
          "Condition" : {
            "Null" : {
              "aws:RequestTag/elbv2.k8s.aws/cluster" : "true",
              "aws:ResourceTag/elbv2.k8s.aws/cluster" : "false"
            }
          }
        },
        {
          "Effect" : "Allow",
          "Action" : [
            "ec2:AuthorizeSecurityGroupIngress",
            "ec2:RevokeSecurityGroupIngress",
            "ec2:DeleteSecurityGroup"
          ],
          "Resource" : "*",
          "Condition" : {
            "Null" : {
              "aws:ResourceTag/elbv2.k8s.aws/cluster" : "false"
            }
          }
        },
        {
          "Effect" : "Allow",
          "Action" : [
            "elasticloadbalancing:CreateLoadBalancer",
            "elasticloadbalancing:CreateTargetGroup"
          ],
          "Resource" : "*",
          "Condition" : {
            "Null" : {
              "aws:RequestTag/elbv2.k8s.aws/cluster" : "false"
            }
          }
        },
        {
          "Effect" : "Allow",
          "Action" : [
            "elasticloadbalancing:CreateListener",
            "elasticloadbalancing:DeleteListener",
            "elasticloadbalancing:CreateRule",
            "elasticloadbalancing:DeleteRule"
          ],
          "Resource" : "*"
        },
        {
          "Effect" : "Allow",
          "Action" : [
            "elasticloadbalancing:AddTags",
            "elasticloadbalancing:RemoveTags"
          ],
          "Resource" : [
            "arn:aws:elasticloadbalancing:*:*:targetgroup/*/*",
            "arn:aws:elasticloadbalancing:*:*:loadbalancer/net/*/*",
            "arn:aws:elasticloadbalancing:*:*:loadbalancer/app/*/*"
          ],
          "Condition" : {
            "Null" : {
              "aws:RequestTag/elbv2.k8s.aws/cluster" : "true",
              "aws:ResourceTag/elbv2.k8s.aws/cluster" : "false"
            }
          }
        },
        {
          "Effect" : "Allow",
          "Action" : [
            "elasticloadbalancing:AddTags",
            "elasticloadbalancing:RemoveTags"
          ],
          "Resource" : [
            "arn:aws:elasticloadbalancing:*:*:listener/net/*/*/*",
            "arn:aws:elasticloadbalancing:*:*:listener/app/*/*/*",
            "arn:aws:elasticloadbalancing:*:*:listener-rule/net/*/*/*",
            "arn:aws:elasticloadbalancing:*:*:listener-rule/app/*/*/*"
          ]
        },
        {
          "Effect" : "Allow",
          "Action" : [
            "elasticloadbalancing:AddTags"
          ],
          "Resource" : [
            "arn:aws:elasticloadbalancing:*:*:targetgroup/*/*",
            "arn:aws:elasticloadbalancing:*:*:loadbalancer/net/*/*",
            "arn:aws:elasticloadbalancing:*:*:loadbalancer/app/*/*"
          ],
          "Condition" : {
            "StringEquals" : {
              "elasticloadbalancing:CreateAction" : [
                "CreateTargetGroup",
                "CreateLoadBalancer"
              ]
            },
            "Null" : {
              "aws:RequestTag/elbv2.k8s.aws/cluster" : "false"
            }
          }
        },
        {
          "Effect" : "Allow",
          "Action" : [
            "elasticloadbalancing:ModifyLoadBalancerAttributes",
            "elasticloadbalancing:SetIpAddressType",
            "elasticloadbalancing:SetSecurityGroups",
            "elasticloadbalancing:SetSubnets",
            "elasticloadbalancing:DeleteLoadBalancer",
            "elasticloadbalancing:ModifyTargetGroup",
            "elasticloadbalancing:ModifyTargetGroupAttributes",
            "elasticloadbalancing:DeleteTargetGroup"
          ],
          "Resource" : "*",
          "Condition" : {
            "Null" : {
              "aws:ResourceTag/elbv2.k8s.aws/cluster" : "false"
            }
          }
        },
        {
          "Effect" : "Allow",
          "Action" : [
            "elasticloadbalancing:RegisterTargets",
            "elasticloadbalancing:DeregisterTargets"
          ],
          "Resource" : "arn:aws:elasticloadbalancing:*:*:targetgroup/*/*"
        },
        {
          "Effect" : "Allow",
          "Action" : [
            "elasticloadbalancing:SetWebAcl",
            "elasticloadbalancing:ModifyListener",
            "elasticloadbalancing:AddListenerCertificates",
            "elasticloadbalancing:RemoveListenerCertificates",
            "elasticloadbalancing:ModifyRule"
          ],
          "Resource" : "*"
        }
      ]
  })
}

data "tls_certificate" "eks" {
  url = module.eks.cluster_oidc_issuer_url
}

# resource "aws_iam_openid_connect_provider" "eks" {
#   url = module.eks.cluster_oidc_issuer_url

#   client_id_list = [
#     "sts.amazonaws.com"
#   ]

#   thumbprint_list = [data.tls_certificate.eks.certificates[0].sha1_fingerprint]
# }

data "aws_iam_policy_document" "ingress-iam" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    condition {
      test     = "StringEquals"
      variable = "${replace(module.eks.cluster_oidc_issuer_url, "https://", "")}:sub"
      values   = ["system:serviceaccount:kube-system:aws-load-balancer-controller"]
    }
    principals {
      type        = "Federated"
      identifiers = [module.eks.oidc_provider_arn]
    }
  }
}

resource "aws_iam_role" "ingress-role" {
  name               = "test-ingress"
  assume_role_policy = data.aws_iam_policy_document.ingress-iam.json
}

resource "aws_iam_role_policy_attachment" "ingress" {
  role       = aws_iam_role.ingress-role.name
  policy_arn = aws_iam_policy.ingress.arn
}