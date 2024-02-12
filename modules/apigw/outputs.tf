#This solution, non-production-ready template describes AWS Codepipeline based CICD Pipeline for terraform code deployment.
#© 2024 Amazon Web Services, Inc. or its affiliates. All Rights Reserved.
#This AWS Content is provided subject to the terms of the AWS Customer Agreement available at
#http://aws.amazon.com/agreement or other written agreement between Customer and either
#Amazon Web Services, Inc. or Amazon Web Services EMEA SARL or both.

output "api_invoke_url" {
  value       = "${aws_api_gateway_deployment.api_deployment.invoke_url}/${var.version_prefix}/${var.api_path_part}"
  description = "Invoke URL for the Create Task API"
}