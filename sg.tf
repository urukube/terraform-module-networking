# Security group for EKS nodes
resource "aws_security_group" "eks_nodes" {
  # checkov:skip=CKV2_AWS_5:Security group attached in external module
  name_prefix = "${var.friendly_name}-${var.bu_id}-${var.app_id}-eks-nodes-sg-"
  description = "Security group for EKS worker nodes"
  vpc_id      = module.vpc.vpc_id

  tags = merge(
    local.common_tags,
    {
      Name = "${var.friendly_name}-${var.bu_id}-${var.app_id}-eks-nodes-sg"
    }
  )

  lifecycle {
    create_before_destroy = true
  }
}

# Allow all traffic from within VPC CIDR
resource "aws_vpc_security_group_ingress_rule" "eks_nodes_vpc_ingress" {
  security_group_id = aws_security_group.eks_nodes.id
  description       = "Allow all traffic from VPC CIDR"
  cidr_ipv4         = var.vpc_cidr
  ip_protocol       = "-1"

  tags = merge(
    local.common_tags,
    {
      Name = "${var.friendly_name}-${var.bu_id}-${var.app_id}-eks-nodes-vpc-ingress-sg"
    }
  )
}

# Allow HTTPS from Network Load Balancer if enabled
resource "aws_vpc_security_group_ingress_rule" "eks_nodes_nlb_ingress" {
  count = var.enable_network_load_balancer ? 1 : 0

  security_group_id = aws_security_group.eks_nodes.id
  description       = "Allow HTTPS from anywhere for NLB"
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 443
  to_port           = 443
  ip_protocol       = "tcp"

  tags = merge(
    local.common_tags,
    {
      Name = "${var.friendly_name}-${var.bu_id}-${var.app_id}-eks-nodes-nlb-ingress-sg"
    }
  )
}

# Allow all egress traffic
resource "aws_vpc_security_group_egress_rule" "eks_nodes_egress" {
  security_group_id = aws_security_group.eks_nodes.id
  description       = "Allow all outbound traffic"
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"

  tags = merge(
    local.common_tags,
    {
      Name = "${var.friendly_name}-${var.bu_id}-${var.app_id}-eks-nodes-egress-sg"
    }
  )
}

# Security group for EKS control plane
resource "aws_security_group" "eks_control_plane" {
  # checkov:skip=CKV2_AWS_5:Security group attached in external module
  name_prefix = "${var.friendly_name}-${var.bu_id}-${var.app_id}-eks-control-plane-sg-"
  description = "Security group for EKS control plane"
  vpc_id      = module.vpc.vpc_id

  tags = merge(
    local.common_tags,
    {
      Name = "${var.friendly_name}-${var.bu_id}-${var.app_id}-eks-control-plane-sg"
    }
  )

  lifecycle {
    create_before_destroy = true
  }
}

# Allow HTTPS from worker nodes
resource "aws_vpc_security_group_ingress_rule" "control_plane_from_nodes" {
  security_group_id            = aws_security_group.eks_control_plane.id
  description                  = "Allow HTTPS from worker nodes"
  referenced_security_group_id = aws_security_group.eks_nodes.id
  from_port                    = 443
  to_port                      = 443
  ip_protocol                  = "tcp"

  tags = merge(
    local.common_tags,
    {
      Name = "${var.friendly_name}-${var.bu_id}-${var.app_id}-control-plane-from-nodes-sg"
    }
  )
}

# Allow egress to worker nodes - HTTPS
resource "aws_vpc_security_group_egress_rule" "control_plane_to_nodes_https" {
  security_group_id            = aws_security_group.eks_control_plane.id
  description                  = "Allow HTTPS to worker nodes"
  referenced_security_group_id = aws_security_group.eks_nodes.id
  from_port                    = 443
  to_port                      = 443
  ip_protocol                  = "tcp"

  tags = merge(
    local.common_tags,
    {
      Name = "${var.friendly_name}-${var.bu_id}-${var.app_id}-control-plane-to-nodes-https-sg"
    }
  )
}

# Allow egress to worker nodes - Kubelet and extension API servers
resource "aws_vpc_security_group_egress_rule" "control_plane_to_nodes_kubelet" {
  security_group_id            = aws_security_group.eks_control_plane.id
  description                  = "Allow kubelet and extension API traffic to worker nodes"
  referenced_security_group_id = aws_security_group.eks_nodes.id
  from_port                    = 1025
  to_port                      = 65535
  ip_protocol                  = "tcp"

  tags = merge(
    local.common_tags,
    {
      Name = "${var.friendly_name}-${var.bu_id}-${var.app_id}-control-plane-to-nodes-kubelet-sg"
    }
  )
}

# Security group for VPC endpoints
resource "aws_security_group" "vpc_endpoints" {
  # checkov:skip=CKV2_AWS_5:Security group attached in external module
  count = var.enable_vpc_endpoints ? 1 : 0

  name_prefix = "${var.friendly_name}-${var.bu_id}-${var.app_id}-vpc-endpoints-sg-"
  description = "Security group for VPC endpoints"
  vpc_id      = module.vpc.vpc_id

  tags = merge(
    local.common_tags,
    {
      Name = "${var.friendly_name}-${var.bu_id}-${var.app_id}-vpc-endpoints-sg"
    }
  )

  lifecycle {
    create_before_destroy = true
  }
}

# Allow HTTPS from VPC CIDR for VPC endpoints
resource "aws_vpc_security_group_ingress_rule" "vpc_endpoints_https" {
  count = var.enable_vpc_endpoints ? 1 : 0

  security_group_id = aws_security_group.vpc_endpoints[0].id
  description       = "Allow HTTPS from VPC CIDR"
  cidr_ipv4         = var.vpc_cidr
  from_port         = 443
  to_port           = 443
  ip_protocol       = "tcp"

  tags = merge(
    local.common_tags,
    {
      Name = "${var.friendly_name}-${var.bu_id}-${var.app_id}-vpc-endpoints-https-sg"
    }
  )
}

