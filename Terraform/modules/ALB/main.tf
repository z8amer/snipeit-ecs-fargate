#Load Balancer security group
resource "aws_security_group" "alb_sg" {
  name        = "alb_sg"
  description = "Allow HTTP and HTTPS traffic"
  vpc_id      = var.vpc_id

  tags = {
    Name = "${var.project_name}-alb_sg"
  }

}

#Allow secure public web traffic
resource "aws_vpc_security_group_ingress_rule" "allow_https" {
  security_group_id = aws_security_group.alb_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = var.https_port
  ip_protocol       = "tcp"
  to_port           = var.https_port
}

#Allow public web traffic
resource "aws_vpc_security_group_ingress_rule" "allow_http" {
  security_group_id = aws_security_group.alb_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = var.container_port
  ip_protocol       = "tcp"
  to_port           = var.container_port
}

#Outbound traffic
resource "aws_vpc_security_group_egress_rule" "allow_all_ipv4" {
  security_group_id = aws_security_group.alb_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

#IPv6 Outbound Traffic
resource "aws_vpc_security_group_egress_rule" "allow_all_ipv6" {
  security_group_id = aws_security_group.alb_sg.id
  cidr_ipv6         = "::/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

#Application Load Balance. Distributes incoming web traffic evenly across application tasks running in the subnets.
resource "aws_lb" "main_alb" {
  name               = "main-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = var.public_subnet_ids

  enable_deletion_protection = false

  tags = {
    Name = "${var.project_name}-alb"
  }
}

# ALB Target Group. Routes incoming traffic from the load balancer using their private IP addresses.
resource "aws_lb_target_group" "alb_tg" {
  name        = "${var.project_name}-alb-tg"
  port        = var.container_port
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    path                = var.health_check_path
    healthy_threshold   = 3
    unhealthy_threshold = 3
    timeout             = 5
    interval            = 30
    matcher             = "200"
  }
}

# Listens for public traffic on port 80 and responds with a permanent redirect (HTTP 301) to force connections over HTTPS.
resource "aws_lb_listener" "http_listner" {
  load_balancer_arn = aws_lb.main_alb.arn
  port              = var.container_port
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = var.https_port
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }

  }
}

#Handles incoming secure traffic on port 443. Decrypts the request using SSL certificate and forwards the traffic directly to application target group.
resource "aws_lb_listener" "https_listner" {
  load_balancer_arn = aws_lb.main_alb.arn
  port              = var.https_port
  protocol          = "HTTPS"
  ssl_policy        = var.ssl_policy
  certificate_arn   = var.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb_tg.arn
  }
}
