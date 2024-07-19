resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"

  enable_dns_support   = true   # requirement for some add-ons, like EFS/CSI driver/Client VPN
  enable_dns_hostnames = true

  tags = {
    Name = "${local.env}-main"
  }
}