# Allow all egress for VPC endpoints
resource "aws_vpc_security_group_egress_rule" "vpc_endpoints_egress" {
  count = var.enable_vpc_endpoints ? 1 : 0

  security_group_id = aws_security_group.vpc_endpoints[0].id
  description       = "Allow all outbound traffic"
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"

  tags = merge(
    local.common_tags,
    {
      Name = "${var.friendly_name}-${var.bu_id}-${var.app_id}-vpc-endpoints-egress-sg"
    }
  )
}

# Security group for Istio service mesh (optional)
resource "aws_security_group" "istio" {
  # checkov:skip=CKV2_AWS_5:Security group attached in external module
  count = var.enable_istio_support ? 1 : 0

  name_prefix = "${var.friendly_name}-${var.bu_id}-${var.app_id}-istio-sg-"
  description = "Security group for Istio service mesh"
  vpc_id      = module.vpc.vpc_id

  tags = merge(
    local.common_tags,
    {
      Name = "${var.friendly_name}-${var.bu_id}-${var.app_id}-istio-sg"
    }
  )

  lifecycle {
    create_before_destroy = true
  }
}

# Allow Istio pilot discovery port
resource "aws_vpc_security_group_ingress_rule" "istio_pilot" {
  count = var.enable_istio_support ? 1 : 0

  security_group_id = aws_security_group.istio[0].id
  description       = "Allow Istio pilot discovery"
  cidr_ipv4         = var.vpc_cidr
  from_port         = 15010
  to_port           = 15012
  ip_protocol       = "tcp"

  tags = merge(
    local.common_tags,
    {
      Name = "${var.friendly_name}-${var.bu_id}-${var.app_id}-istio-pilot-sg"
    }
  )
}

# Allow Istio ingress gateway ports
resource "aws_vpc_security_group_ingress_rule" "istio_ingress" {
  count = var.enable_istio_support ? 1 : 0

  security_group_id = aws_security_group.istio[0].id
  description       = "Allow Istio ingress gateway"
  cidr_ipv4         = var.vpc_cidr
  from_port         = 8080
  to_port           = 8080
  ip_protocol       = "tcp"

  tags = merge(
    local.common_tags,
    {
      Name = "${var.friendly_name}-${var.bu_id}-${var.app_id}-istio-ingress-sg"
    }
  )
}

# Allow Istio HTTPS
resource "aws_vpc_security_group_ingress_rule" "istio_https" {
  count = var.enable_istio_support ? 1 : 0

  security_group_id = aws_security_group.istio[0].id
  description       = "Allow Istio HTTPS"
  cidr_ipv4         = var.vpc_cidr
  from_port         = 8443
  to_port           = 8443
  ip_protocol       = "tcp"

  tags = merge(
    local.common_tags,
    {
      Name = "${var.friendly_name}-${var.bu_id}-${var.app_id}-istio-https-sg"
    }
  )
}

# Allow all egress for Istio
resource "aws_vpc_security_group_egress_rule" "istio_egress" {
  count = var.enable_istio_support ? 1 : 0

  security_group_id = aws_security_group.istio[0].id
  description       = "Allow all outbound traffic"
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"

  tags = merge(
    local.common_tags,
    {
      Name = "${var.friendly_name}-${var.bu_id}-${var.app_id}-istio-egress-sg"
    }
  )
}

# Security group for Application Load Balancer
resource "aws_security_group" "alb" {
  # checkov:skip=CKV2_AWS_5:Security group attached in external module
  count = var.enable_alb ? 1 : 0

  name_prefix = "${var.friendly_name}-${var.bu_id}-${var.app_id}-alb-sg-"
  description = "Security group for Application Load Balancer"
  vpc_id      = module.vpc.vpc_id

  tags = merge(
    local.common_tags,
    {
      Name = "${var.friendly_name}-${var.bu_id}-${var.app_id}-alb-sg"
    }
  )

  lifecycle {
    create_before_destroy = true
  }
}

# Allow HTTP ingress for ALB
# checkov:skip=CKV_AWS_260:Public access required for ALB
resource "aws_vpc_security_group_ingress_rule" "alb_http" {
  count = var.enable_alb && var.alb_http_enabled ? 1 : 0

  security_group_id = aws_security_group.alb[0].id
  description       = "Allow HTTP from allowed CIDRs"
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  to_port           = 80
  ip_protocol       = "tcp"

  tags = merge(
    local.common_tags,
    {
      Name = "${var.friendly_name}-${var.bu_id}-${var.app_id}-alb-http-sg"
    }
  )
}

# Allow HTTPS ingress for ALB
resource "aws_vpc_security_group_ingress_rule" "alb_https" {
  count = var.enable_alb && var.alb_https_enabled ? 1 : 0

  security_group_id = aws_security_group.alb[0].id
  description       = "Allow HTTPS from allowed CIDRs"
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 443
  to_port           = 443
  ip_protocol       = "tcp"

  tags = merge(
    local.common_tags,
    {
      Name = "${var.friendly_name}-${var.bu_id}-${var.app_id}-alb-https-sg"
    }
  )
}

# Allow all egress for ALB
resource "aws_vpc_security_group_egress_rule" "alb_egress" {
  count = var.enable_alb ? 1 : 0

  security_group_id = aws_security_group.alb[0].id
  description       = "Allow all outbound traffic"
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"

  tags = merge(
    local.common_tags,
    {
      Name = "${var.friendly_name}-${var.bu_id}-${var.app_id}-alb-egress-sg"
    }
  )
}
