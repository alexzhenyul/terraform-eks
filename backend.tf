terraform {
  backend "s3" {
    bucket = "goofy-terraform-tfstate" 
    key    = "eks/goofy/terraform.tfstate"
    region = "ap-southeast-4"
  }
}