resource "aws_iam_role" "iam_role" {
  name                  = var.iam_role_name
  assume_role_policy    = var.iam_assume_role_policy
}
 
resource "aws_iam_policy" "iam_role_policy" {
  name          = var.iam_role_name
  description   = "Policy that allows access to IAM role created with aws_iam_role.iam_role"
  policy        = var.iam_role_policy
}
 
resource "aws_iam_role_policy_attachment" "ecs-task-role-policy-attachment" {
  role          = aws_iam_role.iam_role.name
  policy_arn    = aws_iam_policy.iam_role_policy.arn
}