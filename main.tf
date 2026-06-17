module "vpc" {
  # checkov:skip=CKV_TF_1:Using version tags for modules
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.5.0"

  name = "${var.friendly_name}-${var.bu_id}-${var.app_id}-vpc"
  cidr = var.vpc_cidr

  azs             = local.azs
  private_subnets = local.private_subnets
  public_subnets  = local.public_subnets

  # NAT Gateway configuration
  enable_nat_gateway = var.enable_nat_gateway
  single_nat_gateway = var.single_nat_gateway

  # DNS configuration
  enable_dns_hostnames = var.enable_dns_hostnames
  enable_dns_support   = var.enable_dns_support

  # VPN Gateway
  enable_vpn_gateway = var.enable_vpn_gateway

  # VPC Flow Logs
  enable_flow_log                                 = var.enable_flow_logs
  create_flow_log_cloudwatch_iam_role             = var.enable_flow_logs
  create_flow_log_cloudwatch_log_group            = var.enable_flow_logs
  flow_log_cloudwatch_log_group_retention_in_days = var.flow_logs_retention_days

  # Subnet tagging for EKS
  public_subnet_tags  = local.public_subnet_tags
  private_subnet_tags = local.private_subnet_tags

  # Common tags
  tags = local.common_tags

  # VPC tags
  vpc_tags = merge(local.common_tags, {
    Name = "${var.friendly_name}-${var.bu_id}-${var.app_id}-vpc"
  })
}
