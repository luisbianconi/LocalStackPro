# ==============================================================================
# AWS Identity and Access Management (IAM) Lab Module
# Objective: Implement AWS Well-Architected Framework security best practices
# by provisioning an administrator user, a group, policy attachment, and programmatic keys.
# ==============================================================================

# 1. IAM Group
# Best Practice: Assign permissions to groups rather than individual users.
resource "aws_iam_group" "administrators" {
  name = "cloud-administrators"
  path = "/admins/"
}

# 2. IAM User
# Best Practice: Do not use the AWS Root account for day-to-day operations.
resource "aws_iam_user" "admin_user" {
  name = "admin-luisbianconi"
  path = "/admins/"

  tags = {
    Environment = "Homelab"
    Role        = "CloudAdministrator"
    ManagedBy   = "Terraform"
    Project     = "AWS-Mastery-Lab"
  }
}

# 3. IAM Group Membership
# Assigns the IAM user to the administrators group.
resource "aws_iam_group_membership" "admin_team" {
  name  = "admin-team-membership"
  group = aws_iam_group.administrators.name

  users = [
    aws_iam_user.admin_user.name
  ]
}

# 4. IAM Customer Managed Policy
# Defines the permissions JSON document (Effect, Action, Resource).
resource "aws_iam_policy" "admin_policy" {
  name        = "AdministratorAccessPolicy"
  description = "Provides full administrative access across cloud resources."

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "AllowFullAccessToAllServices"
        Effect   = "Allow"
        Action   = "*"
        Resource = "*"
      }
    ]
  })
}

# 5. Policy Attachment
# Attaches the Administrator policy directly to the IAM Group.
resource "aws_iam_group_policy_attachment" "attach_admin_policy" {
  group      = aws_iam_group.administrators.name
  policy_arn = aws_iam_policy.admin_policy.arn
}

# 6. Programmatic Access Keys
# Generates AWS Access Key ID and Secret Access Key for CLI / SDK usage.
resource "aws_iam_access_key" "admin_key" {
  user = aws_iam_user.admin_user.name
}

# 7. Local Output Artifact (Lab Convenience)
# Automatically saves generated lab credentials to a JSON file for testing and portfolio showcase.
resource "local_file" "admin_credentials" {
  filename = "${path.module}/generated_credentials.json"
  content = jsonencode({
    notice             = "MOCK CREDENTIALS FOR LOCAL LAB ONLY - NO REAL-WORLD AWS VALIDITY"
    user_name          = aws_iam_user.admin_user.name
    user_arn           = aws_iam_user.admin_user.arn
    access_key_id      = aws_iam_access_key.admin_key.id
    secret_access_key  = aws_iam_access_key.admin_key.secret
    aws_default_region = "us-east-1"
    endpoint_url       = "http://10.0.0.254:4566"
  })
}
