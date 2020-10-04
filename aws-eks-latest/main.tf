provider "aws" {
  access_key = "${var.AWS_ACCESS_KEY}"
  secret_key = "${var.AWS_SECRET_KEY}"
  region  = "${var.region}"
}

data "aws_availability_zones" "available" {}

locals {
  cluster_name = "${var.cluster-name}"
}