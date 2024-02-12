#This solution, non-production-ready template describes AWS Codepipeline based CICD Pipeline for terraform code deployment.
#© 2024 Amazon Web Services, Inc. or its affiliates. All Rights Reserved.
#This AWS Content is provided subject to the terms of the AWS Customer Agreement available at
#http://aws.amazon.com/agreement or other written agreement between Customer and either
#Amazon Web Services, Inc. or Amazon Web Services EMEA SARL or both.

resource "aws_api_gateway_rest_api" "api" {
  name        = var.api_gw_name
  description = var.api_description
  lifecycle {
    create_before_destroy = true
  }

  tags = var.tags

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}


resource "aws_api_gateway_resource" "version_one" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = var.version_prefix
}


resource "aws_api_gateway_resource" "post-method" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_resource.version_one.id
  path_part   = var.api_path_part
}

resource "aws_api_gateway_method" "post-method" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.post-method.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "post-method" {
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.post-method.id
  http_method             = aws_api_gateway_method.post-method.http_method
  type                    = "AWS_PROXY"
  uri                     = var.apigw_lambda_arn
  integration_http_method = "POST"
}

resource "aws_lambda_permission" "api_lambda" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = var.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "arn:aws:execute-api:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:${aws_api_gateway_rest_api.api.id}/*/*/*"
}

resource "aws_api_gateway_deployment" "api_deployment" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  stage_name  = var.api_stage_name
  description = var.api_stage_description
  depends_on  = [aws_api_gateway_integration.post-method]
  
  triggers = {
    redeployment = sha1(jsonencode([aws_api_gateway_rest_api.api.body]))
  }

  lifecycle {
    create_before_destroy = true
  }
}