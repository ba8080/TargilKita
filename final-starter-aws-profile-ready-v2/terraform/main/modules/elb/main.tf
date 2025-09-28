resource "aws_lb" "this" {
  name               = "${var.project_name}-nlb"
  load_balancer_type = "network"
  internal           = false
  subnets            = [var.public_subnet_id]
}

resource "aws_lb_target_group" "tg" {
  name        = "${var.project_name}-tg"
  port        = var.target_port
  protocol    = "TCP"
  target_type = "instance"
  vpc_id      = var.vpc_id

  health_check {
    port     = var.target_port
    protocol = "TCP"
  }
}

resource "aws_lb_listener" "tcp80" {
  load_balancer_arn = aws_lb.this.arn
  port     = 80
  protocol = "TCP"
  default_action { type = "forward" target_group_arn = aws_lb_target_group.tg.arn }
}

resource "aws_lb_target_group_attachment" "att" {
  for_each         = toset(var.target_instance_ids)
  target_group_arn = aws_lb_target_group.tg.arn
  target_id        = each.value
  port             = var.target_port
}

output "lb_dns_name" { value = aws_lb.this.dns_name }
