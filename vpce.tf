locals {
  # Define VPC endpoints configuration
  vpc_endpoints_config = {
    ssm = {
      service             = "ssm"
      service_type        = "Interface"
      private_dns_enabled = true
    }
    ssmmessages = {
      service             = "ssmmessages"
      service_type        = "Interface"
      private_dns_enabled = true
    }
    ec2messages = {
      service             = "ec2messages"
      service_type        = "Interface"
      private_dns_enabled = true
    }
    kms = {
      service             = "kms"
      service_type        = "Interface"
      private_dns_enabled = true
    }
    ecr_api = {
      service             = "ecr.api"
      service_type        = "Interface"
      private_dns_enabled = true
    }
    ecr_dkr = {
      service             = "ecr.dkr"
      service_type        = "Interface"
      private_dns_enabled = true
    }
    ec2 = {
      service             = "ec2"
      service_type        = "Interface"
      private_dns_enabled = true
    }
    sts = {
      service             = "sts"
      service_type        = "Interface"
      private_dns_enabled = true
    }
    eks = {
      service             = "eks"
      service_type        = "Interface"
      private_dns_enabled = true
    }
    logs = {
      service             = "logs"
      service_type        = "Interface"
      private_dns_enabled = true
    }
    s3 = {
      service      = "s3"
      service_type = "Gateway"
    }
    dynamodb = {
      service      = "dynamodb"
      service_type = "Gateway"
    }
  }

  # Filter endpoints based on user configuration
  enabled_endpoints = {
    for k, v in local.vpc_endpoints_config :
    k => v if lookup(var.vpc_endpoints, k, false)
  }

  # Separate interface and gateway endpoints
  interface_endpoints = {
    for k, v in local.enabled_endpoints :
    k => v if v.service_type == "Interface"
  }

  gateway_endpoints = {
    for k, v in local.enabled_endpoints :
    k => v if v.service_type == "Gateway"
  }
}

# Interface VPC Endpoints (SSM, KMS, ECR, etc.)
resource "aws_vpc_endpoint" "interface" {
  for_each = var.enable_vpc_endpoints ? local.interface_endpoints : {}

  vpc_id              = module.vpc.vpc_id
  service_name        = "com.amazonaws.${data.aws_region.current.id}.${each.value.service}"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = each.value.private_dns_enabled

  subnet_ids         = module.vpc.private_subnets
  security_group_ids = [aws_security_group.vpc_endpoints[0].id]

  tags = merge(
    local.common_tags,
    {
      Name = "${var.friendly_name}-${var.bu_id}-${var.app_id}-${each.key}-endpoint"
    }
  )
}

# Gateway VPC Endpoints (S3, DynamoDB)
resource "aws_vpc_endpoint" "gateway" {
  for_each = var.enable_vpc_endpoints ? local.gateway_endpoints : {}

  vpc_id            = module.vpc.vpc_id
  service_name      = "com.amazonaws.${data.aws_region.current.id}.${each.value.service}"
  vpc_endpoint_type = "Gateway"

  route_table_ids = concat(
    module.vpc.private_route_table_ids,
    module.vpc.public_route_table_ids
  )

  tags = merge(
    local.common_tags,
    {
      Name = "${var.friendly_name}-${var.bu_id}-${var.app_id}-${each.key}-endpoint"
    }
  )
}
