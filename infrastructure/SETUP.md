# 🚀 Terraform Infrastructure Setup Guide

This guide will help you set up and deploy the Serverless Expense Tracker infrastructure using Terraform.

## Prerequisites

- AWS Account with appropriate permissions
- Terraform installed (v1.0+)
- GitHub account and repository access
- AWS CLI configured

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

## 📋 Deployment Steps

```bash
# 1. Navigate to the infrastructure directory
cd backend/infrastructure

# 2. Create .env file and add your token
echo 'TF_VAR_github_token=ghp_your_token_here' > .env

# 3. Load environment variables
source .env

# 4. Initialize Terraform (downloads providers and modules)
terraform init

# 5. Review the execution plan
terraform plan

# 6. Apply the changes
terraform apply

# 7. Type 'yes' when prompted to confirm
```

## 🔧 Configuration Variables

You can customize the deployment by modifying variables in `terraform.tfvars`:

| Variable             | Description                  | Default          |
| -------------------- | ---------------------------- | ---------------- |
| `aws_region`         | AWS region for deployment    | `us-east-1`      |
| `api_gateway_stage`  | API Gateway deployment stage | `PRODUCTION`     |
| `aws_dynamodb_table` | DynamoDB table name          | `expenses-table` |
| `github_token`       | GitHub PAT for Amplify       | (required)       |
| `github_repository`  | GitHub repository URL        | (preset)         |

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
