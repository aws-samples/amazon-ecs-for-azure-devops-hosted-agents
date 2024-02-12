#This solution, non-production-ready template describes AWS Codepipeline based CICD Pipeline for terraform code deployment.
#© 2024 Amazon Web Services, Inc. or its affiliates. All Rights Reserved.
#This AWS Content is provided subject to the terms of the AWS Customer Agreement available at
#http://aws.amazon.com/agreement or other written agreement between Customer and either
#Amazon Web Services, Inc. or Amazon Web Services EMEA SARL or both.

variable "api_gw_name" {
  description = "Name of the API GW Name"
  type        = string
}

variable "api_description" {
  description = "Description of the API GW Name"
  type        = string
}

variable "tags" {
  description = "Tags to be applied to the API GW Resource"
  type        = map(any)
}

variable "version_prefix" {
  description = "API GW Version Path Prefix"
  type        = string
  default     = "v1"
}

variable "api_path_part" {
  description = "API GW Path"
  type        = string
}

variable "api_stage_name" {
  description = "Name of the API GW Stage"
  type        = string
  default     = "dev"
}

variable "api_stage_description" {
  description = "Description for the API GW Stage"
  type        = string
}

variable "apigw_lambda_arn" {
  description = "Invocation ARN of the target Lambda"
  type        = string
}

variable "function_name" {
  description = "Lambda Function name"
}
