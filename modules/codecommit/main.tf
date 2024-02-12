#This solution, non-production-ready template describes AWS Codepipeline based CICD Pipeline for terraform code deployment.
#© 2024 Amazon Web Services, Inc. or its affiliates. All Rights Reserved.
#This AWS Content is provided subject to the terms of the AWS Customer Agreement available at
#http://aws.amazon.com/agreement or other written agreement between Customer and either
#Amazon Web Services, Inc. or Amazon Web Services EMEA SARL or both.

resource "aws_codecommit_repository" "source_repository" {
  count           = var.create_new_repo ? 1 : 0
  repository_name = var.source_repository_name
  default_branch  = var.source_repository_branch
  description     = "Code Repository for hosting the terraform code and pipeline configuration files"
  tags            = var.tags
}

