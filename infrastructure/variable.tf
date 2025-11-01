variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "api_gateway_stage" {
  description = "API Gateway stage"
  type        = string
  default     = "PRODUCTION"
}

variable "aws_dynamodb_table" {
  description = "AWS DynamoDB table"
  type        = string
  default     = "expenses-table"
}

variable "github_token" {
  description = "GitHub personal access token for Amplify"
  type        = string
  sensitive   = true
}

variable "github_repository" {
  description = "GitHub repository URL"
  type        = string
  default     = "https://github.com/inornnut01/ExpensesSeverless-frontend-Amplify.git"
}