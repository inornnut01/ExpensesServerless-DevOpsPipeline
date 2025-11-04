# 🚀 Terraform Infrastructure Setup Guide

This guide will help you set up and deploy the Serverless Expense Tracker infrastructure using Terraform.

## Prerequisites

- AWS Account with appropriate permissions
- Terraform installed (v1.0+)
- GitHub account and repository access
- AWS CLI configured
- Docker installed (v20+) - for local testing and builds
- GitHub repository write access (for Actions CI/CD)

## Infrastructure Components

This Terraform configuration will provision:

- **AWS Amplify** - Frontend hosting and CI/CD
- **API Gateway** - RESTful API endpoints
- **Lambda Functions** - Serverless compute for expense operations
- **DynamoDB** - NoSQL database for storing expenses
- **Cognito User Pool** - User authentication and authorization

## GitHub Token Configuration

To deploy the Amplify frontend, you need to provide a GitHub Personal Access Token. Choose one of the following methods:

### Method 1: Using Environment Variable (Recommended) ⭐

Create a `.env` file in the `backend/infrastructure/` directory:

```bash
# File: backend/infrastructure/.env
TF_VAR_github_token=ghp_your_github_token_here
```

Then load the environment variables and run Terraform:

```bash
cd backend/infrastructure
source .env
terraform init
terraform plan
terraform apply
```

### Method 2: Using terraform.tfvars

Copy the example file and fill in your token:

```bash
cp terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars`:

```hcl
# File: backend/infrastructure/terraform.tfvars
github_token = "ghp_your_github_token_here"
```

Then run:

```bash
terraform init
terraform apply
```

### Method 3: Command Line Variable

```bash
terraform apply -var="github_token=ghp_your_token_here"
```

## 🔐 How to Create a GitHub Personal Access Token

1. Go to https://github.com/settings/tokens
2. Click **"Tokens (classic)"** → **"Generate new token (classic)"**
3. Give it a descriptive name (e.g., "Terraform Amplify Access")
4. Select the required scopes:
   - ✅ **repo** - Full control of private repositories
   - ✅ **admin:repo_hook** - Full control of repository hooks
