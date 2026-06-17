
################ORG INFO##########################
variable "bu_id" {
  description = "Business Unit"
  type        = string
  default     = null
}


variable "app_id" {
  description = "application Unit"
  type        = string
  default     = null
}

variable "friendly_name" {
  description = "Friendly name prefix for resources (e.g., 'allhub', 'devspoke'). Used in resource naming and EKS cluster identification."
  type        = string
}

####################################################
# VPC INFO#

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"

  validation {
    condition     = can(cidrhost(var.vpc_cidr, 0))
    error_message = "VPC CIDR must be a valid IPv4 CIDR block"
  }
}

variable "azs" {
  description = "List of availability zones. If not provided, will auto-detect 2-3 AZs in the region"
  type        = list(string)
  default     = []
}

variable "private_subnets" {
  description = "List of CIDR blocks for private subnets. If not provided, will auto-calculate based on VPC CIDR"
  type        = list(string)
  default     = []
}

variable "public_subnets" {
  description = "List of CIDR blocks for public subnets. If not provided, will auto-calculate based on VPC CIDR"
  type        = list(string)
  default     = []
}

variable "enable_nat_gateway" {
  description = "Enable NAT Gateway for private subnets"
  type        = bool
  default     = true
}

variable "single_nat_gateway" {
  description = "Use single NAT Gateway to reduce costs (not recommended for production)"
  type        = bool
  default     = false
}

variable "enable_dns_hostnames" {
  description = "Enable DNS hostnames in VPC"
  type        = bool
  default     = true
}

variable "enable_dns_support" {
  description = "Enable DNS support in VPC"
  type        = bool
  default     = true
}


variable "env" {
  description = "Environment name (dev, staging, prod)"
  type        = string

  validation {
    condition     = can(regex("^(dev|staging|prod|test)$", var.env))
    error_message = "Environment must be dev, staging, or prod"
  }
}



variable "enable_vpn_gateway" {
  description = "Enable VPN Gateway"
  type        = bool
  default     = false
}

variable "enable_flow_logs" {
  description = "Enable VPC Flow Logs to CloudWatch"
  type        = bool
  default     = false
}

variable "flow_logs_retention_days" {
  description = "CloudWatch log retention for flow logs in days"
  type        = number
  default     = 7

  validation {
    condition     = contains([1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1096, 1827, 2192, 2557, 2922, 3288, 3653], var.flow_logs_retention_days)
    error_message = "Flow logs retention must be a valid CloudWatch Logs retention period"
  }
}

variable "enable_vpc_endpoints" {
  description = "Enable VPC endpoints for AWS services"
  type        = bool
  default     = true
}

variable "vpc_endpoints" {
  description = "Map of VPC endpoints to create. Valid keys: ssm, ssmmessages, ec2messages, kms, ecr_api, ecr_dkr, ec2, sts, logs, s3, dynamodb"
  type        = map(bool)
  default = {
    ssm         = true
    ssmmessages = true
    ec2messages = true
    kms         = true
    ecr_api     = true
    ecr_dkr     = true
    ec2         = true
    sts         = true
    logs        = true
    s3          = true
    dynamodb    = false
  }
}

variable "enable_network_load_balancer" {
  description = "Create Network Load Balancer in public subnets"
  type        = bool
  default     = false
}

variable "nlb_subnet_ids" {
  description = "Subnet IDs for NLB. If not specified, uses public subnets"
  type        = list(string)
  default     = []
}

variable "nlb_deletion_protection" {
  description = "Enable deletion protection for Network Load Balancer"
  type        = bool
  default     = true
}

variable "nlb_access_logs_bucket_name" {
  description = "S3 bucket name for NLB access logs. If null, logging is disabled"
  type        = string
  default     = null
}

variable "nlb_access_logs_prefix" {
  description = "S3 prefix for NLB access logs"
  type        = string
  default     = null
}

variable "enable_istio_support" {
  description = "Configure security groups for Istio service mesh"
  type        = bool
  default     = false
}

variable "enable_alb" {
  description = "Create Application Load Balancer"
  type        = bool
  default     = false
}

variable "alb_subnet_ids" {
  description = "Subnet IDs for ALB. If not specified, uses public subnets"
  type        = list(string)
  default     = []
}

variable "alb_deletion_protection" {
  description = "Enable deletion protection for ALB"
  type        = bool
  default     = true
}

variable "alb_access_logs_bucket_name" {
  description = "S3 bucket name for ALB access logs. If null, logging is disabled"
  type        = string
  default     = null
}

variable "alb_access_logs_prefix" {
  description = "S3 prefix for ALB access logs"
  type        = string
  default     = null
}

variable "alb_http_enabled" {
  description = "Enable HTTP listener for ALB"
  type        = bool
  default     = true
}

variable "alb_https_enabled" {
  description = "Enable HTTPS listener for ALB"
  type        = bool
  default     = true
}

variable "alb_certificate_arn" {
  description = "ARN of ACM certificate for HTTPS listener"
  type        = string
  default     = null
}

variable "alb_ingress_cidr_blocks" {
  description = "List of CIDR blocks to allow ingress to ALB (HTTP/HTTPS)"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "tags" {
  description = "Additional tags for all resources"
  type        = map(string)
  default     = {}
}
