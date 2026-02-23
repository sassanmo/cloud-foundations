module "lambda" {
  source = "../lambda"

  function_name         = var.lambda_function_name
  filename             = var.lambda_filename
  source_code_hash     = var.lambda_source_code_hash
  s3_bucket            = var.lambda_s3_bucket
  s3_key               = var.lambda_s3_key
  s3_object_version    = var.lambda_s3_object_version
  handler              = var.lambda_handler
  runtime              = var.lambda_runtime
  timeout              = var.lambda_timeout
  memory_size          = var.lambda_memory_size
  architectures        = var.lambda_architectures
  publish              = var.lambda_publish
  layers               = var.lambda_layers
  environment_variables = var.lambda_environment_variables
  additional_policy_arns = var.lambda_additional_policy_arns
  log_retention_days   = var.lambda_log_retention_days
  secrets              = var.lambda_secrets

  tags = var.tags
}

module "api_gateway" {
  source = "../../service/api_gateway"

  api_name        = var.api_name
  description     = var.api_description
  protocol_type   = var.protocol_type
  route_key       = var.route_key
  target          = module.lambda.invoke_arn
  cors_configuration = var.cors_configuration
  stage_name      = var.stage_name
  auto_deploy     = var.auto_deploy
  throttle_settings = var.throttle_settings
  access_log_destination_arn = var.access_log_destination_arn
  access_log_format = var.access_log_format

  tags = var.tags
}

resource "aws_lambda_permission" "api_gateway" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = module.lambda.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${module.api_gateway.api_arn}/*/*"
}
