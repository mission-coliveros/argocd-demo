#terraform {
#  backend "local" {
#    path = "terraform.tfstate"
#  }
#}

terraform {
  backend "s3" {
    region = "us-west-2"
  }
}