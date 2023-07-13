locals {
  aws_lb_controller = yamlencode({
    "region" : var.aws_region,
    "enableShield" : false,
    "enableWaf" : false,
    "enableWafv2" : false,
    "defaultSSLPolicy" : var.aws_ssl_policy,
    "vpcId" : data.terraform_remote_state.network.outputs.vpc.main.vpc_id,
    "clusterName" : data.terraform_remote_state.eks.outputs.eks_cluster_id,
    "serviceAccount" : {
      "name" : local.default_name
      "annotations" : {
        "eks.amazonaws.com/role-arn" : module.aws_lb_controller_iam_role.iam_role_arn
      }
    },
    "clusterSecretsPermissions" : {
      "allowAllSecrets" : true
    }
  })

  aws_lb_controller_crds_extra_values = yamlencode({
    "status" : {
      "acceptedNames" : {
        "kind" : "",
        "plural" : "",
      },
      "conditions" : [],
      "storedVersions" : []
    }
  })

  aws_lb_controller_chart_name = "aws-load-balancer-controller"
  incubator = {
    "repository" = "https://charts.helm.sh/incubator"
    chart        = "raw"
  }
  default_name                = "aws-lb-controller-sa"
  aws_lb_controller_crds_name = "aws-load-balancer-controller-crds"
  crds_url                    = "https://raw.githubusercontent.com/aws/eks-charts/master/stable/aws-load-balancer-controller/crds/crds.yaml"
  name                        = length(var.sa_role_name) > 0 || var.sa_role_name != null ? var.sa_role_name : "eks-${local.default_name}"
}





