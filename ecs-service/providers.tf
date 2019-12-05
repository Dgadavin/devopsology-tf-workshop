provider "aws" {
  region     = "eu-central-1"
}

provider "random" {
}

terraform {
  backend "s3" {}
}
