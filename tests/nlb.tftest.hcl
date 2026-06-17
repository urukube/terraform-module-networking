variables {
  env                          = "test"
  friendly_name                = "test"
  bu_id                        = "BU12345"
  app_id                       = "APP67890"
  vpc_cidr                     = "10.0.0.0/16"
  azs                          = ["us-east-1a", "us-east-1b"]
  enable_network_load_balancer = true
}

run "nlb_verification" {
  command = plan

  assert {
    condition     = length(aws_lb.network) == 1
    error_message = "NLB should be created"
  }

  assert {
    condition     = aws_lb.network[0].name == "test-BU12345-APP67890-nlb"
    error_message = "NLB name mismatch"
  }

  assert {
    condition     = aws_lb.network[0].internal == false
    error_message = "NLB should be internet-facing"
  }

  assert {
    condition     = aws_lb.network[0].load_balancer_type == "network"
    error_message = "LB type should be network"
  }

  assert {
    condition     = aws_lb.network[0].tags["Name"] == "test-BU12345-APP67890-nlb"
    error_message = "NLB Name tag mismatch"
  }
}
