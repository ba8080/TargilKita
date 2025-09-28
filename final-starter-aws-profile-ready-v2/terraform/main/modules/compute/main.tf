data "aws_ami" "al2023" {
  most_recent = true
  owners      = [var.ami_owner]
  filter { name = "name" values = ["al2023-ami-*-x86_64"] }
}

resource "aws_instance" "bastion" {
  ami                         = data.aws_ami.al2023.id
  instance_type               = var.instance_type
  subnet_id                   = var.public_subnet_id
  associate_public_ip_address = true
  vpc_security_group_ids      = [var.bastion_sg_id]
  key_name                    = var.key_name

  root_block_device { volume_size = var.root_volume_gb volume_type = "gp2" }

  tags = { Name = "${var.project_name}-bastion" }
}

resource "aws_instance" "app" {
  count                       = 2
  ami                         = data.aws_ami.al2023.id
  instance_type               = var.instance_type
  subnet_id                   = var.private_subnet_ids[count.index]
  associate_public_ip_address = false
  vpc_security_group_ids      = [var.app_sg_id]
  key_name                    = var.key_name

  user_data = <<-EOF
#!/bin/bash
set -eux
yum update -y || true
yum install -y python3 git || true
EOF

  root_block_device { volume_size = var.root_volume_gb volume_type = "gp2" }
  tags = { Name = "${var.project_name}-app-${count.index}" }
}

output "bastion_public_ip" { value = aws_instance.bastion.public_ip }
output "app_instance_ids"  { value = aws_instance.app[*].id }
output "app_private_ips"   { value = aws_instance.app[*].private_ip }
