variables {
  env           = "test"
  friendly_name = "test"
  bu_id         = "BU12345"
  app_id        = "APP67890"
  vpc_cidr      = "10.0.0.0/16"
  azs           = ["us-east-1a"]
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
    condition     = length(module.vpc.private_subnets) == 1
    error_message = "Expected 1 EKS node subnet"
  }

  assert {
    condition     = length(module.vpc.intra_subnets) == 1
    error_message = "Expected 1 AWS resource subnet"
  }

  assert {
    condition     = length(module.vpc.public_subnets) == 1
    error_message = "Expected 1 public subnet"
  }

  assert {
    condition     = length(module.vpc.natgw_ids) > 0
    error_message = "NAT Gateway should be created for EKS node subnet"
  }

  assert {
    condition     = length(module.vpc.private_route_table_ids) == 1
    error_message = "One route table expected for EKS node subnet"
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

  variables {
    azs              = []
    eks_node_subnets = []
    resource_subnets = []
    public_subnets   = []
  }

  assert {
    condition     = module.vpc.private_subnets_cidr_blocks[0] == "10.0.0.0/19"
    error_message = "EKS node subnet CIDR calculation incorrect"
  }

  assert {
    condition     = module.vpc.intra_subnets_cidr_blocks[0] == "10.0.32.0/19"
    error_message = "Resource subnet CIDR calculation incorrect"
  }

  assert {
    condition     = module.vpc.public_subnets_cidr_blocks[0] == "10.0.96.0/24"
    error_message = "Public subnet CIDR calculation incorrect"
  }
}
