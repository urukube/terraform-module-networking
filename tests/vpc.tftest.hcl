variables {
  env           = "test"
  friendly_name = "test"
  bu_id         = "BU12345"
  app_id        = "APP67890"
  vpc_cidr      = "10.0.0.0/16"
  azs           = ["us-east-1a", "us-east-1b"]
}

run "vpc_defaults" {
  command = plan

  assert {
    condition     = module.vpc.name == "test-BU12345-APP67890-vpc"
    error_message = "VPC name did not match expected value"
  }

  assert {
    condition     = module.vpc.vpc_cidr_block == "10.0.0.0/16"
    error_message = "VPC CIDR did not match expected value"
  }

  assert {
    condition     = output.vpc_tags["Name"] == "test-BU12345-APP67890-vpc"
    error_message = "VPC Name tag is incorrect"
  }

  assert {
    condition     = length(module.vpc.private_subnets) == 2
    error_message = "Number of private subnets matching AZs"
  }

  assert {
    condition     = length(module.vpc.public_subnets) == 2
    error_message = "Number of public subnets matching AZs"
  }

  assert {
    condition     = length(module.vpc.natgw_ids) > 0
    error_message = "NAT Gateways should be created by default"
  }

  assert {
    condition     = length(module.vpc.private_route_table_ids) == 2
    error_message = "Private route tables should be created for each private subnet (implicitly associating with NAT GW)"
  }
}

run "vpc_cost_optimized" {
  command = plan

  variables {
    single_nat_gateway = true
  }

  assert {
    condition     = length(module.vpc.natgw_ids) == 1
    error_message = "Single NAT gateway should create exactly 1 NAT gateway"
  }
}

run "auto_subnets" {
  command = plan

  # Clear list variables to trigger auto-calculation
  variables {
    azs             = []
    private_subnets = []
    public_subnets  = []
  }

  assert {
    condition     = module.vpc.private_subnets_cidr_blocks[0] == "10.0.0.0/19"
    error_message = "Private Subnet 1 CIDR calculation incorrect"
  }

  assert {
    condition     = module.vpc.private_subnets_cidr_blocks[1] == "10.0.32.0/19"
    error_message = "Private Subnet 2 CIDR calculation incorrect"
  }

  assert {
    condition     = module.vpc.private_subnets_cidr_blocks[2] == "10.0.64.0/19"
    error_message = "Private Subnet 3 CIDR calculation incorrect"
  }

  assert {
    condition     = module.vpc.public_subnets_cidr_blocks[0] == "10.0.96.0/24"
    error_message = "Public Subnet 1 CIDR calculation incorrect"
  }

  assert {
    condition     = module.vpc.public_subnets_cidr_blocks[1] == "10.0.97.0/24"
    error_message = "Public Subnet 2 CIDR calculation incorrect"
  }

  assert {
    condition     = module.vpc.public_subnets_cidr_blocks[2] == "10.0.98.0/24"
    error_message = "Public Subnet 3 CIDR calculation incorrect"
  }
}
