# Name: ecr.tf
# Owner: Saurav Mitra
# Description: This terraform config will Provision ECR Private Repository in AWS for Demo

data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

# ECR Repository
resource "aws_ecr_repository" "backend_api_ecr_repository" {
  name                 = "backend-api"
  image_tag_mutability = "IMMUTABLE"
  force_delete         = "true"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name = "${var.prefix}-backend-api"
  }
}

# IAM Instance Profile
resource "aws_iam_policy" "ecr_policy" {
  name        = "ecr-policy"
  path        = "/"
  description = "This policy will allow an EC2 instance to access ECR."

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "GetAuthorizationToken",
        "Effect" : "Allow",
        "Action" : "ecr:GetAuthorizationToken",
        "Resource" : "*"
      },
      {
        "Sid" : "AllowPushPull",
        "Effect" : "Allow",
        "Action" : [
          "ecr:BatchGetImage",
          "ecr:BatchCheckLayerAvailability",
          "ecr:CompleteLayerUpload",
          "ecr:GetDownloadUrlForLayer",
          "ecr:InitiateLayerUpload",
          "ecr:PutImage",
          "ecr:UploadLayerPart"
        ],
        "Resource" : "arn:aws:ecr:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:repository/${aws_ecr_repository.backend_api_ecr_repository.name}"
      }
    ]
  })

  tags = {
    Name = "ecr-policy"
  }
}

resource "aws_iam_role" "ecr_role" {
  name        = "ecr-role"
  description = "Allows EC2 instances to call AWS services on your behalf."

  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : "sts:AssumeRole",
        "Principal" : {
          "Service" : "ec2.amazonaws.com"
        }
      }
    ]
  })

  managed_policy_arns = [
    aws_iam_policy.ecr_policy.arn
  ]

  tags = {
    Name = "ecr-role"
  }
}

resource "aws_iam_instance_profile" "ecr_instance_profile" {
  name = "ecr-role"
  role = aws_iam_role.ecr_role.name
}
