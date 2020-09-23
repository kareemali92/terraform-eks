provider "aws" {
  access_key = "${var.AWS_ACCESS_KEY}"
  secret_key = "${var.AWS_SECRET_KEY}"
  region  = "${var.region}"
}

data "aws_availability_zones" "available" {}

locals {
  cluster_name = "${var.app_name}-eks-${random_string.suffix.result}"
}

resource "random_string" "suffix" {
  length  = 8
  special = false
}