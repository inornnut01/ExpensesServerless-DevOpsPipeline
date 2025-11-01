# Amplify App
resource "aws_amplify_app" "expenses_frontend" {
  name        = "expenses-tracker-frontend"
  repository  = var.github_repository
  
  # OAuth token for GitHub
  access_token = var.github_token

  # Environment variables 
  environment_variables = {
    VITE_API_URL              = aws_api_gateway_stage.production.invoke_url
    VITE_USER_POOL_ID         = aws_cognito_user_pool.expenses_user_pool.id
    VITE_USER_POOL_CLIENT_ID  = aws_cognito_user_pool_client.expenses_client.id
    VITE_AWS_REGION           = var.aws_region
  }

  # Build settings
  build_spec = <<-EOT
    version: 1
    frontend:
      phases:
        preBuild:
          commands:
            - npm ci
        build:
          commands:
            - npm run build
      artifacts:
        baseDirectory: dist
        files:
          - '**/*'
      cache:
        paths:
          - node_modules/**/*
  EOT

  # Custom rules for SPA routing
  custom_rule {
    source = "/<*>"
    status = "404"
    target = "/index.html"
  }

  tags = {
    Name = "Serverless Expenses Frontend"
  }
}

# Amplify Branch (main/production)
resource "aws_amplify_branch" "main" {
  app_id      = aws_amplify_app.expenses_frontend.id
  branch_name = "main"

  enable_auto_build = true

  framework = "React" 
  stage     = "PRODUCTION"
}



