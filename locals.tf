locals {
  # Single AZ by default — one subnet per tier (EKS nodes, AWS resources, public)
  azs = length(var.azs) > 0 ? var.azs : slice(data.aws_availability_zones.available.names, 0, 1)

  # Tier 1 private: EKS node subnet — has NAT GW route for image pulls
  # Default: 10.0.0.0/19 (8,192 IPs)
  eks_node_subnets = length(var.eks_node_subnets) > 0 ? var.eks_node_subnets : [
    for idx, az in local.azs : cidrsubnet(var.vpc_cidr, 3, idx)
  ]

  # Tier 2 private: AWS resource subnet — no NAT GW, VPC-local only
  # Default: 10.0.32.0/19 (8,192 IPs)
  resource_subnets = length(var.resource_subnets) > 0 ? var.resource_subnets : [
    for idx, az in local.azs : cidrsubnet(var.vpc_cidr, 3, length(local.eks_node_subnets) + idx)
  ]

  # Public subnet — for load balancers only
  # Default: 10.0.96.0/24 (256 IPs)
  public_subnets = length(var.public_subnets) > 0 ? var.public_subnets : [
    for idx, az in local.azs : cidrsubnet(var.vpc_cidr, 8, 96 + idx)
  ]

  common_tags = merge(
    var.tags,
    {
      env    = var.env
      bu_id  = var.bu_id
      app_id = var.app_id
    }
  )

  # EKS node subnet tags — enables AWS LB controller discovery for internal LBs
  private_subnet_tags = {
    "kubernetes.io/role/internal-elb"                                          = "1"
    "kubernetes.io/cluster/${var.friendly_name}-${var.bu_id}-${var.app_id}-eks" = "shared"
  }

  # Resource subnet tags — marks the tier, explicitly excludes EKS scheduling
  intra_subnet_tags = {
    "Tier" = "resources"
  }

  # Public subnet tags — enables AWS LB controller discovery for external LBs
  public_subnet_tags = {
    "kubernetes.io/role/elb"                                                   = "1"
    "kubernetes.io/cluster/${var.friendly_name}-${var.bu_id}-${var.app_id}-eks" = "shared"
  }
}
