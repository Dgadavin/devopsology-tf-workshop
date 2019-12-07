provider "aws" {
  region     = "us-east-1"
}

# provider "random" {
# }
# //
terraform {
  backend "s3" {
    bucket = "terraform-itea-workshop-max"
    key = "new-state/tf.state"
    region = "us-east-1"
  }
}
