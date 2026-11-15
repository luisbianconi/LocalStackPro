output "admin_user_arn" {
  description = "Unique Amazon Resource Name (ARN) of the provisioned IAM User"
  value       = aws_iam_user.admin_user.arn
}

output "admin_user_name" {
  description = "Name of the provisioned IAM User"
  value       = aws_iam_user.admin_user.name
}

output "admin_group_name" {
  description = "Name of the IAM Administrators Group"
  value       = aws_iam_group.administrators.name
}

output "admin_access_key_id" {
  description = "Programmatic Access Key ID for AWS CLI authentication"
  value       = aws_iam_access_key.admin_key.id
}

output "admin_secret_access_key" {
  description = "Programmatic Secret Access Key (Lab environment)"
  value       = aws_iam_access_key.admin_key.secret
  sensitive   = true
}

output "credentials_file_path" {
  description = "Path to the generated JSON credentials file"
  value       = local_file.admin_credentials.filename
}
