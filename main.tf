provider "aws" {
  default_tags {
    tags = {
      Environment = var.stage
      Namespace   = var.namespace
      Technology  = "Terraform"
      Env         = var.stage
    }
  }
}

variable "tf_bucket" {}

variable "aws_region" {}

data "terraform_remote_state" "eks" {
  backend = "s3"

  config = {
    bucket = var.tf_bucket
    key    = "eks-cluster/terraform.tfstate"
    region = var.aws_region
  }
}

data "terraform_remote_state" "network" {
  backend = "s3"

  config = {
    bucket = var.tf_bucket
    key    = "network/terraform.tfstate"
    region = var.aws_region
  }
}


data "aws_eks_cluster" "eks" {
  name = data.terraform_remote_state.eks.outputs.eks_cluster_id
}

data "aws_eks_cluster_auth" "eks" {
  name = data.terraform_remote_state.eks.outputs.eks_cluster_id
}

data "kubernetes_namespace" "namespace" {
  count = var.aws_lb_controller_enabled ? 1 : 0
  metadata {
    name = "kube-system"
  }
}

data "utils_deep_merge_yaml" "aws_lb_controller_crds" {
  count = var.aws_lb_controller_enabled ? 1 : 0
  input = [
    data.http.crds.response_body,
    local.aws_lb_controller_crds_extra_values
  ]
}

data "utils_deep_merge_yaml" "aws_lb_controller" {
  count = var.aws_lb_controller_enabled ? 1 : 0
  input = compact([
    local.aws_lb_controller,
    yamlencode(var.aws_lb_controller_extra_values)
  ])
}

module "aws_lb_controller_iam_role" {
  source               = "git::https://github.com/cloudposse/terraform-aws-eks-iam-role.git?ref=tags/0.2.0"
  enabled              = var.aws_lb_controller_enabled
  namespace            = var.namespace
  stage                = var.stage
  name                 = local.name
  kubernetes_namespace = data.kubernetes_namespace.namespace.0.metadata.0.name
  service_account_name = local.default_name
  eks_oidc_issuer_url  = data.terraform_remote_state.eks.outputs.eks_cluster_identity_oidc_issuer
  inline_role_policies = {
    aws-lb-controller = var.aws_lb_controller_enabled ? data.aws_iam_policy_document.lb_controller[0].json : null
  }
}

data "http" "crds" {
  url    = local.crds_url
  method = "GET"
  request_headers = {
    Accept = "application/json"
  }
}
resource "helm_release" "aws_lb_controller_crds" {
  count       = var.aws_lb_controller_enabled ? 1 : 0
  name        = local.aws_lb_controller_crds_name
  chart       = lookup(local.incubator, "chart")
  repository  = lookup(local.incubator, "repository")
  max_history = 3
  namespace   = data.kubernetes_namespace.namespace.0.metadata.0.name
  values = [
    data.utils_deep_merge_yaml.aws_lb_controller_crds[0].output
  ]
}

resource "helm_release" "aws_lb_controller" {
  count       = var.aws_lb_controller_enabled ? 1 : 0
  name        = local.aws_lb_controller_chart_name
  chart       = local.aws_lb_controller_chart_name
  repository  = lookup(var.aws_lb_controller_chart, "repository")
  version     = lookup(var.aws_lb_controller_chart, "version")
  namespace   = data.kubernetes_namespace.namespace.0.metadata.0.name
  skip_crds   = var.skip_crds
  max_history = 3
  values = [
    data.utils_deep_merge_yaml.aws_lb_controller[0].output
  ]
  depends_on = [helm_release.aws_lb_controller_crds]
}
