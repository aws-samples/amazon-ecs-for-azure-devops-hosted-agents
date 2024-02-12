#This solution, non-production-ready template describes AWS Codepipeline based CICD Pipeline for terraform code deployment.
#© 2024 Amazon Web Services, Inc. or its affiliates. All Rights Reserved.
#This AWS Content is provided subject to the terms of the AWS Customer Agreement available at
#http://aws.amazon.com/agreement or other written agreement between Customer and either
#Amazon Web Services, Inc. or Amazon Web Services EMEA SARL or both.


#Module for creating a new S3 bucket for storing pipeline artifacts
module "s3_artifacts_bucket" {
  source                = "./modules/s3"
  project_name          = var.project_name
  kms_key_arn           = module.codepipeline_kms.arn
  codepipeline_role_arn = module.codepipeline_iam_role.role_arn
  tags = {
    Project_Name = var.project_name
    Environment  = var.environment
    Account_ID   = local.account_id
    Region       = local.region
  }
}

# Resources
data "local_file" "buildspec_local" {
  filename = "${path.module}/templates/buildspec.yml"
}

# Module for Infrastructure Source code repository
module "codecommit_ado_agent_repo" {
  source = "./modules/codecommit"

  create_new_repo          = var.create_new_repo
  source_repository_name   = var.source_repo_name
  source_repository_branch = var.source_repo_branch
  kms_key_arn              = module.codepipeline_kms.arn
  tags = {
    Project_Name = var.project_name
    Environment  = var.environment
    Account_ID   = local.account_id
    Region       = local.region
  }

}

# Module for Infrastructure Validation - CodeBuild
module "codebuild" {
  depends_on = [
    module.codecommit_ado_agent_repo
  ]
  source = "./modules/codebuild"

  project_name                        = var.project_name
  role_arn                            = module.codepipeline_iam_role.role_arn
  s3_bucket_name                      = module.s3_artifacts_bucket.bucket
  build_projects                      = var.build_projects
  build_project_source                = var.build_project_source
  builder_compute_type                = var.builder_compute_type
  builder_image                       = var.builder_image
  builder_image_pull_credentials_type = var.builder_image_pull_credentials_type
  builder_type                        = var.builder_type
  kms_key_arn                         = module.codepipeline_kms.arn
  ecr_repository_name                 = var.ecr_repo_name
  build_spec                          = data.local_file.buildspec_local.content
  container_image_tag                 = var.container_image_tag
  tags = {
    Project_Name = var.project_name
    Environment  = var.environment
    Account_ID   = local.account_id
    Region       = local.region
  }
}

module "codepipeline_kms" {
  source                = "./modules/kms"
  codepipeline_role_arn = module.codepipeline_iam_role.role_arn
  tags = {
    Project_Name = var.project_name
    Environment  = var.environment
    Account_ID   = local.account_id
    Region       = local.region
  }

}

module "codepipeline_iam_role" {
  source                            = "./modules/iam-role"
  project_name                      = var.project_name
  create_new_role                   = var.create_new_role
  codepipeline_iam_role_name        = var.create_new_role == true ? "${var.project_name}-codepipeline-role" : var.codepipeline_iam_role_name
  source_repository_name            = var.source_repo_name
  kms_key_arn                       = module.codepipeline_kms.arn
  s3_bucket_arn                     = module.s3_artifacts_bucket.arn
  infrastructure_deployer_role_name = "infra-deployer-role"
  tags = {
    Project_Name = var.project_name
    Environment  = var.environment
    Account_ID   = local.account_id
    Region       = local.region
  }
}
# Module for Infrastructure Validate, Plan, Apply and Destroy - CodePipeline
module "codepipeline" {
  depends_on = [
    module.codebuild,
    module.s3_artifacts_bucket
  ]
  source = "./modules/codepipeline"

  project_name          = var.project_name
  source_repo_name      = var.source_repo_name
  source_repo_branch    = var.source_repo_branch
  s3_bucket_name        = module.s3_artifacts_bucket.bucket
  codepipeline_role_arn = module.codepipeline_iam_role.role_arn
  stages                = var.stage_input
  kms_key_arn           = module.codepipeline_kms.arn
  tags = {
    Project_Name = var.project_name
    Environment  = var.environment
    Account_ID   = local.account_id
    Region       = local.region
  }
}


# Module for Infrastructure- ECR
module "ecr" {
  source = "./modules/ecr"

  ecr_repository_name = var.ecr_repo_name
  tags = {
    Project_Name = var.project_name
    Environment  = var.environment
    Account_ID   = local.account_id
    Region       = local.region
  }
}

module "iam_ecs_task_exec_role" {
  source = "./modules/iam"

  iam_role_name          = "${local.prefix}-ecs-task-exec-role-${var.environment}"
  iam_assume_role_policy = data.aws_iam_policy_document.ecs-assume-role-policy.json
  iam_role_policy        = data.aws_iam_policy_document.ecs_task_role_policy.json
}

module "iam_ecs_task_role" {
  source = "./modules/iam"

