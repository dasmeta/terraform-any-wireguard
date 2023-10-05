# Create a security group that allows access to the EC2 instance
resource "aws_security_group" "wireguard" {
  name        = "${var.name}-vpn"
  description = "Wireguard security group Communication to and from VPC endpoint"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = var.server_port
    to_port     = var.server_port
    protocol    = "udp"
    cidr_blocks = var.ingress
  }

  dynamic "ingress" {
    for_each = var.ssh_key_name != null ? [1] : []

    content {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = var.ingress
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Provision wireguard server instance
resource "aws_instance" "this" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.instance_type
  subnet_id                   = data.aws_subnets.public_subnets.ids[0] # if no subnet found to use for instance and it fails here, check if you have public subnet in passed vpc and/or check var.vpc_subnet_additional_filter to alter additional filtration
  vpc_security_group_ids      = [aws_security_group.wireguard.id]
  key_name                    = var.ssh_key_name
  user_data_replace_on_change = true

  user_data = templatefile("${path.module}/templates/wireguard-server-init.sh.tpl", {
    network_cidr       = var.network_cidr
    server_port        = var.server_port
    server_private_key = var.server_private_key
    server_public_key  = var.server_public_key
    clients            = var.clients
  })

  tags = {
    Name = var.name
  }
}

# create static/elastic IP and attach to wireguard server instance
resource "aws_eip" "this" {
  vpc = true
}
resource "aws_eip_association" "this" {
  instance_id   = aws_instance.this.id
  allocation_id = aws_eip.this.id
}
