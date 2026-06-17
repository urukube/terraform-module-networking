variables {
  env           = "test"
  friendly_name = "test"
  bu_id         = "BU12345"
  app_id        = "APP67890"
  vpc_cidr      = "10.0.0.0/16"
  azs           = ["us-east-1a", "us-east-1b"]
}

run "endpoints_defaults" {
  command = plan

  assert {
    condition     = length(aws_vpc_endpoint.interface) > 0
    error_message = "Interface endpoints should be created by default"
  }

  assert {
    condition     = contains(keys(aws_vpc_endpoint.interface), "ssm")
    error_message = "SSM interface endpoint missing"
  }

  assert {
    condition     = contains(keys(aws_vpc_endpoint.interface), "ecr_api")
    error_message = "ECR API interface endpoint missing"
  }

  assert {
    condition     = length(aws_vpc_endpoint.gateway) == 1
    error_message = "Gateway endpoints (S3) should be created by default"
  }
}

run "endpoints_disabled" {
  command = plan

  variables {
    enable_vpc_endpoints = false
  }

  assert {
    condition     = length(aws_vpc_endpoint.interface) == 0
    error_message = "Interface endpoints should be 0 when disabled"
  }

  assert {
    condition     = length(aws_vpc_endpoint.gateway) == 0
    error_message = "Gateway endpoints should be 0 when disabled"
  }
}

run "endpoints_selective" {
  command = plan

  variables {
    vpc_endpoints = {
      s3          = true
      ssm         = false
      ssmmessages = false
      ec2messages = false
      kms         = false
      ecr_api     = false
      ecr_dkr     = false
      ec2         = false
      sts         = false
      logs        = false
      dynamodb    = false
    }
  }

  assert {
    condition     = length(aws_vpc_endpoint.interface) == 0
    error_message = "Interface endpoints should be 0"
  }

  assert {
    condition     = length(aws_vpc_endpoint.gateway) == 1
    error_message = "Gateway endpoints should be 1 (S3 only)"
  }
}
