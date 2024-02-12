provider_region     = "eu-west-2" //Replace with the preferred region
project_name        = "ado-ecs-runner"
environment         = "dev"
source_repo_name    = "ado-ecs-repo"
source_repo_branch  = "main"
create_new_repo     = true
create_new_role     = true

stage_input = [
  { name = "build-image", category = "Test", owner = "AWS", provider = "CodeBuild", input_artifacts = "SourceOutput", output_artifacts = "ValidateOutput-terraform" }
]
build_projects = ["build-image"]

# ECS   
container_env_vars = [
  { name = "LOG_LEVEL", value = "DEBUG" },
  { name = "PORT", value = "80" },
  { name = "AZP_URL", value = "https://dev.azure.com/change-me/" },// Replace with your ADO Org URL
  { name = "AZP_POOL", value = "ecscluster" }, // Replace with your ADO Agent Pool name
]
container_port      = 80
container_host_port = 80
ecs_service_count   = "2"
container_image_tag    = "ado-ecs"
ecr_repo_name          = "ado-ecs-ecr"
ecs_cluster_name       = "ado-ecs"
ecs_container_def_name = "ado-ecs-tf"
ecs_service_name       = "ado-ecs-svc"
ecs_ado_patsecret_name = "ecs-ado-pat-secret"

lambda_memory_size = "128"
lambda_timeout     = "90"

subnet_ids      = "subnet-change-me" // Replace with subnet-id from your account
security_groups = "sg-change-me"     // Replace with security-group-id from your account

ado_org = "change-me"  // Replace with your ADO Org ID
