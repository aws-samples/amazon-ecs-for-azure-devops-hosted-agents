variable "function_name" {
  description = "Lambda Function name"
}

variable "source_path" {
  description = "Path for lambda source code"
  type        = string
}

variable "function_file" {
  description = "Lambda code file name"
  type        = string
}

variable "lambda_memory_size" {
  description = "lamda memrory size"
}

variable "lambda_timeout" {
  description = "lambda timeout value"
}

variable "lambda_concurrency" {
  description = "Concurrency value for the Lambda"
  type = number
}

variable "environment_variables" {
  description = "A map that defines environment variables for the Lambda Function."
  type        = map(string)
  default     = {}
}

variable "create_layer" {
  description = "Controls whether Lambda layer should be created"
  type        = bool
  default     = true
}

variable "ecs_task_def_arn" {
  description = "ARN of the ECS Task Definition"
  type        = string
}

variable "ecs_task_exec_role_arn" {
  description = "ARN for the Task Execution Role"
  type        = string
}

variable "ecs_task_role_arn" {
  description = "ARN for the Task Role"
  type        = string
}

variable "lambda_execution_role_arn" {
  description = "ARN for the Lambda Role"
  type        = string
}