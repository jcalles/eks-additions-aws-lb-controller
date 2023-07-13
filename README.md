## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.14 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |
| <a name="provider_helm"></a> [helm](#provider\_helm) | n/a |
| <a name="provider_http"></a> [http](#provider\_http) | n/a |
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | n/a |
| <a name="provider_terraform"></a> [terraform](#provider\_terraform) | n/a |
| <a name="provider_utils"></a> [utils](#provider\_utils) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_aws_lb_controller_iam_role"></a> [aws\_lb\_controller\_iam\_role](#module\_aws\_lb\_controller\_iam\_role) | git::https://github.com/cloudposse/terraform-aws-eks-iam-role.git | tags/0.2.0 |

## Resources

| Name | Type |
|------|------|
| [helm_release.aws_lb_controller](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [helm_release.aws_lb_controller_crds](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [aws_eks_cluster.eks](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/eks_cluster) | data source |
| [aws_eks_cluster_auth.eks](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/eks_cluster_auth) | data source |
| [aws_iam_policy_document.lb_controller](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [http_http.crds](https://registry.terraform.io/providers/hashicorp/http/latest/docs/data-sources/http) | data source |
| [kubernetes_namespace.namespace](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/data-sources/namespace) | data source |
| [terraform_remote_state.eks](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/data-sources/remote_state) | data source |
| [terraform_remote_state.network](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/data-sources/remote_state) | data source |
| [utils_deep_merge_yaml.aws_lb_controller](https://registry.terraform.io/providers/cloudposse/utils/latest/docs/data-sources/deep_merge_yaml) | data source |
| [utils_deep_merge_yaml.aws_lb_controller_crds](https://registry.terraform.io/providers/cloudposse/utils/latest/docs/data-sources/deep_merge_yaml) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_additional_iam_policy_statements"></a> [additional\_iam\_policy\_statements](#input\_additional\_iam\_policy\_statements) | Map of IAM policy statements to use in the policy. | `any` | `{}` | no |
| <a name="input_aws_lb_controller_chart"></a> [aws\_lb\_controller\_chart](#input\_aws\_lb\_controller\_chart) | Helm chart values for AWS LB controller | `map(string)` | <pre>{<br>  "repository": "https://aws.github.io/eks-charts",<br>  "version": "1.5.3"<br>}</pre> | no |
| <a name="input_aws_lb_controller_crds_extra_values"></a> [aws\_lb\_controller\_crds\_extra\_values](#input\_aws\_lb\_controller\_crds\_extra\_values) | Additional settings which will be passed to the Helm chart values : aws\_lb\_controller\_crds\_extra\_values | `map(any)` | `{}` | no |
| <a name="input_aws_lb_controller_enabled"></a> [aws\_lb\_controller\_enabled](#input\_aws\_lb\_controller\_enabled) | enable alb controller | `bool` | `false` | no |
| <a name="input_aws_lb_controller_extra_values"></a> [aws\_lb\_controller\_extra\_values](#input\_aws\_lb\_controller\_extra\_values) | Additional settings which will be passed to the Helm chart values: aws\_lb\_controller | `map(any)` | `{}` | no |
| <a name="input_aws_lb_controller_ingressclass_extra_values"></a> [aws\_lb\_controller\_ingressclass\_extra\_values](#input\_aws\_lb\_controller\_ingressclass\_extra\_values) | Additional settings which will be passed to the Helm chart values : aws-load-balancer-controller-ingressclass | `map(any)` | `{}` | no |
| <a name="input_aws_lb_controller_settings"></a> [aws\_lb\_controller\_settings](#input\_aws\_lb\_controller\_settings) | Additional settings which will be passed to the Helm chart values, see https://artifacthub.io/packages/helm/bitnami/metrics-server | `map(any)` | `{}` | no |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | n/a | `any` | n/a | yes |
| <a name="input_aws_ssl_policy"></a> [aws\_ssl\_policy](#input\_aws\_ssl\_policy) | ELBSecurityPolicy | `string` | `"ELBSecurityPolicy-TLS-1-2-2017-01"` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | Namespace, which could be your organization name, e.g. 'eg' or 'cp' | `string` | n/a | yes |
| <a name="input_sa_role_name"></a> [sa\_role\_name](#input\_sa\_role\_name) | the default name for AWS IAM role | `string` | `"eks-aws-lb-controller-sa"` | no |
| <a name="input_skip_crds"></a> [skip\_crds](#input\_skip\_crds) | If set, no CRDs will be installed. By default, CRDs are installed if not already present | `bool` | `false` | no |
| <a name="input_stage"></a> [stage](#input\_stage) | Stage, e.g. 'prod', 'staging', 'dev' or 'testing' | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Additional tags (e.g. `map('BusinessUnit`,`XYZ`) | `map(string)` | `{}` | no |
| <a name="input_tf_bucket"></a> [tf\_bucket](#input\_tf\_bucket) | n/a | `any` | n/a | yes |

## Outputs

No outputs.
