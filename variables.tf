variable "namespace" {
  type        = string
  description = "Namespace, which could be your organization name, e.g. 'eg' or 'cp'"
}

variable "stage" {
  type        = string
  description = "Stage, e.g. 'prod', 'staging', 'dev' or 'testing'"
}


variable "tags" {
  type        = map(string)
  default     = {}
  description = "Additional tags (e.g. `map('BusinessUnit`,`XYZ`)"
}


variable "aws_lb_controller_settings" {
  type        = map(any)
  default     = {}
  description = "Additional settings which will be passed to the Helm chart values, see https://artifacthub.io/packages/helm/bitnami/metrics-server"
}

variable "skip_crds" {
  description = "If set, no CRDs will be installed. By default, CRDs are installed if not already present"
  type        = bool
  default     = false
}

variable "aws_lb_controller_extra_values" {
  description = "Additional settings which will be passed to the Helm chart values: aws_lb_controller"
  type        = map(any)
  default     = {}
}

variable "aws_lb_controller_ingressclass_extra_values" {
  description = "Additional settings which will be passed to the Helm chart values : aws-load-balancer-controller-ingressclass"
  type        = map(any)
  default     = {}
}

variable "aws_lb_controller_crds_extra_values" {
  description = "Additional settings which will be passed to the Helm chart values : aws_lb_controller_crds_extra_values"
  type        = map(any)
  default     = {}
}

variable "aws_lb_controller_enabled" {
  description = "enable alb controller"
  type        = bool
  default     = false

}

variable "aws_ssl_policy" {
  description = "ELBSecurityPolicy"
  type        = string
  default     = "ELBSecurityPolicy-TLS-1-2-2017-01"
}

variable "aws_lb_controller_chart" {
  description = "Helm chart values for AWS LB controller"
  type        = map(string)
  default = {
    version    = "1.5.3" ## app version 	v2.5.2
    repository = "https://aws.github.io/eks-charts"
  }
}

variable "additional_iam_policy_statements" {
  type        = any
  description = "Map of IAM policy statements to use in the policy."
  default     = {}
}
variable "sa_role_name" {
  description = "the default name for AWS IAM role"
  type        = string
  default     = "eks-aws-lb-controller-sa"
}
