# alb.tf | Load Balancer Configuration

data "aws_alb" "application_load_balancer" {
  arn  = var.lb_arn
}

data "http" "myip" {
  url = "http://ipv4.icanhazip.com"
}

data "aws_security_group" "load_balancer_security_group" {
  id = var.lb_security_group_id
}

resource "aws_lb_target_group" "target_group" {
  name        = "${var.app_name}-${var.app_environment}-tg"
  port        = 6789
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = data.aws_vpc.aws-vpc.id

  health_check {
    healthy_threshold   = "3"
    interval            = "30"
    protocol            = "HTTP"
    matcher             = "200"
    timeout             = "5"
    path                = "/api/status"
    unhealthy_threshold = "2"
  }

  tags = {
    Name        = "${var.app_name}-lb-tg"
    Environment = var.app_environment
  }
}

data "aws_lb_listener" "https_listener" {
  load_balancer_arn = data.aws_alb.application_load_balancer.arn
  port              = 80
}

resource "aws_lb_listener_rule" "hostname_based_routing" {
  listener_arn = data.aws_lb_listener.https_listener.arn
  priority     = 100  # Priority must be unique among rules for the listener

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target_group.arn
  }

  condition {
    host_header {
      values = ["example.com"]  # Replace with your desired hostname
    }
  }
}

output "load_balancer_dns_name" {
  value = "http://${data.aws_alb.application_load_balancer.dns_name}"
}
