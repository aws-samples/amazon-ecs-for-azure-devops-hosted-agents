output "aws_iam_role_arn" {
  description = "The ARN of the IAM role."
  value       = aws_iam_role.iam_role.arn
}

output "aws_iam_role_name" {
  description = "IAM role name."
  value       = aws_iam_role.iam_role.name
}