module "iam-role" {
  source = "git@github.com:Dgadavin/itea-terraform-workshop//terraform-modules/iam/iam-role"
  service_name = "${var.service_name}"
  trusted_name = "ecs-tasks"
}

module "embeded-policy-attachment" {
  source = "git@github.com:dgadavin/itea-terraform-workshop//terraform-modules/iam/iam-policy-attach"
  iam_role_name = "${module.iam-role.IAMRoleName}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}
