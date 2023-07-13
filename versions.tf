terraform {
  required_version = ">= 0.14"

  backend "s3" {}

  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
    }
    local = {
      source = "hashicorp/local"
    }
    helm = {
      source = "hashicorp/helm"
    }
    utils = {
      source = "cloudposse/utils"
    }
    http = {
      source = "hashicorp/http"
    }
  }
}
