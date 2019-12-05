data "terraform_remote_state" "base-stack" {
  backend = "s3"
  config = {
    bucket = "@@bucket@@"
    key    = "baseSetup/terraform.tfstate"
    region = "eu-central-1"
  }
}

data "terraform_remote_state" "main-cluster" {
  backend = "s3"
  config = {
    bucket = "@@bucket@@"
    key    = "${var.main_cluster_stack_name}/terraform.tfstate"
    region = "eu-central-1"
  }
}

module "task-definition" {
  source = "git@github.com:dgadavin/itea-terraform-worshop//terraform-modules/ecs/task-definition"
  family = "${var.service_name}-terraform"
  task_template = "${data.template_file.nginxTemplate.rendered}"
  task_role_arn = "${module.iam-role.IAMRoleARN}"
  execution_role_arn = "${data.terraform_remote_state.base-stack.EcsExecutionRoleARN}"
}

module "route53-internal" {
  source = "git@github.com:dgadavin/itea-terraform-worshop//terraform-modules/ecs/route53"
  elb_dns_name = "${var.ELBDNSName}-eu-west-1"
  domain_hosted_zone_id = "${var.HostedZoneID}"
  load_balancer_dns_name = "${module.main-cluster.ClusterInternalLoadBalancerDNSName}"
  canonical_hosted_zone_id = "${module.main-cluster.ClusterInternalLoadBalancerCanonicalHostedZoneID}"
}

module "ecs-service" {
  source = "git@github.com:dgadavin/itea-terraform-worshop//ecs/ecs-deploy?ref=migrate_2_tf_0_12"
  service_name = "${var.service_name}-${lower(var.Environment)}"
  container_name = "${var.service_name}"
  vpc_id = "${lookup(data.terraform_remote_state.base-stack.VPCIdsMap, "${var.Environment}")}"
  http_listener_arn = "${module.main-cluster.ClusterInternalLoadBalancerHttpListener}"
  https_listener_arn = "${module.main-cluster.ClusterInternalLoadBalancerHttpsListener}"
  cluster_id = "${module.main-cluster.ClusterId}"
  task_definition_arn = "${module.task-definition.TaskDefinitionARN}"
  desire_count = "${var.ScaleMinCapacity}"
  service_iam_role = "${module.main-cluster.ClusterecsServiceRole}"
  scale_max_capacity = "${var.ScaleMaxCapacity}"
  scale_min_capacity = "${var.ScaleMinCapacity}"
  autoscaling_iam_role_arn = "${module.main-cluster.ClusterecsAutoscalingRole}"
  route53_fqdn = "${module.route53-internal.FancyLoadBalancerDNSName}"
  health_path = "/"
  app_autoscaling_enabled = false
  deployment_minimum_healthy_percent = 100
  deployment_maximum_percent = 200
  container_port = 80
}
