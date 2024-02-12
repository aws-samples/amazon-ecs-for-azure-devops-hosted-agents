#This solution, non-production-ready template describes AWS Codepipeline based CICD Pipeline for terraform code deployment.
#© 2024 Amazon Web Services, Inc. or its affiliates. All Rights Reserved.
#This AWS Content is provided subject to the terms of the AWS Customer Agreement available at
#http://aws.amazon.com/agreement or other written agreement between Customer and either
#Amazon Web Services, Inc. or Amazon Web Services EMEA SARL or both.

resource "aws_ecs_cluster" "ecs_cluster" {
  name = var.ecs_cluster_name
}

resource "aws_ecs_task_definition" "ecs_task_def" {
  family                   = "ecs-ado-td"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 256
  memory                   = 512
  execution_role_arn       = var.ecs_task_execution_role_arn //aws_iam_role.ecs_task_execution_role.arn
  task_role_arn            = var.ecs_task_role_arn           //aws_iam_role.ecs_task_role.arn
  container_definitions = jsonencode([{
    name        = var.ecs_container_def_name
    image       = "${var.container_image}:${var.container_image_tag}"
    essential   = true
    environment = var.container_env_vars
    #readonlyRootFilesystem = true
    secrets = [
      {
        name      = "AZP_TOKEN",
        valueFrom = var.ecs_ado_pat_secret_arn
      }

    ]
    portMappings = [{
      protocol      = "tcp"
      containerPort = var.container_port
      hostPort      = var.container_host_port
    }]
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        awslogs-group         = var.ecs_log_group_name
        awslogs-region        = data.aws_region.current.name
        awslogs-stream-prefix = "ecs"
      }
    }
  }])
}
