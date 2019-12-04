data "terraform_remote_state" "base-stack" {
  backend = "s3"
  config = {
    bucket = "@@bucket@@"
    key    = "baseSetup/terraform.tfstate"
    region = "eu-west-1"
  }
}

resource "aws_ecs_cluster" "ecs-cluster" {
  name = "${var.ClusterName}-${var.environment}"
}

data "template_file" "user_data" {
  template = "${file("templates/user_data.sh")}"

  vars {
    cluster_name = "${var.ClusterName}-${var.environment}"
  }
}

module "sns-drain-topic" {
  source = "../terraform-modules//sns"
  topic_name = "${title(var.environment)}ClusterDrainEcsTopic"
}

module "alb-internal" {
  source = "../terraform-modules//alb"
  alb_name = "${var.ClusterName}-internal"
  subnet_ids = "${split(",", lookup(data.terraform_remote_state.base-stack.SubnetIdsMap, "${var.environment}"))}"
  environment = "${var.environment}"
  certificate_arn = "${var.CertificateARN}"
  security_group = ["${aws_security_group.internal-load-balancer.id}"]
}

module "alb-external" {
  source = "../terraform-modules//alb"
  jenkins_listener = true
  alb_name = "${var.ClusterName}-external"
  subnet_ids = "${split(",", lookup(data.terraform_remote_state.base-stack.SubnetIdsMap, "${var.environment}"))}"
  environment = "${var.environment}"
  certificate_arn = "${var.CertificateARN}"
  is_internal = false
  security_group = ["${aws_security_group.external-load-balancer.id}"]
}

module "ecs-instances" {
  source = "../terraform-modules//autoscaling-group"
  environment = "${var.environment}"
  name = "${var.ClusterName}"
  aws_ami = "${var.AmiId}"
  spot_price = "0.017"
  ssh_key_name = "${var.ssh_key_name}"
  security_groups = ["${aws_security_group.cluster-sg.id}", "${lookup(data.terraform_remote_state.base-stack.DevVPNSgMap, "${var.environment}")}"]
  iam_instance_profile_arn = "${module.instance-role.InstanceProfileARN}"
  subnet_ids = "${split(",", lookup(data.terraform_remote_state.base-stack.SubnetIdsMap, "${var.environment}"))}"
  lifecycle_hook = 0
  notify_target = "${module.sns-drain-topic.SNSTopicARN}"
  notify_role_arn = "${module.asg-lifeccycle-hook-role.IAMRoleARN}"
  user_data = "${data.template_file.user_data.rendered}"
}
