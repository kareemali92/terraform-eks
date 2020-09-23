output "region" {
  description = "AWS region"
  value       = var.region
}

output "cluster_name" {
  description = "Kubernetes Cluster Name"
  value       = local.cluster_name
}

output "security_group_cluster" {
  value = "${aws_security_group.cluster.id}"
}

output "security_group_node" {
  value = "${aws_security_group.node.id}"
}

output "iam_cluster_arn" {
  value = "${aws_iam_role.cluster.arn}"
}

output "iam_instance_profile" {
  value = "${aws_iam_instance_profile.node.name}"
}

output "iam_node_arn" {
  value = "${aws_iam_role.node.arn}"
}

## EKS-cluster output
#####
locals {
  config_map_aws_auth = <<CONFIGMAPAWSAUTH
apiVersion: v1
kind: ConfigMap
metadata:
  name: aws-auth
  namespace: kube-system
data:
  mapRoles: |
    - rolearn: ${aws_iam_role.cluster.arn}
      username: system:node:{{EC2PrivateDNSName}}
      groups:
        - system:bootstrappers
        - system:nodes
CONFIGMAPAWSAUTH

  kubeconfig = <<KUBECONFIG
apiVersion: v1
clusters:
- cluster:
    server: ${aws_eks_cluster.mycluster.endpoint}
    certificate-authority-data: ${aws_eks_cluster.mycluster.certificate_authority.0.data}
  name: kubernetes
contexts:
- context:
    cluster: kubernetes
    user: aws
  name: aws
current-context: aws
kind: Config
preferences: {}
users:
- name: aws
  user:
    exec:
      apiVersion: client.authentication.k8s.io/v1alpha1
      command: aws-iam-authenticator
      args:
        - "token"
        - "-i"
        - "${aws_eks_cluster.mycluster.name}"
KUBECONFIG
}

output "config_map_aws_auth" {
  value = "${local.config_map_aws_auth}"
}

output "kubeconfig" {
  value = "${local.kubeconfig}"
}

output "eks_certificate_authority" {
  value = "${aws_eks_cluster.mycluster.certificate_authority.0.data}"
}

output "eks_endpoint" {
  value = "${aws_eks_cluster.mycluster.endpoint}"
}

output "eks_cluster_name" {
  value = "${aws_eks_cluster.mycluster.name}"
}
