module "ecs-execution-role" {
  source = "../terraform-modules/iam/iam-role"
  service_name = "${var.short_name}-execution"
  trusted_name = "ecs-tasks"
}

module "embeded-policy-attachment" {
  source = "../terraform-modules/iam/iam-policy-attach"
  iam_role_name = "${module.ecs-execution-role.IAMRoleName}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

module "ssm-policy-attachment" {
  source = "../terraform-modules/iam/iam-policy-attach"
  iam_role_name = "${module.ecs-execution-role.IAMRoleName}"
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMReadOnlyAccess"
}
