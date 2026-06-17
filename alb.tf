resource "aws_lb" "application" {
  # checkov:skip=CKV_AWS_150:Deletion protection is configurable via variable
  # checkov:skip=CKV2_AWS_28:WAF is managed externally
  # checkov:skip=CKV2_AWS_20:Review HTTP to HTTPS redirect requirement
  # checkov:skip=CKV_AWS_131:ALB drops HTTP headers
  # checkov:skip=CKV_AWS_91:Access logging is optional and configurable via variables
  count = var.enable_alb ? 1 : 0

  name               = "${var.friendly_name}-${var.bu_id}-${var.app_id}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb[0].id]
  subnets            = length(var.alb_subnet_ids) > 0 ? var.alb_subnet_ids : module.vpc.public_subnets

  enable_deletion_protection = var.alb_deletion_protection
  drop_invalid_header_fields = true

  dynamic "access_logs" {
    for_each = var.alb_access_logs_bucket_name != null ? [1] : []
    content {
      bucket  = var.alb_access_logs_bucket_name
      prefix  = var.alb_access_logs_prefix
      enabled = true
    }
  }

  tags = merge(
    local.common_tags,
    {
      Name = "${var.friendly_name}-${var.bu_id}-${var.app_id}-alb"
    }
  )
}

# ALB Target Group
resource "aws_lb_target_group" "application" {
  # checkov:skip=CKV_AWS_378:HTTP is required for this target group
  count = var.enable_alb && (var.alb_http_enabled || var.alb_https_enabled) ? 1 : 0

  name     = "${var.friendly_name}-${var.bu_id}-${var.app_id}-alb-tg"
  port     = var.alb_http_enabled ? 80 : 443
  protocol = var.alb_http_enabled ? "HTTP" : "HTTPS"
  vpc_id   = module.vpc.vpc_id

  health_check {
    enabled             = true
    path                = "/"
    protocol            = var.alb_http_enabled ? "HTTP" : "HTTPS"
    matcher             = "200-399"
    healthy_threshold   = 3
    unhealthy_threshold = 3
    interval            = 30
    timeout             = 5
  }

  deregistration_delay = 30

  tags = merge(
    local.common_tags,
    {
      Name = "${var.friendly_name}-${var.bu_id}-${var.app_id}-alb-tg"
    }
  )
}

# ALB Listener (HTTP)
resource "aws_lb_listener" "application_http" {
  # checkov:skip=CKV_AWS_2:HTTP listener required
  # checkov:skip=CKV_AWS_103:TLS not applicable for HTTP
  count = var.enable_alb && var.alb_http_enabled ? 1 : 0

  load_balancer_arn = aws_lb.application[0].arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.application[0].arn
  }

  tags = merge(
    local.common_tags,
    {
      Name = "${var.friendly_name}-${var.bu_id}-${var.app_id}-alb-http-listener"
    }
  )
}

# ALB Listener (HTTPS)
resource "aws_lb_listener" "application_https" {
  count = var.enable_alb && var.alb_https_enabled ? 1 : 0

  load_balancer_arn = aws_lb.application[0].arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  certificate_arn   = var.alb_certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.application[0].arn
  }

  tags = merge(
    local.common_tags,
    {
      Name = "${var.friendly_name}-${var.bu_id}-${var.app_id}-alb-https-listener"
    }
  )
}
