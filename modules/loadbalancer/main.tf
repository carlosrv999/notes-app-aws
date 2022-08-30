resource "aws_lb" "default" {
  name               = "alb-notesapp"
  internal           = false
  load_balancer_type = "application"
  security_groups    = var.security_groups_ids[*]
  subnets            = var.subnet_ids[*]

  enable_deletion_protection = false

  tags = merge(
    { "Name" = "notes-app" },
    var.tags,
  )
}

resource "aws_lb_target_group" "default" {
  deregistration_delay          = "300"
  load_balancing_algorithm_type = "round_robin"
  name                          = "ecs-service-notesapp"
  port                          = 80
  protocol                      = "HTTP"
  protocol_version              = "HTTP1"
  slow_start                    = 0
  target_type                   = "ip"
  vpc_id                        = var.vpc_id

  health_check {
    enabled             = true
    healthy_threshold   = 5
    interval            = 30
    matcher             = "200"
    path                = "/"
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = 5
    unhealthy_threshold = 2
  }

  stickiness {
    cookie_duration = 86400
    enabled         = false
    type            = "lb_cookie"
  }

  tags = merge(
    { "Name" = "notes-app" },
    var.tags,
  )
}

resource "aws_lb_listener" "default" {
  load_balancer_arn = aws_lb.default.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_lb_target_group.default.arn
    type             = "forward"
  }

  tags = merge(
    { "Name" = "notes-app" },
    var.tags,
  )

}
