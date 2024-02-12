## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.20.1 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 4.20.1 |
| <a name="provider_local"></a> [local](#provider\_local) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_codebuild"></a> [codebuild](#module\_codebuild) | ./modules/codebuild | n/a |
| <a name="module_codecommit_ado_agent_repo"></a> [codecommit\_ado\_agent\_repo](#module\_codecommit\_ado\_agent\_repo) | ./modules/codecommit | n/a |
| <a name="module_codepipeline"></a> [codepipeline](#module\_codepipeline) | ./modules/codepipeline | n/a |
| <a name="module_codepipeline_iam_role"></a> [codepipeline\_iam\_role](#module\_codepipeline\_iam\_role) | ./modules/iam-role | n/a |
| <a name="module_codepipeline_kms"></a> [codepipeline\_kms](#module\_codepipeline\_kms) | ./modules/kms | n/a |
| <a name="module_create_task_lambda"></a> [create\_task\_lambda](#module\_create\_task\_lambda) | ./modules/lambda | n/a |
| <a name="module_create_task_lambda_role"></a> [create\_task\_lambda\_role](#module\_create\_task\_lambda\_role) | ./modules/iam | n/a |
| <a name="module_ecr"></a> [ecr](#module\_ecr) | ./modules/ecr | n/a |
| <a name="module_ecs"></a> [ecs](#module\_ecs) | ./modules/ecs | n/a |
| <a name="module_ecs_ado_api"></a> [ecs\_ado\_api](#module\_ecs\_ado\_api) | ./modules/apigw | n/a |
| <a name="module_get_task_lambda"></a> [get\_task\_lambda](#module\_get\_task\_lambda) | ./modules/lambda | n/a |
| <a name="module_get_task_lambda_role"></a> [get\_task\_lambda\_role](#module\_get\_task\_lambda\_role) | ./modules/iam | n/a |
| <a name="module_iam_ecs_task_exec_role"></a> [iam\_ecs\_task\_exec\_role](#module\_iam\_ecs\_task\_exec\_role) | ./modules/iam | n/a |
| <a name="module_iam_ecs_task_role"></a> [iam\_ecs\_task\_role](#module\_iam\_ecs\_task\_role) | ./modules/iam | n/a |
| <a name="module_s3_artifacts_bucket"></a> [s3\_artifacts\_bucket](#module\_s3\_artifacts\_bucket) | ./modules/s3 | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_log_group.ecs_log_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_secretsmanager_secret.ecs_ado_pat](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy_document.ecs-assume-role-policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.ecs_task_role_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.lambda-assume-role-policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.lambda_create_task_role_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.lambda_get_task_role_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |
| [local_file.buildspec_local](https://registry.terraform.io/providers/hashicorp/local/latest/docs/data-sources/file) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_ado_org"></a> [ado\_org](#input\_ado\_org) | Ado orgname to pass it on as env var for lambda | `string` | n/a | yes |
| <a name="input_build_project_source"></a> [build\_project\_source](#input\_build\_project\_source) | aws/codebuild/standard:4.0 | `string` | `"CODEPIPELINE"` | no |
| <a name="input_build_projects"></a> [build\_projects](#input\_build\_projects) | Tags to be attached to the CodePipeline | `list(string)` | n/a | yes |
| <a name="input_builder_compute_type"></a> [builder\_compute\_type](#input\_builder\_compute\_type) | Relative path to the Apply and Destroy build spec file | `string` | `"BUILD_GENERAL1_SMALL"` | no |
| <a name="input_builder_image"></a> [builder\_image](#input\_builder\_image) | Docker Image to be used by codebuild | `string` | `"aws/codebuild/amazonlinux2-x86_64-standard:3.0"` | no |
| <a name="input_builder_image_pull_credentials_type"></a> [builder\_image\_pull\_credentials\_type](#input\_builder\_image\_pull\_credentials\_type) | Image pull credentials type used by codebuild project | `string` | `"CODEBUILD"` | no |
| <a name="input_builder_type"></a> [builder\_type](#input\_builder\_type) | Type of codebuild run environment | `string` | `"LINUX_CONTAINER"` | no |
| <a name="input_codepipeline_iam_role_name"></a> [codepipeline\_iam\_role\_name](#input\_codepipeline\_iam\_role\_name) | Name of the IAM role to be used by the Codepipeline | `string` | `"codepipeline-role"` | no |
| <a name="input_container_env_vars"></a> [container\_env\_vars](#input\_container\_env\_vars) | The container environmnent variables | `list(any)` | n/a | yes |
| <a name="input_container_host_port"></a> [container\_host\_port](#input\_container\_host\_port) | The port number on the container instance to reserve for the container. | `number` | n/a | yes |
| <a name="input_container_image_tag"></a> [container\_image\_tag](#input\_container\_image\_tag) | Container image to tag to be selected | `string` | n/a | yes |
| <a name="input_container_port"></a> [container\_port](#input\_container\_port) | Port on the container to associate with the load balancer | `number` | n/a | yes |
| <a name="input_create_new_repo"></a> [create\_new\_repo](#input\_create\_new\_repo) | Whether to create a new repository. Values are true or false. Defaulted to true always. | `bool` | `true` | no |
| <a name="input_create_new_role"></a> [create\_new\_role](#input\_create\_new\_role) | Whether to create a new IAM Role. Values are true or false. Defaulted to true always. | `bool` | `true` | no |
| <a name="input_ecr_repo_name"></a> [ecr\_repo\_name](#input\_ecr\_repo\_name) | Name for the ECR Repository | `string` | n/a | yes |
| <a name="input_ecs_ado_patsecret_description"></a> [ecs\_ado\_patsecret\_description](#input\_ecs\_ado\_patsecret\_description) | n/a | `string` | `"This secret is used at runtime by ECS Tasks to connect to ADO to setup agents"` | no |
| <a name="input_ecs_ado_patsecret_name"></a> [ecs\_ado\_patsecret\_name](#input\_ecs\_ado\_patsecret\_name) | Name for the Secret to store ADO PAT | `string` | n/a | yes |
| <a name="input_ecs_cluster_name"></a> [ecs\_cluster\_name](#input\_ecs\_cluster\_name) | Name of the ECS cluster | `string` | n/a | yes |
| <a name="input_ecs_container_def_name"></a> [ecs\_container\_def\_name](#input\_ecs\_container\_def\_name) | Name for the container definition under ECS Task definition | `string` | n/a | yes |
| <a name="input_ecs_service_count"></a> [ecs\_service\_count](#input\_ecs\_service\_count) | Number of instances of the task definition to place and keep running | `any` | n/a | yes |
| <a name="input_ecs_service_name"></a> [ecs\_service\_name](#input\_ecs\_service\_name) | Name for the ECS Service resource | `string` | n/a | yes |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment in which the script is run. Eg: dev, prod, etc | `string` | n/a | yes |
| <a name="input_lambda_memory_size"></a> [lambda\_memory\_size](#input\_lambda\_memory\_size) | lamda memrory size | `any` | n/a | yes |
| <a name="input_lambda_timeout"></a> [lambda\_timeout](#input\_lambda\_timeout) | lambda timeout value | `any` | n/a | yes |
| <a name="input_project_name"></a> [project\_name](#input\_project\_name) | Unique name for this project | `string` | n/a | yes |
| <a name="input_security_groups"></a> [security\_groups](#input\_security\_groups) | Security Group IDs for ECS VPC Config | `string` | n/a | yes |
| <a name="input_source_repo_branch"></a> [source\_repo\_branch](#input\_source\_repo\_branch) | Default branch in the Source repo for which CodePipeline needs to be configured | `string` | n/a | yes |
| <a name="input_source_repo_name"></a> [source\_repo\_name](#input\_source\_repo\_name) | Source repo name of the CodeCommit repository | `string` | n/a | yes |
| <a name="input_stage_input"></a> [stage\_input](#input\_stage\_input) | Tags to be attached to the CodePipeline | `list(map(any))` | n/a | yes |
| <a name="input_subnet_ids"></a> [subnet\_ids](#input\_subnet\_ids) | Subnet IDs for ECS VPC Config | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_clone_url_http_grc"></a> [clone\_url\_http\_grc](#output\_clone\_url\_http\_grc) | HTTP (GRC) URL for CodeCommit Repo |
| <a name="output_codecommit_url_http"></a> [codecommit\_url\_http](#output\_codecommit\_url\_http) | HTTP URL for CodeCommit Repo |
| <a name="output_ecs_ado_api_invoke_url"></a> [ecs\_ado\_api\_invoke\_url](#output\_ecs\_ado\_api\_invoke\_url) | URL to invoke ADO hosted agents dynamically via ECS Tasks |
| <a name="output_ecs_ado_pat_secret_arn"></a> [ecs\_ado\_pat\_secret\_arn](#output\_ecs\_ado\_pat\_secret\_arn) | Secret ARN to update with ADO PAT to setup agents |
