resource "aws_ecr_repository" "terraform_ecr_repository" {
  name                 = var.ecr_repository_name
  image_tag_mutability = "MUTABLE"
  image_scanning_configuration {
    scan_on_push = true
  }
  encryption_configuration {
    encryption_type = "KMS"
  }

  force_delete    = true
  tags            = var.tags
}

resource "aws_ecr_lifecycle_policy" "terraform_ecr_repository_lifecycle_policy" {
  policy = jsonencode({
    rules = [
      {
        rulePriority = 1,
        description  = "Keep last 5 images tagged with either pull & push",
        selection = {
          tagStatus = "tagged",
          tagPrefixList = [
            "pull",
            "push"
          ],
          countType   = "imageCountMoreThan",
          countNumber = 5
        },
        action = {
          type = "expire"
        }
      }
    ]
  })
  repository = aws_ecr_repository.terraform_ecr_repository.name
}

resource "aws_ecr_repository_policy" "terraform_ecr_repository_policy" {
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "examplepolicy",
        "Effect" : "Allow",
        "Principal" : {
          "AWS" : [
            "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
          ]
        },
        "Action" : [
          "ecr:BatchGetImage",
          "ecr:BatchCheckLayerAvailability",
          "ecr:CompleteLayerUpload",
          "ecr:GetDownloadUrlForLayer",
          "ecr:GetLifecyclePolicy",
          "ecr:InitiateLayerUpload",
          "ecr:PutImage",
          "ecr:UploadLayerPart"
        ]
      }
    ]
  })

  repository = aws_ecr_repository.terraform_ecr_repository.name
}