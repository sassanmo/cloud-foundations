locals {
  step_functions_role_name = "${var.state_machine_name}-role"
  log_group_name          = "/aws/stepfunctions/${var.state_machine_name}"

  step_functions_assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "states.amazonaws.com"
        }
      }
    ]
  })

  step_functions_policy_arns = concat([
    "arn:aws:iam::aws:policy/service-role/AWSStepFunctionsBasicExecutionRole"
  ], var.additional_policy_arns)
}

