data "aws_ami" "eks-worker" {
  filter {
    name   = "name"
    values = ["amazon-eks-*"]
  }
  most_recent = true
  owners = ["amazon"]
}

data "aws_region" "current" {}

data "template_file" "user_data" {
  template = "${file("userdata.tpl")}"

  vars = {
    eks_certificate_authority = "${aws_eks_cluster.mycluster.certificate_authority.0.data}"
    eks_endpoint              = "${aws_eks_cluster.mycluster.endpoint}"
    eks_cluster_name          = "${aws_eks_cluster.mycluster.name}"
    aws_region_current_name 	= "${data.aws_region.current.name}"
  }
}

resource "null_resource" "export_rendered_template" {
	provisioner "local-exec" {
	command = "cat > ./data_output.sh <<EOL\n${data.template_file.user_data.rendered}\nEOL"
	}
}

resource "aws_launch_configuration" "mycluster" {
  associate_public_ip_address = true
  iam_instance_profile        = "${aws_iam_instance_profile.node.name}"
  image_id                    = "${data.aws_ami.eks-worker.id}"
  instance_type               = "t3.micro"
  name_prefix                 = "terraform-eks"
  key_name                    = "karim"
  security_groups             = ["${aws_security_group.node.id}"]
  user_data                     = "${data.template_file.user_data.rendered}"
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "mycluster" {
  desired_capacity     = 2
  launch_configuration = "${aws_launch_configuration.mycluster.id}"
  max_size             = 3
  min_size             = 1
  name                 = "terraform-eks"
  vpc_zone_identifier  = module.vpc.private_subnets

  tag {
    key                 = "Name"
    value               = "terraform-eks"
    propagate_at_launch = true
  }

  tag {
    key                 = "kubernetes.io/cluster/${aws_eks_cluster.mycluster.name}"
    value               = "owned"
    propagate_at_launch = true
  }
}

resource "aws_autoscaling_policy" "nodes-scale-up" {
    name = "nodes-scale-up"
    scaling_adjustment = 1
    adjustment_type = "ChangeInCapacity"
    cooldown = 300
    autoscaling_group_name = "${aws_autoscaling_group.mycluster.name}"
}

resource "aws_autoscaling_policy" "nodes-scale-down" {
    name = "nodes-scale-down"
    scaling_adjustment = -1
    adjustment_type = "ChangeInCapacity"
    cooldown = 300
    autoscaling_group_name = "${aws_autoscaling_group.mycluster.name}"
}

resource "aws_cloudwatch_metric_alarm" "memory-high" {
    alarm_name = "mem-util-high-agents"
    comparison_operator = "GreaterThanOrEqualToThreshold"
    evaluation_periods = "2"
    metric_name = "MemoryUtilization"
    namespace = "System/Linux"
    period = "300"
    statistic = "Average"
    threshold = "60"
    alarm_description = "This metric monitors ec2 memory for high utilization on agent hosts"
    alarm_actions = [
        "${aws_autoscaling_policy.nodes-scale-up.arn}"
    ]
    dimensions = {
        AutoScalingGroupName = "${aws_autoscaling_group.mycluster.name}"
    }
}

resource "aws_cloudwatch_metric_alarm" "memory-low" {
    alarm_name = "mem-util-low-agents"
    comparison_operator = "LessThanOrEqualToThreshold"
    evaluation_periods = "2"
    metric_name = "MemoryUtilization"
    namespace = "System/Linux"
    period = "300"
    statistic = "Average"
    threshold = "40"
    alarm_description = "This metric monitors ec2 memory for low utilization on agent hosts"
    alarm_actions = [
        "${aws_autoscaling_policy.nodes-scale-down.arn}"
    ]
    dimensions = {
        AutoScalingGroupName = "${aws_autoscaling_group.mycluster.name}"
    }
}

resource "aws_autoscaling_policy" "cpu-nodes-scale-up" {
    name = "cpu-nodes-scale-up"
    scaling_adjustment = 1
    adjustment_type = "ChangeInCapacity"
    cooldown = 300
    autoscaling_group_name = "${aws_autoscaling_group.mycluster.name}"
}

resource "aws_autoscaling_policy" "cpu-nodes-scale-down" {
    name = "cpu-nodes-scale-down"
    scaling_adjustment = -1
    adjustment_type = "ChangeInCapacity"
    cooldown = 300
    autoscaling_group_name = "${aws_autoscaling_group.mycluster.name}"
}

resource "aws_cloudwatch_metric_alarm" "cpu-high" {
    alarm_name = "cpu-util-high-agents"
    comparison_operator = "GreaterThanOrEqualToThreshold"
    evaluation_periods = "2"
    metric_name = "CPUUtilization"
    namespace = "System/Linux"
    period = "300"
    statistic = "Average"
    threshold = "40"
    alarm_description = "This metric monitors ec2 cpu for high utilization on agent hosts"
    alarm_actions = [
        "${aws_autoscaling_policy.cpu-nodes-scale-up.arn}"
    ]
    dimensions = {
        AutoScalingGroupName = "${aws_autoscaling_group.mycluster.name}"
    }
}

resource "aws_cloudwatch_metric_alarm" "cpu-low" {
    alarm_name = "cpu-util-low-agents"
    comparison_operator = "LessThanOrEqualToThreshold"
    evaluation_periods = "2"
    metric_name = "CPUUtilization"
    namespace = "System/Linux"
    period = "300"
    statistic = "Average"
    threshold = "20"
    alarm_description = "This metric monitors ec2 cpu for low utilization on agent hosts"
    alarm_actions = [
        "${aws_autoscaling_policy.cpu-nodes-scale-down.arn}"
    ]
    dimensions = {
        AutoScalingGroupName = "${aws_autoscaling_group.mycluster.name}"
    }
}


