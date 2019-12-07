variable "alb_name" {}
variable "is_internal" {
  type = bool
  default = true
}
variable "environment" {}
variable "subnet_ids" { type = "list" }
variable "security_group" {}
variable "certificate_arn" {}
