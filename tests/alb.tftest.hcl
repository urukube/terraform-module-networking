variables {
  env           = "test"
  friendly_name = "test"
  bu_id         = "BU12345"
  app_id        = "APP67890"
  vpc_cidr      = "10.0.0.0/16"
  azs           = ["us-east-1a", "us-east-1b"]
  enable_alb    = true
}

run "alb_verification" {
  command = plan

  assert {
    condition     = length(aws_lb.application) == 1
    error_message = "ALB should be created"
  }

  assert {
    condition     = aws_lb.application[0].name == "test-BU12345-APP67890-alb"
    error_message = "ALB name mismatch"
  }

  assert {
    condition     = aws_lb.application[0].internal == false
    error_message = "ALB should be internet-facing"
  }

  assert {
    condition     = length(aws_lb_target_group.application) == 1
    error_message = "ALB Target Group should be created"
  }

  assert {
    condition     = aws_lb_target_group.application[0].name == "test-BU12345-APP67890-alb-tg"
    error_message = "ALB Target Group name mismatch"
  }

  assert {
    condition     = length(aws_lb_listener.application_http) == 1
    error_message = "ALB HTTP Listener should be created"
  }

  assert {
    condition     = aws_lb.application[0].tags["Name"] == "test-BU12345-APP67890-alb"
    error_message = "ALB Name tag mismatch"
  }
}
