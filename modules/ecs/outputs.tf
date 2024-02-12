#This solution, non-production-ready template describes AWS Codepipeline based CICD Pipeline for terraform code deployment.
#© 2024 Amazon Web Services, Inc. or its affiliates. All Rights Reserved.
#This AWS Content is provided subject to the terms of the AWS Customer Agreement available at
#http://aws.amazon.com/agreement or other written agreement between Customer and either
#Amazon Web Services, Inc. or Amazon Web Services EMEA SARL or both.


output "ecs_task_def_arn" {
  value       = aws_ecs_task_definition.ecs_task_def.arn_without_revision
  description = "ARN of the Task Definition"
}

output "ecs_task_def_name" {
  description = "Name of the ECS Task Definition"
  value       = aws_ecs_task_definition.ecs_task_def.container_definitions
}

output "ecs_cluster_name" {
  description = "ECS Cluster name"
  value       = aws_ecs_cluster.ecs_cluster.name
}