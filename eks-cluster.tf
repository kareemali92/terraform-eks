resource "aws_eks_cluster" "mycluster" {
  name     = "${local.cluster_name}"
  role_arn = "${aws_iam_role.cluster.arn}"

  vpc_config {
    security_group_ids = ["${aws_security_group.cluster.id}"]
    subnet_ids         = module.vpc.private_subnets
  }
}