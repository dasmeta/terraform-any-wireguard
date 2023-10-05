# get vpc public subnets by vpc id and additional filtration
data "aws_subnets" "public_subnets" {
  filter {
    name   = "vpc-id"
    values = [var.vpc_id]
  }

  dynamic "filter" {
    for_each = var.vpc_subnet_additional_filter

    content {
      name   = filter.value.name
      values = filter.value.values
    }
  }
}

# Lookup the AMI instance that corresponds to a Ubuntu server
data "aws_ami" "ubuntu" {
  most_recent = true
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/${var.ubuntu_version}-amd64-server-*"]
  }
  owners = ["099720109477"] # Canonical
}
