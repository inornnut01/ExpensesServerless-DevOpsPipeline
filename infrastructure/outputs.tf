# API Gateway Outputs
output "api_gateway_url" {
  description = "API Gateway URL"
  value       = "${aws_api_gateway_stage.production.invoke_url}/expenses"
}

output "api_gateway_id" {
  description = "API Gateway REST API ID"
  value       = aws_api_gateway_rest_api.expenses_api.id
}

# Cognito Outputs
output "user_pool_id" {
  description = "Cognito User Pool ID"
  value       = aws_cognito_user_pool.expenses_user_pool.id
}

output "user_pool_client_id" {
  description = "Cognito User Pool Client ID"
  value       = aws_cognito_user_pool_client.expenses_client.id
}

output "user_pool_endpoint" {
  description = "Cognito User Pool Endpoint"
  value       = aws_cognito_user_pool.expenses_user_pool.endpoint
}

output "user_pool_arn" {
  description = "Cognito User Pool ARN"
  value       = aws_cognito_user_pool.expenses_user_pool.arn
}

# DynamoDB Outputs
output "dynamodb_table_name" {
  description = "DynamoDB Table Name"
  value       = module.expense_dynamodb_table.dynamodb_table_id
}

output "dynamodb_table_arn" {
  description = "DynamoDB Table ARN"
  value       = module.expense_dynamodb_table.dynamodb_table_arn
}

# Lambda Outputs
output "lambda_layer_arn" {
  description = "Lambda Layer ARN"
  value       = module.lambda_layer_shared.lambda_layer_arn
}

output "lambda_create_expense_arn" {
  description = "Create Expense Lambda Function ARN"
  value       = module.lambda_create_expense.lambda_function_arn
}

output "lambda_get_expenses_arn" {
  description = "Get Expenses Lambda Function ARN"
  value       = module.lambda_get_expenses.lambda_function_arn
}

output "lambda_update_expense_arn" {
  description = "Update Expense Lambda Function ARN"
  value       = module.lambda_update_expense.lambda_function_arn
}

output "lambda_delete_expense_arn" {
  description = "Delete Expense Lambda Function ARN"
  value       = module.lambda_delete_expense.lambda_function_arn
}

output "amplify_app_id" {
  description = "Amplify App ID"
  value       = aws_amplify_app.expenses_frontend.id
}

output "amplify_app_url" {
  description = "Amplify App URL"
  value       = "https://${aws_amplify_branch.main.branch_name}.${aws_amplify_app.expenses_frontend.default_domain}"
}

# Monitoring & Alerting Outputs
output "sns_topic_arn" {
  description = "SNS Topic ARN for CloudWatch Alarms"
  value       = aws_sns_topic.expenses_alarms.arn
}

output "sns_topic_name" {
  description = "SNS Topic Name"
  value       = aws_sns_topic.expenses_alarms.name
}

output "api_gateway_log_group" {
  description = "CloudWatch Log Group for API Gateway"
  value       = aws_cloudwatch_log_group.api_gateway.name
}

output "cloudwatch_alarms" {
  description = "List of CloudWatch Alarm names"
  value = [
    aws_cloudwatch_metric_alarm.lambda_create_expense_errors.alarm_name,
    aws_cloudwatch_metric_alarm.lambda_get_expenses_errors.alarm_name,
    aws_cloudwatch_metric_alarm.lambda_update_expense_errors.alarm_name,
    aws_cloudwatch_metric_alarm.lambda_delete_expense_errors.alarm_name,
    aws_cloudwatch_metric_alarm.api_gateway_5xx_errors.alarm_name,
    aws_cloudwatch_metric_alarm.dynamodb_read_throttle.alarm_name,
    aws_cloudwatch_metric_alarm.dynamodb_write_throttle.alarm_name,
    aws_cloudwatch_metric_alarm.dynamodb_user_errors.alarm_name,
  ]
}

