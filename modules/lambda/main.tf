

# For functions with no dependencies
data "archive_file" "lambda_package" {
  type        = "zip"
  source_dir  = var.source_path
  output_path = "${path.module}/src/${var.function_name}.zip"
  excludes    = ["${var.function_name}.zip"]
}


resource "aws_lambda_function" "lambda_function" {
  filename      = data.archive_file.lambda_package.output_path
  function_name = var.function_name
  role          = var.lambda_execution_role_arn
  handler       = "lambda_function.lambda_handler"
  memory_size   = var.lambda_memory_size
  timeout       = var.lambda_timeout
  layers        = var.create_layer ? [aws_lambda_layer_version.lambda_layer[0].arn] : []

  source_code_hash = data.archive_file.lambda_package.output_base64sha256

  runtime = "python3.9"

  reserved_concurrent_executions = var.lambda_concurrency
  
  tracing_config {
    mode = "Active"
  }
  
  dynamic "environment" {
    for_each = length(keys(var.environment_variables)) == 0 ? [] : [true]
    content {
      variables = var.environment_variables
    }
  }
}

/* resource "null_resource" "lambda_package_dependencies" {
  count = var.create_layer ? 1 : 0

  provisioner "local-exec" {
    command     = "cd ${var.source_path} && mkdir python && pip install -r requirements.txt -t python/ -U && zip -r ../../${path.module}/lambda_layer_package.zip python/"
    interpreter = ["bash", "-c"]
  }
  triggers = {
    always_run = "${timestamp()}"
  }
}


resource "aws_lambda_layer_version" "lambda_layer" {
  count = var.create_layer ? 1 : 0

  filename   = "${path.module}/lambda_layer_package.zip"
  layer_name = "${var.function_name}-layer"

  compatible_runtimes = ["python3.9"]
  depends_on          = [null_resource.lambda_package_dependencies]

}
 */

 resource "null_resource" "install_dependencies" {
    count = var.create_layer ? 1 : 0

  
  provisioner "local-exec" {
    working_dir = "${path.module}/src/package"
    command = "/bin/bash package.sh"
  }
  triggers = {
    always_run = "${timestamp()}"
  }
}

data "archive_file" "lambda_layer_package" {
    count = var.create_layer ? 1 : 0

  type        = "zip"
  source_dir  = "${path.module}/src/package"
  output_path = "${path.module}/src/package/layer.zip"
  excludes    = ["layer.zip", "package.sh"]
  depends_on  = [null_resource.install_dependencies]
}


resource "aws_lambda_layer_version" "lambda_layer" {
    count = var.create_layer ? 1 : 0

  filename   = data.archive_file.lambda_layer_package[0].output_path
  layer_name = "${var.function_name}-layer"

  compatible_runtimes = ["python3.9"]
}
