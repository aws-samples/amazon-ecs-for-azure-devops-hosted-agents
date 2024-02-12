#This solution, non-production-ready template describes AWS Codepipeline based CICD Pipeline for terraform code deployment.
#© 2024 Amazon Web Services, Inc. or its affiliates. All Rights Reserved.
#This AWS Content is provided subject to the terms of the AWS Customer Agreement available at
#http://aws.amazon.com/agreement or other written agreement between Customer and either
#Amazon Web Services, Inc. or Amazon Web Services EMEA SARL or both.

variable "project_name" {
  description = "Unique name for this project"
  type        = string
}

variable "create_new_repo" {
  description = "Whether to create a new repository. Values are true or false. Defaulted to true always."
  type        = bool
  default     = true
}

variable "ado_org" {
  description = "Ado orgname to pass it on as env var for lambda"
  type        = string
}
variable "create_new_role" {
  description = "Whether to create a new IAM Role. Values are true or false. Defaulted to true always."
  type        = bool
  default     = true
}

variable "codepipeline_iam_role_name" {
  description = "Name of the IAM role to be used by the Codepipeline"
  type        = string
  default     = "codepipeline-role"
}

variable "source_repo_name" {
  description = "Source repo name of the CodeCommit repository"
  type        = string
}

variable "source_repo_branch" {
  description = "Default branch in the Source repo for which CodePipeline needs to be configured"
  type        = string
}

variable "environment" {
  description = "Environment in which the script is run. Eg: dev, prod, etc"
  type        = string
}

variable "stage_input" {
  description = "Tags to be attached to the CodePipeline"
  type        = list(map(any))
}

variable "build_projects" {
  description = "Tags to be attached to the CodePipeline"
  type        = list(string)
}

variable "builder_compute_type" {
  description = "Relative path to the Apply and Destroy build spec file"
  type        = string
  default     = "BUILD_GENERAL1_SMALL"
}

variable "builder_image" {
  description = "Docker Image to be used by codebuild"
  type        = string
  default     = "aws/codebuild/amazonlinux2-x86_64-standard:3.0"
}

variable "builder_type" {
  description = "Type of codebuild run environment"
  type        = string
  default     = "LINUX_CONTAINER"
}

variable "builder_image_pull_credentials_type" {
  description = "Image pull credentials type used by codebuild project"
  type        = string
  default     = "CODEBUILD"
}

variable "build_project_source" {
  description = "aws/codebuild/standard:4.0"
  type        = string
  default     = "CODEPIPELINE"
}

variable "ecr_repo_name" {
  description = "Name for the ECR Repository"
  type        = string
}
variable "ecs_cluster_name" {
  description = "Name of the ECS cluster"
  type        = string
}


variable "ecs_container_def_name" {
  description = "Name for the container definition under ECS Task definition"
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


variable "ecs_service_count" {
  description = "Number of instances of the task definition to place and keep running"
}

variable "lambda_memory_size" {
  description = "lamda memrory size"
}

variable "lambda_timeout" {
  description = "lambda timeout value"
}

variable "subnet_ids" {
  description = "Subnet IDs for ECS VPC Config"
  type        = string
}


variable "security_groups" {
  description = "Security Group IDs for ECS VPC Config"
  type        = string
}

variable "ecs_ado_patsecret_name" {
  description = "Name for the Secret to store ADO PAT"
  type        = string
}
variable "ecs_ado_patsecret_description" {
  default = "This secret is used at runtime by ECS Tasks to connect to ADO to setup agents"
  type    = string
}