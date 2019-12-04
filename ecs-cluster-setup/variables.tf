#Immutable variables
variable "service_name" { default = "main-cluster" }
variable "profile_name" { default = "itea" }
variable "environment" {}
#Common variables
variable "ClusterName" {}
variable "CertificateARN" { default = "" }
variable "AmiId" { default = "ami-0d2aaec13a6b7e7ca" }
variable "ssh_key_name" {}