5. Click **"Generate token"**
6. **Copy and save it immediately** (you won't be able to see it again)

## 🔄 CI/CD Pipeline Setup (Recommended)

This project includes automated deployment via GitHub Actions. The CI/CD pipeline automatically tests, builds, and deploys your application when you push to `main` or `develop` branches.

### GitHub Secrets Configuration

Configure the following secrets in your GitHub repository to enable automated deployment:

**Navigate to:** Repository → **Settings** → **Secrets and variables** → **Actions**

| Secret Name             | Description                                  | Example Value |
| ----------------------- | -------------------------------------------- | ------------- |
| `AWS_ACCESS_KEY_ID`     | AWS IAM user access key for deployment       | `AKIA...`     |
| `AWS_SECRET_ACCESS_KEY` | AWS IAM secret access key                    | `wJalr...`    |
| `AWS_REGION`            | AWS region for deployment                    | `us-east-1`   |
| `AWS_TOKEN_FOR_AMPLIFY` | GitHub Personal Access Token (same as above) | `ghp_...`     |

### Setting Up GitHub Secrets

1. Go to your repository on GitHub
2. Navigate to: **Settings** → **Secrets and variables** → **Actions**
3. Click **"New repository secret"**
4. Add each secret with its corresponding value
5. Repeat for all four secrets

### IAM User Permissions Required

The AWS IAM user (credentials used in GitHub Secrets) needs the following permissions:

- **Lambda**: Create, update, delete functions and layers
- **API Gateway**: Create and manage REST APIs
- **DynamoDB**: Create and manage tables
- **Cognito**: Create and manage user pools
- **IAM**: Create and manage roles and policies
- **CloudWatch**: Create logs, metrics, and alarms
- **SNS**: Create topics and manage subscriptions
- **Amplify**: Create and manage apps

**Recommended for Development**: Attach the `PowerUserAccess` managed policy to the IAM user.

**Production**: Create a custom policy with least-privilege permissions for each service.

### Automated Deployment Workflow

Once secrets are configured, deployment is automatic:

```bash
# Make your changes
git add .
git commit -m "Update infrastructure"

# Push to main or develop branch
git push origin develop

# GitHub Actions will automatically:
# 1. Run tests in Docker container
# 2. Build TypeScript code
# 3. Create Lambda deployment packages
# 4. Deploy infrastructure via Terraform
```

### Monitoring the Pipeline

- **View pipeline status**: Go to your repository → **Actions** tab
- **Check workflow runs**: Click on any workflow run to see detailed logs
- **Review Terraform plan**: Expand the "Terraform Plan" step to review changes
- **Deployment time**: Typically 5-10 minutes for complete deployment

### CI/CD Pipeline Stages

The pipeline executes in three stages:

1. **Test**: Runs Jest unit tests in Docker container
2. **Build**: Compiles TypeScript to JavaScript
3. **Deploy**: Creates Lambda packages and deploys via Terraform

If any stage fails, the pipeline stops and no deployment occurs.

## ⚠️ Security Warnings

**Files protected in .gitignore:**

- ✅ `.env` and `.env.*`
- ✅ `terraform.tfvars` and `*.tfvars`
- ✅ `.terraform/` directory
- ✅ `*.tfstate` and `*.tfstate.*` files
- ✅ `.terraform.lock.hcl`

**NEVER commit:**

- ❌ Files containing tokens or credentials
- ❌ Terraform state files
- ❌ .terraform directory
- ❌ terraform.tfvars with sensitive data

## 📊 CloudWatch Monitoring Configuration

This project includes comprehensive CloudWatch monitoring with automatic alarms and SNS email notifications for production observability.

### Monitoring Components

The infrastructure creates **7 CloudWatch alarms** that monitor:

**Lambda Functions (4 alarms)**

- `createExpense` - Error monitoring
- `getExpenses` - Error monitoring
- `updateExpense` - Error monitoring
- `deleteExpense` - Error monitoring

**API Gateway (1 alarm)**

- 5xx server errors

**DynamoDB (2 alarms)**

- Read throttle events
- Write throttle events

### SNS Email Notifications Setup

To receive alarm notifications via email:

1. **Add your email to `terraform.tfvars`:**

```hcl
# File: infrastructure/terraform.tfvars
cloudwatch_alarm_email = "your-email@example.com"
```

2. **After Terraform deployment, check your email**

   - You'll receive an "AWS Notification - Subscription Confirmation" email
   - Click the **"Confirm subscription"** link in the email
   - You'll see a confirmation page from AWS

3. **Start receiving alerts**
   - Once confirmed, you'll receive email notifications for:
     - Lambda function errors (>5 errors in 5 minutes)
     - API Gateway 5xx errors (>10 in 5 minutes)
     - DynamoDB throttle events (>5 in 5 minutes)
     - DynamoDB user errors (>10 in 5 minutes)

### Alarm Thresholds

Current configurations (customizable in `CloudWatch.tf`):

| Service     | Metric               | Threshold | Period    |
| ----------- | -------------------- | --------- | --------- |
| Lambda      | Errors               | >5        | 5 minutes |
| API Gateway | 5xx Errors           | >10       | 5 minutes |
| DynamoDB    | Read/Write Throttles | >5        | 5 minutes |
| DynamoDB    | User Errors          | >10       | 5 minutes |

### Customizing Alarms

To adjust alarm thresholds, edit `infrastructure/CloudWatch.tf`:

```hcl
resource "aws_cloudwatch_metric_alarm" "lambda_create_expense_errors" {
  threshold = "5"  # Change this value
  period    = "300" # 5 minutes in seconds
  # ... other settings
}
```

### Viewing Metrics in AWS Console

1. Go to **AWS Console** → **CloudWatch**
2. Navigate to:
   - **Alarms** - View alarm status and history
   - **Metrics** - Explore detailed metrics for Lambda, API Gateway, DynamoDB
   - **Logs** - View Lambda function logs

### Testing Alerts

To verify your alarm setup:

1. Trigger an error in your Lambda function (e.g., invalid API request)
2. Repeat until threshold is exceeded (>5 errors)
3. Check your email for alarm notification
4. View alarm state change in CloudWatch Console

## 📋 Manual Deployment Steps

### Option 1: Using Docker (Recommended) 🐳

This approach uses Docker to build and prepare all Lambda deployment packages, ensuring consistency with the CI/CD pipeline.

```bash
# Step 0: Build with Docker
# Navigate to project root (where Dockerfile is located)
cd /path/to/ExpensesSeverless-backend

# Test your code first (runs Jest tests)
docker build --target test -t expense-backend:test .

# Build TypeScript to JavaScript
docker build --target build -t expense-backend:build .

# Create production artifacts (Lambda packages)
docker build --target production -t expense-backend:prod .

# Extract deployment artifacts
docker create --name temp-prod expense-backend:prod
mkdir -p src/dist
docker cp temp-prod:/app/artifacts/expenses ./src/dist/expenses
docker cp temp-prod:/app/artifacts/nodejs ./src/dist/nodejs
docker rm temp-prod

# Verify artifacts structure
echo "=== Lambda Functions ==="
ls -lah ./src/dist/expenses/
echo "=== Lambda Layer ==="
ls -lah ./src/dist/nodejs/

# Step 1: Navigate to infrastructure directory
cd infrastructure

# Step 2: Create .env file with your tokens
echo 'TF_VAR_github_token=ghp_your_token_here' > .env

# OR create terraform.tfvars (choose one method)
cat > terraform.tfvars <<EOF
github_token = "ghp_your_token_here"
cloudwatch_alarm_email = "your-email@example.com"
EOF

# Step 3: Load environment variables (if using .env)
source .env

# Step 4: Initialize Terraform
terraform init

# Step 5: Review the execution plan
terraform plan

# Step 6: Apply the changes
terraform apply

# Step 7: Type 'yes' when prompted to confirm
```

### Option 2: Using npm (Alternative)

If you don't have Docker installed, you can build locally with npm:

```bash
# Step 0: Build with npm
cd src
npm install
npm run build

# Verify build output
ls -lah dist/

# Step 1-7: Continue with Terraform steps above
cd ../infrastructure
# ... follow terraform steps from Option 1
```

## 🔧 Configuration Variables

You can customize the deployment by modifying variables in `terraform.tfvars`:

| Variable                 | Description                       | Default          |
| ------------------------ | --------------------------------- | ---------------- |
| `aws_region`             | AWS region for deployment         | `us-east-1`      |
| `api_gateway_stage`      | API Gateway deployment stage      | `PRODUCTION`     |
| `aws_dynamodb_table`     | DynamoDB table name               | `expenses-table` |
| `github_token`           | GitHub PAT for Amplify            | (required)       |
| `github_repository`      | GitHub repository URL             | (preset)         |
| `cloudwatch_alarm_email` | Email for CloudWatch alarm alerts | (required)       |

## 📤 Outputs

After successful deployment, Terraform will output:

- API Gateway endpoint URL
- Cognito User Pool ID
- Cognito User Pool Client ID
- DynamoDB table name
- Lambda function names
- Amplify app URL

Save these outputs as you'll need them for frontend configuration.

## 🔍 Verify Token Security

```bash
# Check if sensitive files are properly ignored
git check-ignore .env terraform.tfvars

# If it shows the filenames = Safe ✅
# If it shows nothing = Danger! Add them to .gitignore
```

## 🧹 Cleanup (Destroy Infrastructure)

To remove all resources and avoid charges:

```bash
cd backend/infrastructure
terraform destroy
```

Type `yes` when prompted to confirm deletion.

## 🆘 Emergency: Token Leaked

If your GitHub token is accidentally committed or exposed:

1. Go to https://github.com/settings/tokens **immediately**
2. Find the compromised token
3. Click **Delete** or **Revoke**
4. Generate a new token following the steps above
5. Update it in your `.env` or `terraform.tfvars`
6. If committed to git, remove it from history:
   ```bash
   # Contact your team lead or DevOps for help with git history cleanup
   ```

## 🐛 Troubleshooting

### Common Issues

**"Error: No valid credential sources found"**

- Run `aws configure` to set up your AWS credentials

**"Error: Invalid token"**

- Verify your GitHub token has the correct scopes
- Check if the token has expired

**"Error: DynamoDB table already exists"**

- Change the `aws_dynamodb_table` variable to a unique name

**State Lock Issues**

- If Terraform hangs, someone else might be running Terraform
- Use `terraform force-unlock <LOCK_ID>` if you're sure no one else is running it

## 📞 Support

For issues or questions:

- Check the Terraform documentation: https://www.terraform.io/docs
- Review AWS service documentation
- Contact the development team
