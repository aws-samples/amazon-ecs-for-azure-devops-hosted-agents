#This solution, non-production-ready template describes AWS Codepipeline based CICD Pipeline for terraform code deployment.
#© 2024 Amazon Web Services, Inc. or its affiliates. All Rights Reserved.
#This AWS Content is provided subject to the terms of the AWS Customer Agreement available at
#http://aws.amazon.com/agreement or other written agreement between Customer and either
#Amazon Web Services, Inc. or Amazon Web Services EMEA SARL or both.


variable "ecr_repo_name" {
  description = "Name for the ECR Repository"
  type        = string
}
variable "ecs_cluster_name" {
  description = "Name of the ECS cluster"
  type        = string
}

# ECS Task Definition
variable "ecs_task_execution_role_arn" {
  description = "ARN of the task execution role that the Amazon ECS container agent and the Docker daemon can assume"
  type        = string
}

variable "ecs_task_role_arn" {
  description = "ARN of IAM role that allows your Amazon ECS container task to make calls to other AWS services"
  type        = string
}

variable "ecs_container_def_name" {
  description = "Name for the container definition under ECS Task definition"
  type        = string
}

variable "container_image" {
  description = "Container image to run"
  type        = string
}

variable "container_image_tag" {
  description = "Container image to tag to be selected"
  type        = string
}

variable "container_env_vars" {
  description = "The container environmnent variables"
  type        = list(any)
}
variable "container_port" {
  description = "Port on the container to associate with the load balancer"
  type        = number
}
variable "container_host_port" {
  description = "The port number on the container instance to reserve for the container."
  type        = number
}

# ECS Service
variable "ecs_service_name" {
  description = "Name for the ECS Service resource"
  type        = string
}

variable "ecs_service_security_groups" {
  description = "List of security groups for ECS svc"
  type        = list(string)
}
variable "ecs_subnets" {
  description = "List of Private subnet IDs for ECS"
  type        = list(string)
}

variable "ecs_service_count" {
  description = "Number of instances of the task definition to place and keep running"
}

variable "ecs_log_group_name" {
  description = "CW Log Group Name for ECS Task Logs"
  type        = string
}

variable "ecs_ado_pat_secret_arn" {
  description = "ARN of the ADO PAT from Secret maanger Secret"
  type        = string
}