  iam_role_name          = "${local.prefix}-ecs-task-role-${var.environment}"
  iam_assume_role_policy = data.aws_iam_policy_document.ecs-assume-role-policy.json
  iam_role_policy        = data.aws_iam_policy_document.ecs_task_role_policy.json
}

resource "aws_cloudwatch_log_group" "ecs_log_group" {
  name              = "/ecs/ecs_ado"
  retention_in_days = 30
}

resource "aws_secretsmanager_secret" "ecs_ado_pat" {
  name                    = var.ecs_ado_patsecret_name
  description             = var.ecs_ado_patsecret_description
  recovery_window_in_days = 0 //Force delete secret upon destroy
}

## ECS
module "ecs" {
  source = "./modules/ecs"

  ecr_repo_name               = "${local.prefix}-ecr-repo-${var.environment}"
  ecs_cluster_name            = "${local.prefix}-ecs-cluster-${var.environment}"
  ecs_task_execution_role_arn = module.iam_ecs_task_exec_role.aws_iam_role_arn
  ecs_task_role_arn           = module.iam_ecs_task_role.aws_iam_role_arn
  ecs_container_def_name      = "${local.prefix}-ecs-container-${var.environment}"
  container_image             = module.ecr.repository_url
  container_image_tag         = var.container_image_tag
  container_env_vars          = var.container_env_vars
  ecs_ado_pat_secret_arn      = aws_secretsmanager_secret.ecs_ado_pat.arn
  ecs_log_group_name          = aws_cloudwatch_log_group.ecs_log_group.name
  container_port              = var.container_port
  container_host_port         = var.container_host_port
  ecs_service_name            = "${local.prefix}-ecs-svc-${var.environment}"
  ecs_service_count           = var.ecs_service_count
  ecs_service_security_groups = [var.security_groups]
  ecs_subnets                 = [var.subnet_ids]
}

# Lambda Releated resource

module "create_task_lambda_role" {
  source = "./modules/iam"

  iam_role_name          = "${local.prefix}-ecs-create-task-role-${var.environment}"
  iam_assume_role_policy = data.aws_iam_policy_document.lambda-assume-role-policy.json
  iam_role_policy        = data.aws_iam_policy_document.lambda_create_task_role_policy.json
}

module "create_task_lambda" {
  source = "./modules/lambda"

  function_name             = "ecs-create-task"
  lambda_execution_role_arn = module.create_task_lambda_role.aws_iam_role_arn
  source_path               = "./lambda_src/ecs_create_task"
  function_file             = "lambda_function.py"
  lambda_memory_size        = var.lambda_memory_size
  lambda_timeout            = var.lambda_timeout
  create_layer              = false
  lambda_concurrency        = 5
  environment_variables = {
    LogLevel               = "INFO"
    ECS_CLUSTER            = module.ecs.ecs_cluster_name
    ECS_TASK_DEFINITION    = "ecs-ado-td"
    CALLBACK_FUNCTION_NAME = "ecs-get-task"
    SUBNET_IDs             = var.subnet_ids
    SECURITY_GROUP_IDs     = var.security_groups
  }
  ecs_task_def_arn       = module.ecs.ecs_task_def_arn
  ecs_task_exec_role_arn = module.iam_ecs_task_exec_role.aws_iam_role_arn
  ecs_task_role_arn      = module.iam_ecs_task_role.aws_iam_role_arn

}

module "get_task_lambda_role" {
  source = "./modules/iam"

  iam_role_name          = "${local.prefix}-ecs-get-task-role-${var.environment}"
  iam_assume_role_policy = data.aws_iam_policy_document.lambda-assume-role-policy.json
  iam_role_policy        = data.aws_iam_policy_document.lambda_get_task_role_policy.json
}

module "get_task_lambda" {
  source = "./modules/lambda"

  function_name             = "ecs-get-task"
  lambda_execution_role_arn = module.get_task_lambda_role.aws_iam_role_arn
  source_path               = "./lambda_src/ecs_get_task"
  function_file             = "lambda_function.py"
  lambda_memory_size        = var.lambda_memory_size
  lambda_timeout            = "300"
  ecs_task_def_arn          = module.ecs.ecs_task_def_arn
  ecs_task_exec_role_arn    = module.iam_ecs_task_exec_role.aws_iam_role_arn
  ecs_task_role_arn         = module.iam_ecs_task_role.aws_iam_role_arn
  lambda_concurrency        = 5
  environment_variables = {
    LogLevel    = "INFO"
    ECS_CLUSTER = module.ecs.ecs_cluster_name
    ADO_ORG     = var.ado_org
  }
}

module "ecs_ado_api" {
  source = "./modules/apigw"

  api_gw_name           = "ecs-ado-api"
  api_description       = "API to Handle ECS Tasks as ADO agents"
  api_path_part         = "create-task"
  api_stage_name        = "dev"
  api_stage_description = "ECS Ado API Deployment"
  apigw_lambda_arn      = "arn:aws:apigateway:${data.aws_region.current.name}:lambda:path/2015-03-31/functions/${module.create_task_lambda.lambda_function_arn}/invocations"
  function_name         = module.create_task_lambda.lambda_function_name
  tags                  = local.resource_tags
}