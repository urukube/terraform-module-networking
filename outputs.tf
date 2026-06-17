# VPC outputs
output "vpc_id" {
  description = "VPC ID for EKS module"
  value       = module.vpc.vpc_id
}
output "vpc_cidr" {
  description = "VPC CIDR block"
  value       = module.vpc.vpc_cidr_block
}

output "vpc_arn" {
  description = "ARN of the VPC"
  value       = module.vpc.vpc_arn
}

output "vpc_tags" {
  description = "Tags applied to the VPC"
  value = merge(local.common_tags, {
    Name = "${var.friendly_name}-${var.bu_id}-${var.app_id}-vpc"
  })
}

# Subnet outputs
output "private_subnet_ids" {
  description = "List of private subnet IDs (for EKS nodes)"
  value       = module.vpc.private_subnets
}

output "public_subnet_ids" {
  description = "List of public subnet IDs (for load balancers)"
  value       = module.vpc.public_subnets
}

output "all_subnet_ids" {
  description = "Combined list of all subnet IDs"
  value       = concat(module.vpc.private_subnets, module.vpc.public_subnets)
}

output "private_subnet_cidrs" {
  description = "List of private subnet CIDR blocks"
  value       = module.vpc.private_subnets_cidr_blocks
}

output "public_subnet_cidrs" {
  description = "List of public subnet CIDR blocks"
  value       = module.vpc.public_subnets_cidr_blocks
}

# NAT Gateway outputs
output "nat_gateway_ids" {
  description = "NAT Gateway IDs"
  value       = module.vpc.natgw_ids
}

output "nat_gateway_public_ips" {
  description = "Elastic IPs of NAT Gateways"
  value       = module.vpc.nat_public_ips
}

# Availability Zone outputs
output "azs" {
  description = "Availability zones used"
  value       = local.azs
}

# Security Group outputs
output "node_security_group_id" {
  description = "Security group ID for EKS nodes"
  value       = aws_security_group.eks_nodes.id
}

output "control_plane_security_group_id" {
  description = "Security group ID for EKS control plane"
  value       = aws_security_group.eks_control_plane.id
}

output "vpc_endpoint_security_group_id" {
  description = "Security group ID for VPC endpoints"
  value       = var.enable_vpc_endpoints ? aws_security_group.vpc_endpoints[0].id : null
}

output "istio_security_group_id" {
  description = "Security group ID for Istio service mesh"
  value       = var.enable_istio_support ? aws_security_group.istio[0].id : null
}

output "vpc_default_security_group_id" {
  description = "Default VPC security group ID"
  value       = module.vpc.default_security_group_id
}

# VPC Endpoint outputs
output "vpc_endpoints" {
  description = "Map of VPC endpoint IDs"
  value = var.enable_vpc_endpoints ? merge(
    { for k, v in aws_vpc_endpoint.interface : k => v.id },
    { for k, v in aws_vpc_endpoint.gateway : k => v.id }
  ) : {}
}

output "vpc_endpoint_interface_dns_entries" {
  description = "DNS entries for interface VPC endpoints"
  value = var.enable_vpc_endpoints ? {
    for k, v in aws_vpc_endpoint.interface : k => v.dns_entry
  } : {}
}

# Network Load Balancer outputs
output "nlb_arn" {
  description = "Network Load Balancer ARN (if created)"
  value       = var.enable_network_load_balancer ? aws_lb.network[0].arn : null
}

output "nlb_dns_name" {
  description = "Network Load Balancer DNS name (if created)"
  value       = var.enable_network_load_balancer ? aws_lb.network[0].dns_name : null
}

output "nlb_zone_id" {
  description = "Network Load Balancer hosted zone ID (if created)"
  value       = var.enable_network_load_balancer ? aws_lb.network[0].zone_id : null
}

output "nlb_target_group_arn" {
  description = "NLB target group ARN (if created)"
  value       = var.enable_network_load_balancer ? aws_lb_target_group.network[0].arn : null
}

# Route table outputs
output "private_route_table_ids" {
  description = "Private route table IDs"
  value       = module.vpc.private_route_table_ids
}

output "public_route_table_ids" {
  description = "Public route table IDs"
  value       = module.vpc.public_route_table_ids
}

# Internet Gateway output
output "igw_id" {
  description = "Internet Gateway ID"
  value       = module.vpc.igw_id
}

# Application Load Balancer outputs
output "alb_arn" {
  description = "Application Load Balancer ARN (if created)"
  value       = var.enable_alb ? aws_lb.application[0].arn : null
}

output "alb_dns_name" {
  description = "Application Load Balancer DNS name (if created)"
  value       = var.enable_alb ? aws_lb.application[0].dns_name : null
}

output "alb_zone_id" {
  description = "Application Load Balancer hosted zone ID (if created)"
  value       = var.enable_alb ? aws_lb.application[0].zone_id : null
}

output "alb_security_group_id" {
  description = "Security group ID for ALB (if created)"
  value       = var.enable_alb ? aws_security_group.alb[0].id : null
}
