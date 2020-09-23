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