data "aws_eks_cluster" "cluster" {
  name = "${var.eks-name}"
}

data "aws_eks_cluster_auth" "cluster" {
  name = "${var.eks-name}"
}

provider "helm" {
  kubernetes {
    host     = data.aws_eks_cluster.cluster.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
    token                  = data.aws_eks_cluster_auth.cluster.token
    load_config_file       = false
  }
}
