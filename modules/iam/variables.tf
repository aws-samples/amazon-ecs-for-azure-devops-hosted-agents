variable "iam_role_name" {
    description = "Name for the IAM role to be created using this module."
    type        = string
}

variable "iam_assume_role_policy" {
    description = "Policy document for IAM assume role"
}

variable "iam_role_policy" {
    description = "Policy document to be attached to the IAM role created"
}