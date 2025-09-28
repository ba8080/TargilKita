resource "aws_security_group" "bastion" {
  name   = "bastion-sg"
  vpc_id = var.vpc_id
  ingress { from_port=22 to_port=22 protocol="tcp" cidr_blocks=["0.0.0.0/0"] }
  egress  { from_port=0 to_port=0 protocol="-1" cidr_blocks=["0.0.0.0/0"] }
}

resource "aws_security_group" "app" {
  name   = "app-sg"
  vpc_id = var.vpc_id
  egress { from_port=0 to_port=0 protocol="-1" cidr_blocks=["0.0.0.0/0"] }
}

# פתיחת 8000 מתוך ה-VPC לטובת NLB (L4 ללא SG)
resource "aws_security_group_rule" "app_from_vpc_tcp8000" {
  type                     = "ingress"
  security_group_id        = aws_security_group.app.id
  from_port                = 8000
  to_port                  = 8000
  protocol                 = "tcp"
  cidr_blocks              = ["10.0.0.0/8"]
}

# SSH ל-App מה-bastion בלבד
resource "aws_security_group_rule" "app_ssh_from_bastion" {
  type                       = "ingress"
  security_group_id          = aws_security_group.app.id
  from_port                  = 22
  to_port                    = 22
  protocol                   = "tcp"
  source_security_group_id   = aws_security_group.bastion.id
}

resource "aws_security_group" "lb" {
  name   = "lb-sg"
  vpc_id = var.vpc_id
  ingress { from_port=80 to_port=80 protocol="tcp" cidr_blocks = var.lb_ingress_cidrs }
  egress  { from_port=0 to_port=0 protocol="-1" cidr_blocks=["0.0.0.0/0"] }
}

output "bastion_sg_id" { value = aws_security_group.bastion.id }
output "app_sg_id"     { value = aws_security_group.app.id }
output "lb_sg_id"      { value = aws_security_group.lb.id }
