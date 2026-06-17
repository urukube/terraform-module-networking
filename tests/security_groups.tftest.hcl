variables {
  env           = "test"
  friendly_name = "test"
  bu_id         = "BU12345"
  app_id        = "APP67890"
  vpc_cidr      = "10.0.0.0/16"
  azs           = ["us-east-1a", "us-east-1b"]
}

run "sg_defaults" {
  command = plan

  assert {
    condition     = aws_security_group.eks_nodes != null
    error_message = "EKS Nodes SG missing"
  }

  assert {
    condition     = startswith(aws_security_group.eks_nodes.name_prefix, "test-BU12345-APP67890-eks-nodes-sg-")
    error_message = "EKS Nodes SG name prefix mismatch"
  }

  assert {
    condition     = aws_security_group.eks_control_plane != null
    error_message = "EKS Control Plane SG missing"
  }

  assert {
    condition     = aws_security_group.vpc_endpoints != []
    error_message = "VPC Endpoints SG should be created by default"
  }
}

run "sg_istio_enabled" {
  command = plan

  variables {
    enable_istio_support = true
  }

  assert {
    condition     = length(aws_security_group.istio) == 1
    error_message = "Istio SG missing when enabled"
  }

  assert {
    condition     = startswith(aws_security_group.istio[0].name_prefix, "test-BU12345-APP67890-istio-sg-")
    error_message = "Istio SG name prefix mismatch"
  }
}

run "sg_alb_enabled" {
  command = plan

  variables {
    enable_alb = true
  }

  assert {
    condition     = length(aws_security_group.alb) == 1
    error_message = "ALB SG missing when enabled"
  }

  assert {
    condition     = startswith(aws_security_group.alb[0].name_prefix, "test-BU12345-APP67890-alb-sg-")
    error_message = "ALB SG name prefix mismatch"
  }
}
