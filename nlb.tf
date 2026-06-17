# checkov:skip=CKV_AWS_91:Access logging is optional and configurable via variables
resource "aws_lb" "network" {
  count = var.enable_network_load_balancer ? 1 : 0

  name               = "${var.friendly_name}-${var.bu_id}-${var.app_id}-nlb"
  load_balancer_type = "network"
  internal           = false

  subnets = length(var.nlb_subnet_ids) > 0 ? var.nlb_subnet_ids : module.vpc.public_subnets

  enable_deletion_protection       = var.nlb_deletion_protection
  enable_cross_zone_load_balancing = true

  dynamic "access_logs" {
    for_each = var.nlb_access_logs_bucket_name != null ? [1] : []
    content {
      bucket  = var.nlb_access_logs_bucket_name
      prefix  = var.nlb_access_logs_prefix
      enabled = true
    }
  }

  tags = merge(
    local.common_tags,
    {
      Name = "${var.friendly_name}-${var.bu_id}-${var.app_id}-nlb"
    }
  )
}

# NLB Target Group
resource "aws_lb_target_group" "network" {
  count = var.enable_network_load_balancer ? 1 : 0

  name     = "${var.friendly_name}-${var.bu_id}-${var.app_id}-nlb-tg"
  port     = 443
  protocol = "TCP"
  vpc_id   = module.vpc.vpc_id

  health_check {
    enabled             = true
    protocol            = "TCP"
    port                = "traffic-port"
    healthy_threshold   = 3
    unhealthy_threshold = 3
    interval            = 30
  }

  deregistration_delay = 30

  tags = merge(
    local.common_tags,
    {
      Name = "${var.friendly_name}-${var.bu_id}-${var.app_id}-nlb-tg"
    }
  )
}

# NLB Listener
resource "aws_lb_listener" "network" {
  count = var.enable_network_load_balancer ? 1 : 0

  load_balancer_arn = aws_lb.network[0].arn
  port              = 443
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.network[0].arn
  }

  tags = merge(
    local.common_tags,
    {
      Name = "${var.friendly_name}-${var.bu_id}-${var.app_id}-nlb-listener"
    }
  )
}
