# -------------------------
# Application Load Balancer
# -------------------------

resource "aws_lb" "app" {
  name               = "${var.environment}-go-api-alb"
  internal           = false
  load_balancer_type = "application"

  security_groups = [
    aws_security_group.alb.id
  ]

  subnets = aws_subnet.public[*].id

  tags = {
    Name = "${var.environment}-go-api-alb"
  }
}

# -------------------------
# Target Group
# -------------------------

resource "aws_lb_target_group" "app" {
  name     = "${var.environment}-go-api-tg"
  port     = var.app_port
  protocol = "HTTP"

  vpc_id = aws_vpc.main.id

  target_type = "instance"

  health_check {
    enabled             = true
    path                = "/"
    protocol            = "HTTP"
    port                = "traffic-port"
    healthy_threshold   = 2
    unhealthy_threshold = 3
    timeout             = 5
    interval            = 30
  }

  tags = {
    Name = "${var.environment}-go-api-tg"
  }
}

# -------------------------
# ALB Listener
# -------------------------

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.app.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"

    forward {
      target_group {
        arn = aws_lb_target_group.app.arn
      }
    }
  }
}

# -------------------------
# Register EC2
# -------------------------

resource "aws_lb_target_group_attachment" "ec2" {
  target_group_arn = aws_lb_target_group.app.arn
  target_id        = aws_instance.app.id
  port             = var.app_port
}
