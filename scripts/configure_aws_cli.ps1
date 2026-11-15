<#
.SYNOPSIS
    Interactive setup script for AWS CLI against LocalStack on Proxmox.
.DESCRIPTION
    Automatically configures ~/.aws/credentials and ~/.aws/config with the
    local endpoint_url, enabling seamless AWS CLI usage without requiring
    manual --endpoint-url flags.
.EXAMPLE
    .\scripts\configure_aws_cli.ps1
#>

[CmdletBinding()]
param (
    [string]$CredentialsFile = "$PSScriptRoot\..\IAM\generated_credentials.json"
)

Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "       AWS CLI LocalStack Configuration Wizard            " -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Cyan

$endpointDefault = "http://10.0.0.254:4566"
$regionDefault   = "us-east-1"
$accessKey       = ""
$secretKey       = ""
$endpointUrl     = ""
$region          = ""

# Check if auto-generated credentials from Terraform exist
if (Test-Path -Path $CredentialsFile) {
    Write-Host "[+] Detected generated credentials file: $CredentialsFile" -ForegroundColor Green
    $autoLoad = Read-Host "Would you like to auto-load these credentials? (Y/n)"
    if ($autoLoad -eq "" -or $autoLoad -match "^[yY]") {
        try {
            $json = Get-Content -Raw -Path $CredentialsFile | ConvertFrom-Json
            $accessKey   = $json.access_key_id
            $secretKey   = $json.secret_access_key
            $endpointUrl = if ($json.endpoint_url) { $json.endpoint_url } else { $endpointDefault }
            $region      = if ($json.aws_default_region) { $json.aws_default_region } else { $regionDefault }
            Write-Host "[+] Successfully loaded credentials for user: $($json.user_name)" -ForegroundColor Green
        } catch {
            Write-Warning "Could not parse credentials JSON. Falling back to manual input."
        }
    }
}

# Prompt for values if not already loaded
if (-not $accessKey) {
    $accessKey = Read-Host "Enter AWS Access Key ID"
}
if (-not $secretKey) {
    $secretKey = Read-Host "Enter AWS Secret Access Key"
}
if (-not $endpointUrl) {
    $inputEndpoint = Read-Host "Enter LocalStack Endpoint URL [Default: $endpointDefault]"
    $endpointUrl = if ($inputEndpoint) { $inputEndpoint } else { $endpointDefault }
}
if (-not $region) {
    $inputRegion = Read-Host "Enter AWS Region [Default: $regionDefault]"
    $region = if ($inputRegion) { $inputRegion } else { $regionDefault }
}

# Ensure destination directory exists
$awsDir = Join-Path -Path $HOME -ChildPath ".aws"
if (-not (Test-Path -Path $awsDir)) {
    New-Item -ItemType Directory -Force -Path $awsDir | Out-Null
    Write-Host "[+] Created directory: $awsDir" -ForegroundColor Green
}

# Write ~/.aws/credentials
$credentialsPath = Join-Path -Path $awsDir -ChildPath "credentials"
$credentialsContent = @"
[default]
aws_access_key_id = $accessKey
aws_secret_access_key = $secretKey
"@
Set-Content -Path $credentialsPath -Value $credentialsContent -Encoding Ascii
Write-Host "[+] Updated: $credentialsPath" -ForegroundColor Green

# Write ~/.aws/config with endpoint_url
$configPath = Join-Path -Path $awsDir -ChildPath "config"
$configContent = @"
[default]
region = $region
output = json
endpoint_url = $endpointUrl
"@
Set-Content -Path $configPath -Value $configContent -Encoding Ascii
Write-Host "[+] Updated: $configPath (Endpoint URL: $endpointUrl)" -ForegroundColor Green

Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "[*] Testing configuration with AWS CLI..." -ForegroundColor Yellow

try {
    $testResult = aws iam list-users 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "[SUCCESS] AWS CLI is successfully communicating with LocalStack!" -ForegroundColor Green
        Write-Host $testResult
    } else {
        Write-Warning "AWS CLI returned an error code ($LASTEXITCODE): $testResult"
    }
} catch {
    Write-Warning "Unable to execute aws command. Ensure AWS CLI is installed and in PATH."
}

Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "Setup complete! You can now run any 'aws' command without --endpoint-url flags." -ForegroundColor Cyan
