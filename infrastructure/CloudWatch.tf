# ========================================
# SNS Topic for CloudWatch Alarms
# ========================================

resource "aws_sns_topic" "expenses_alarms" {
  name         = "expenses-alarms"
  display_name = "Expenses API Alarms"

  tags = {
    Name        = "Serverless Expenses Alarms"
    Environment = "Production"
  }
}

# SNS Email Subscription (requires manual confirmation)
# The email recipient will need to confirm subscription via email
resource "aws_sns_topic_subscription" "expenses_alarms_email" {
  topic_arn = aws_sns_topic.expenses_alarms.arn
  protocol  = "email"
  endpoint  = var.cloudwatch_alarm_email
}

# ========================================
# Lambda Error Alarms
# ========================================

# Create Expense Lambda Error Alarm
resource "aws_cloudwatch_metric_alarm" "lambda_create_expense_errors" {
  alarm_name          = "expenses-lambda-createExpense-errors"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "Errors"
  namespace           = "AWS/Lambda"
  period              = "300" # 5 minutes
  statistic           = "Sum"
  threshold           = "5"
  alarm_description   = "This alarm monitors createExpense Lambda function errors"
  treat_missing_data  = "notBreaching"

  dimensions = {
    FunctionName = module.lambda_create_expense.lambda_function_name
  }

  alarm_actions = [aws_sns_topic.expenses_alarms.arn]

  tags = {
    Name = "Serverless Expenses - Lambda Errors"
  }
}

# Get Expenses Lambda Error Alarm
resource "aws_cloudwatch_metric_alarm" "lambda_get_expenses_errors" {
  alarm_name          = "expenses-lambda-getExpenses-errors"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "Errors"
  namespace           = "AWS/Lambda"
  period              = "300"
  statistic           = "Sum"
  threshold           = "5"
  alarm_description   = "This alarm monitors getExpenses Lambda function errors"
  treat_missing_data  = "notBreaching"

  dimensions = {
    FunctionName = module.lambda_get_expenses.lambda_function_name
  }

  alarm_actions = [aws_sns_topic.expenses_alarms.arn]

  tags = {
    Name = "Serverless Expenses - Lambda Errors"
  }
}

# Update Expense Lambda Error Alarm
resource "aws_cloudwatch_metric_alarm" "lambda_update_expense_errors" {
  alarm_name          = "expenses-lambda-updateExpense-errors"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "Errors"
  namespace           = "AWS/Lambda"
  period              = "300"
  statistic           = "Sum"
  threshold           = "5"
  alarm_description   = "This alarm monitors updateExpense Lambda function errors"
  treat_missing_data  = "notBreaching"

  dimensions = {
    FunctionName = module.lambda_update_expense.lambda_function_name
  }

  alarm_actions = [aws_sns_topic.expenses_alarms.arn]

  tags = {
    Name = "Serverless Expenses - Lambda Errors"
  }
}

# Delete Expense Lambda Error Alarm
resource "aws_cloudwatch_metric_alarm" "lambda_delete_expense_errors" {
  alarm_name          = "expenses-lambda-deleteExpense-errors"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "Errors"
  namespace           = "AWS/Lambda"
  period              = "300"
  statistic           = "Sum"
  threshold           = "5"
  alarm_description   = "This alarm monitors deleteExpense Lambda function errors"
  treat_missing_data  = "notBreaching"

  dimensions = {
    FunctionName = module.lambda_delete_expense.lambda_function_name
  }

  alarm_actions = [aws_sns_topic.expenses_alarms.arn]

  tags = {
    Name = "Serverless Expenses - Lambda Errors"
  }
}

# ========================================
# API Gateway Alarms
# ========================================

# API Gateway 5xx Errors Alarm
resource "aws_cloudwatch_metric_alarm" "api_gateway_5xx_errors" {
  alarm_name          = "expenses-api-gateway-5xx-errors"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "5XXError"
  namespace           = "AWS/ApiGateway"
  period              = "300"
  statistic           = "Sum"
  threshold           = "10"
  alarm_description   = "This alarm monitors API Gateway 5xx errors"
  treat_missing_data  = "notBreaching"

  dimensions = {
    ApiName = aws_api_gateway_rest_api.expenses_api.name
  }

  alarm_actions = [aws_sns_topic.expenses_alarms.arn]

  tags = {
    Name = "Serverless Expenses - API Gateway Errors"
  }
}

# ========================================
# DynamoDB Alarms
# ========================================

# DynamoDB Read Throttle Events Alarm
resource "aws_cloudwatch_metric_alarm" "dynamodb_read_throttle" {
  alarm_name          = "expenses-dynamodb-read-throttle"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "ReadThrottleEvents"
  namespace           = "AWS/DynamoDB"
  period              = "300"
  statistic           = "Sum"
  threshold           = "5"
  alarm_description   = "This alarm monitors DynamoDB read throttle events"
  treat_missing_data  = "notBreaching"

  dimensions = {
    TableName = var.aws_dynamodb_table
  }

  alarm_actions = [aws_sns_topic.expenses_alarms.arn]

  tags = {
    Name = "Serverless Expenses - DynamoDB Throttle"
  }
}

# DynamoDB Write Throttle Events Alarm
resource "aws_cloudwatch_metric_alarm" "dynamodb_write_throttle" {
  alarm_name          = "expenses-dynamodb-write-throttle"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "WriteThrottleEvents"
  namespace           = "AWS/DynamoDB"
  period              = "300"
  statistic           = "Sum"
  threshold           = "5"
  alarm_description   = "This alarm monitors DynamoDB write throttle events"
  treat_missing_data  = "notBreaching"

  dimensions = {
    TableName = var.aws_dynamodb_table
  }

  alarm_actions = [aws_sns_topic.expenses_alarms.arn]

  tags = {
    Name = "Serverless Expenses - DynamoDB Throttle"
  }
}

# DynamoDB User Errors Alarm
resource "aws_cloudwatch_metric_alarm" "dynamodb_user_errors" {
  alarm_name          = "expenses-dynamodb-user-errors"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "UserErrors"
  namespace           = "AWS/DynamoDB"
  period              = "300"
  statistic           = "Sum"
  threshold           = "10"
  alarm_description   = "This alarm monitors DynamoDB user errors (validation errors, etc.)"
  treat_missing_data  = "notBreaching"

  dimensions = {
    TableName = var.aws_dynamodb_table
  }

  alarm_actions = [aws_sns_topic.expenses_alarms.arn]

  tags = {
    Name = "Serverless Expenses - DynamoDB Errors"
  }
}

