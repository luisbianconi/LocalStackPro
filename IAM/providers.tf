terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.4"
    }
  }
}

provider "aws" {
  region                      = "us-east-1"
  access_key                  = "mock_access_key"
  secret_key                  = "mock_secret_key"
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true
  s3_use_path_style           = true

  # Redirect all AWS service API calls to the private Proxmox LocalStack instance
  endpoints {
    iam        = "http://10.0.0.254:4566"
    sts        = "http://10.0.0.254:4566"
    s3         = "http://10.0.0.254:4566"
    ec2        = "http://10.0.0.254:4566"
    rds        = "http://10.0.0.254:4566"
    lambda     = "http://10.0.0.254:4566"
    sqs        = "http://10.0.0.254:4566"
    sns        = "http://10.0.0.254:4566"
    dynamodb   = "http://10.0.0.254:4566"
    cloudwatch = "http://10.0.0.254:4566"
    eks        = "http://10.0.0.254:4566"
  }
}
