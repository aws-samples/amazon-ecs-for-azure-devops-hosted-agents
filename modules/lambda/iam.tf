/* 
resource "aws_iam_role" "lambda_execution_role" {
  name = "${var.function_name}-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      },
    ]
  })
}
*/

/*
resource "aws_iam_policy" "lambda_execution_role_policy" {
  name = "${var.function_name}-policy"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Effect   = "Allow"
        Resource = "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:*"
      },
      {
        Action = [
        "ec2:Describe*"
        ]
        Effect   = "Allow"
        Resource = "*"
      },
      {
        Action = [
        "ecs:RunTask"
        ]
        Effect   = "Allow"
        Resource = "*"
      },
      {
        Effect: "Allow"
        Action: [
                "iam:PassRole"
            ]
        Resource: [
                "${var.ecs_task_exec_role_arn}",
                "${var.ecs_task_role_arn}"
            ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ambda_execution_role_policy_attachment" {
  role       = aws_iam_role.lambda_execution_role.name
  policy_arn = aws_iam_policy.lambda_execution_role_policy.arn
}
 */