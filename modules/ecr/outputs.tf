#This solution, non-production-ready template describes AWS Codepipeline based CICD Pipeline for terraform code deployment.
#© 2024 Amazon Web Services, Inc. or its affiliates. All Rights Reserved.
#This AWS Content is provided subject to the terms of the AWS Customer Agreement available at
#http://aws.amazon.com/agreement or other written agreement between Customer and either
#Amazon Web Services, Inc. or Amazon Web Services EMEA SARL or both.

output "arn" {
  value       = aws_ecr_repository.terraform_ecr_repository.arn
  description = "Full ARN of the ECR repository."
}

output "repository_url" {
  value       = aws_ecr_repository.terraform_ecr_repository.repository_url
  description = "The URL of the repository (in the form aws_account_id.dkr.ecr.region.amazonaws.com/repositoryName)."
}

output "registry_id" {
  value       = aws_ecr_repository.terraform_ecr_repository.id
  description = "The registry ID where the repository was created."
}


