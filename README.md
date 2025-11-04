# Serverless Expense Tracker - DevOps Enhanced 🚀

![TypeScript](https://img.shields.io/badge/TypeScript-007ACC?style=flat&logo=typescript&logoColor=white)
![Docker](https://img.shields.io/badge/Docker-2496ED?style=flat&logo=docker&logoColor=white)
![AWS](https://img.shields.io/badge/AWS-232F3E?style=flat&logo=amazon-aws&logoColor=white)
![Terraform](https://img.shields.io/badge/Terraform-7B42BC?style=flat&logo=terraform&logoColor=white)
![GitHub Actions](https://img.shields.io/badge/GitHub_Actions-2088FF?style=flat&logo=github-actions&logoColor=white)

> A production-ready serverless expense tracking application with enterprise-grade DevOps practices including Docker containerization, automated CI/CD pipeline, and comprehensive CloudWatch monitoring.

**This project extends and enhances the original serverless architecture with DevOps automation and observability.**

**Original Repository:** [ExpensesSeverless-backend](https://github.com/inornnut01/ExpensesSeverless-backend.git)

---

## 🎯 DevOps Enhancements Overview

This project demonstrates advanced DevOps and Cloud Engineering capabilities by extending a serverless architecture with:

✅ **Multi-Stage Docker Builds** - Optimized containerization for testing, building, and deployment  
✅ **Automated CI/CD Pipeline** - GitHub Actions workflow with automated testing and AWS deployment  
✅ **Infrastructure as Code** - Complete AWS infrastructure provisioned via Terraform  
✅ **Production Monitoring** - CloudWatch alarms with SNS email notifications  
✅ **Automated Testing** - Containerized unit tests in CI/CD pipeline  
✅ **Artifact Management** - Automated Lambda deployment package generation  
✅ **GitOps Workflow** - Branch-based deployment strategy (main, develop)

---

## 🏗️ Architecture

### Original Serverless Architecture

- **AWS Lambda** - Serverless compute for API endpoints (Node.js 22.x)
- **Amazon API Gateway** - RESTful API management with CORS support
- **Amazon DynamoDB** - NoSQL database for expense data storage
- **Amazon Cognito** - User authentication and authorization
- **AWS Amplify** - Frontend hosting and continuous deployment

### DevOps Pipeline Architecture

```
Developer → GitHub Push
    ↓
GitHub Actions CI/CD
    ├── Stage 1: Test (Docker)
    │   └── Run Jest unit tests
    ├── Stage 2: Build (Docker)
    │   └── Compile TypeScript → JavaScript
    └── Stage 3: Deploy
        ├── Create Lambda deployment packages
        ├── Terraform Plan
        └── Terraform Apply → AWS
            ├── Lambda Functions (4)
            ├── API Gateway
            ├── DynamoDB
            ├── Cognito
            ├── CloudWatch Alarms (7)
            └── SNS Notifications
```

---

## 🐳 Docker Implementation

### Multi-Stage Dockerfile

The project uses an optimized multi-stage Docker build for efficient development and deployment:

**Stage 1: Base** - Dependency Installation

- Node.js 20 Alpine image
- Installs all npm dependencies

**Stage 2: Test** - Automated Testing

- Runs Jest unit tests with coverage
- Validates code before build
- Used in CI/CD pipeline

**Stage 3: Build** - TypeScript Compilation

- Compiles TypeScript to JavaScript (ES Modules)
- Produces clean build artifacts
- Verifies build output

**Stage 4: Production** - Lambda Deployment Artifacts

- Production dependencies only (no devDependencies)
- Creates Lambda function packages (.mjs files)
- Generates Lambda Layer structure (shared code + node_modules)
- Optimized for AWS Lambda deployment

### Benefits

- **Consistent Environments**: Same build process locally and in CI/CD
- **Automated Testing**: Tests run in isolated container
- **Optimized Size**: Only production dependencies in final artifacts
- **Fast Builds**: Layer caching speeds up subsequent builds

### Local Docker Usage

```bash
# Run tests
docker build --target test -t expense-backend:test .

# Build TypeScript
docker build --target build -t expense-backend:build .

# Create production artifacts
docker build --target production -t expense-backend:prod .

# Extract artifacts for manual deployment
docker create --name temp expense-backend:prod
docker cp temp:/app/artifacts ./artifacts
docker rm temp
```

---

## 🚀 CI/CD Pipeline

### GitHub Actions Workflow

The automated pipeline consists of three main jobs:

#### 1. **Test Job** 🧪

- Triggers on push to `main`, `develop`, or `CI/CD` branches
- Builds Docker test stage
- Runs Jest unit tests in isolated container
- Fails pipeline if tests don't pass

#### 2. **Build Job** 🔨

- Depends on successful test completion
- Builds TypeScript code using Docker
- Extracts compiled artifacts
- Uploads build artifacts for deployment stage

#### 3. **Deploy Job** 🚢

- Downloads build artifacts
- Configures AWS credentials
- Creates production Lambda packages via Docker
- Extracts deployment artifacts
- Runs Terraform init, validate, fmt
- Creates Terraform plan
- Deploys infrastructure to AWS with auto-approve

### Pipeline Triggers

- **Automatic**: Push to `main` or `develop` branches
- **Pull Requests**: Runs tests on PRs to `main`

### Artifact Flow

```
Source Code → Test Container → Build Container → Production Container
    ↓              ↓               ↓                    ↓
  Tests        Validation      .js files         Lambda Packages
                                   ↓                    ↓
                            Upload Artifacts     Extract & Deploy
                                                        ↓
                                                  Terraform Apply
```

### Required GitHub Secrets

- `AWS_ACCESS_KEY_ID` - AWS IAM credentials
- `AWS_SECRET_ACCESS_KEY` - AWS IAM credentials
- `AWS_REGION` - Target AWS region (e.g., us-east-1)
- `AWS_TOKEN_FOR_AMPLIFY` - GitHub PAT for Amplify deployment

**See [infrastructure/SETUP.md](infrastructure/SETUP.md) for detailed configuration.**

---

## 📊 Monitoring & Alerting

### CloudWatch Integration

Comprehensive production monitoring with 7 CloudWatch alarms:

#### Lambda Function Monitoring (4 alarms)

- **createExpense** - Monitors Lambda errors
- **getExpenses** - Tracks function failures
- **updateExpense** - Detects execution errors
- **deleteExpense** - Monitors error rates

**Threshold**: >5 errors in 5 minutes

#### API Gateway Monitoring (1 alarm)

- **5xx Errors** - Server-side error tracking
- **Threshold**: >10 errors in 5 minutes

#### DynamoDB Monitoring (2 alarms)

- **Read Throttle Events** - Capacity monitoring
- **Write Throttle Events** - Write capacity tracking
- **User Errors** - Validation and client errors

**Threshold**: >5 throttle events in 5 minutes

### SNS Email Notifications

- Configured via Terraform variables
- Email subscription requires confirmation
- Real-time alerts for all alarm triggers
- Customizable alarm thresholds

### Metrics Dashboard Access

- Lambda: Invocations, Duration, Errors, Throttles
- API Gateway: Request Count, Latency, 4xx/5xx Errors
- DynamoDB: Read/Write Capacity Units, Throttles, Errors

---

## ⚙️ Technology Stack

### AWS Services

- **Compute**: AWS Lambda (Node.js 22.x)
- **API**: Amazon API Gateway (REST)
- **Database**: Amazon DynamoDB
- **Auth**: Amazon Cognito User Pools
- **Frontend**: AWS Amplify
- **Monitoring**: Amazon CloudWatch + SNS
- **Security**: AWS IAM

### DevOps Tools

- **Containerization**: Docker (Multi-stage builds)
- **CI/CD**: GitHub Actions
- **IaC**: Terraform (AWS Provider)
- **Version Control**: Git + GitHub

### Backend Technologies

- **Language**: TypeScript 5.9+
- **Runtime**: Node.js 20 (ES Modules)
- **Testing**: Jest with coverage
- **AWS SDK**: v3 (modular)

---

## 📁 Project Structure

```
.
├── .github/
│   └── workflows/
│       └── ci-cd.yml              # GitHub Actions CI/CD pipeline ⭐
├── Dockerfile                      # Multi-stage Docker build ⭐
├── infrastructure/
│   ├── Amplify.tf                 # Amplify hosting configuration
│   ├── API_Gateway.tf             # API Gateway setup
│   ├── CloudWatch.tf              # Monitoring & alarms ⭐
│   ├── CognitoUserPool.tf         # Authentication
│   ├── Dynamodb.tf                # Database configuration
│   ├── Lambda.tf                  # Lambda functions
│   ├── provider.tf                # Terraform AWS provider
│   ├── variable.tf                # Terraform variables
│   ├── outputs.tf                 # Stack outputs
│   ├── SETUP.md                   # Detailed setup guide
│   └── terraform.tfvars.example   # Configuration template
├── src/
│   ├── expenses/                  # Lambda function handlers
│   │   ├── createExpense.ts
│   │   ├── getExpenses.ts
│   │   ├── updateExpense.ts
│   │   └── deleteExpense.ts
│   ├── services/                  # Business logic layer
│   │   └── expenses.service.ts
│   ├── utils/                     # Shared utilities
│   │   ├── authHelper.ts          # JWT validation
│   │   ├── dynamoClient.ts        # DynamoDB client
│   │   └── response.ts            # API responses
│   ├── test/                      # Comprehensive test suite
│   │   └── *.test.ts
│   ├── dist/                      # Compiled output (gitignored)
│   │   ├── expenses/              # Lambda functions (.mjs)
│   │   └── nodejs/                # Lambda Layer
│   ├── package.json
│   ├── tsconfig.json
│   └── jest.config.js
└── README.md

⭐ = DevOps enhancements
```

---

## 🚦 Getting Started

### Prerequisites

- **Docker** (v20+)
- **AWS Account** with appropriate permissions
- **AWS CLI** configured (`aws configure`)
- **Terraform** (v1.0+)
- **GitHub Account** with repository access
- **Node.js** (v18+) - optional for local development

### Quick Start - CI/CD Deployment (Recommended)

1. **Clone the repository**

```bash
git clone https://github.com/inornnut01/ExpensesSeverless-backend.git
cd ExpensesSeverless-backend
```

2. **Configure GitHub Secrets**

   - Go to: Repository → Settings → Secrets and variables → Actions
   - Add required secrets (see [SETUP.md](infrastructure/SETUP.md))

3. **Push to deploy**

```bash
git checkout develop
git push origin develop
# Pipeline automatically runs: Test → Build → Deploy
```

4. **Monitor deployment**
   - Check GitHub Actions tab for pipeline status
   - Review Terraform plan output
   - Verify AWS resources after deployment

### Quick Start - Local Testing

```bash
# Test your code
docker build --target test -t expense-backend:test .

# Build TypeScript
docker build --target build -t expense-backend:build .

# Create production artifacts
docker build --target production -t expense-backend:prod .
```

### Manual Deployment

For step-by-step manual deployment instructions, see **[infrastructure/SETUP.md](infrastructure/SETUP.md)**

---

## 🧪 Testing Strategy

### Automated Testing in CI/CD

- **Containerized Tests**: Run in isolated Docker environment
- **Pipeline Integration**: Tests execute before build/deploy
- **Fail-Fast**: Pipeline stops if tests fail
- **Coverage Reports**: Jest generates coverage metrics

### Test Coverage

- ✅ Lambda function handlers (createExpense, getExpenses, updateExpense, deleteExpense)
- ✅ Business logic (ExpensesService)
- ✅ Utilities (authHelper, response formatter, DynamoDB client)

### Running Tests

```bash
# Using Docker (same as CI/CD)
docker build --target test -t expense-backend:test .

# Local testing (requires Node.js)
cd src
npm install
npm test                 # Run all tests
npm run test:watch       # Watch mode
npm run test:coverage    # With coverage report
```

---

## 🔐 Security & Best Practices

### Docker Security

- ✅ **Multi-stage builds** reduce final image size and attack surface
- ✅ **Alpine Linux** base image for minimal footprint
- ✅ **No secrets in images** - all credentials via environment/secrets
- ✅ **Production stage** contains only runtime dependencies

### CI/CD Security

- ✅ **GitHub Secrets** for sensitive credentials
- ✅ **AWS IAM roles** with least-privilege access
- ✅ **No hardcoded secrets** in code or Terraform
- ✅ **Automated testing** prevents broken deployments

### Infrastructure Security

- ✅ **Cognito authentication** for all API endpoints
- ✅ **JWT token validation** on every request
- ✅ **IAM policies** with minimal required permissions
- ✅ **DynamoDB encryption** at rest
- ✅ **CORS configuration** for controlled access

### Best Practices Implemented

- ✅ Infrastructure as Code (version controlled)
- ✅ Automated testing in pipeline
- ✅ GitOps workflow with branch protection
- ✅ Monitoring and alerting
- ✅ Artifact versioning and management
- ✅ Terraform state management

---

## 📈 DevOps Achievements & Skills Demonstrated

This project showcases production-ready DevOps engineering capabilities:

### 1. **Containerization & Optimization**

- Multi-stage Docker builds for efficiency
- Container optimization for Lambda deployment
- Automated artifact generation

### 2. **CI/CD Pipeline Engineering**

- GitHub Actions workflow design
- Automated testing, building, and deployment
- Artifact management between pipeline stages
- Integration with Terraform for IaC deployment

### 3. **Infrastructure as Code**

- Complete AWS infrastructure via Terraform
- Modular, reusable Terraform configurations
- State management and versioning
- Variables and outputs for flexibility

### 4. **Observability & Monitoring**

- Comprehensive CloudWatch alarm configuration
- Multi-service monitoring (Lambda, API Gateway, DynamoDB)
- SNS integration for alerting
- Production-ready alarm thresholds

### 5. **Testing & Quality Assurance**

- Automated unit testing in CI/CD
- Containerized test execution
- Pre-deployment validation
- Coverage reporting with Jest

### 6. **Cloud Architecture**

- AWS serverless architecture design
- Service integration (Lambda, API Gateway, DynamoDB, Cognito)
- Security best practices (IAM, encryption)
- Cost-optimized serverless design

### 7. **Automation & GitOps**

- Branch-based deployment workflows
- Automated infrastructure provisioning
- Zero-touch deployment process
- Version-controlled infrastructure

---

## 🔧 Configuration & Deployment

### Environment Configuration

1. **Terraform Variables** (`infrastructure/terraform.tfvars`)

   - AWS region
   - DynamoDB table name
   - API Gateway stage
   - GitHub token for Amplify
   - CloudWatch alarm email

2. **GitHub Secrets** (for CI/CD)

   - AWS credentials
   - GitHub token

3. **CloudWatch Alarms**
   - Configurable thresholds
   - Email notification endpoint
   - SNS topic subscription

### Deployment Options

**Option 1: Automated (CI/CD)**

- Push to `main` or `develop` branch
- GitHub Actions handles everything
- ~5-10 minutes deployment time

**Option 2: Manual (Terraform)**

- Build artifacts with Docker
- Run Terraform commands
- Manual approval of changes

**Detailed instructions:** [infrastructure/SETUP.md](infrastructure/SETUP.md)

---

## 📊 Monitoring Dashboard & Metrics

### Available Metrics

**Lambda Functions**

- Invocation count
- Error count and rate
- Duration (min, max, avg)
- Throttles
- Concurrent executions

**API Gateway**

- Request count
- Integration latency
- 4xx errors (client)
- 5xx errors (server)
- Cache hit/miss ratio

**DynamoDB**

- Read/Write capacity units consumed
- Throttled requests
- System errors
- User errors
- Item count and table size

### Accessing Metrics

1. AWS Console → CloudWatch → Dashboards
2. View alarms: CloudWatch → Alarms
3. Check SNS: Email notifications for alerts

---

## 🎓 Learning Outcomes

This project demonstrates hands-on experience with:

✅ **Designing CI/CD pipelines** for serverless applications  
✅ **Docker optimization** for AWS Lambda deployment  
✅ **CloudWatch observability** implementation  
✅ **Terraform infrastructure** management at scale  
✅ **GitHub Actions** workflow development  
✅ **AWS serverless** architecture patterns  
✅ **Automated testing** integration in pipelines  
✅ **Production monitoring** and alerting strategies  
✅ **Security best practices** for cloud infrastructure  
✅ **GitOps workflows** and deployment automation

---

## 🆘 Troubleshooting

### Common Issues

**Docker build fails**

```bash
# Clean Docker cache
docker system prune -a
# Rebuild from scratch
docker build --no-cache --target test -t expense-backend:test .
```

**CI/CD pipeline fails at deploy**

- Verify GitHub Secrets are configured correctly
- Check AWS credentials have sufficient permissions
- Review Terraform error messages in Actions logs

**CloudWatch alarms not sending emails**

- Confirm SNS subscription in email
- Check spam folder
- Verify email variable in terraform.tfvars

**Terraform state lock issues**

- Check if another deployment is running
- Wait for other operations to complete
- Contact team if locked longer than expected

For detailed troubleshooting, see [infrastructure/SETUP.md](infrastructure/SETUP.md)

---

## 🔗 Related Resources

- **Original Repository**: [ExpensesSeverless-backend](https://github.com/inornnut01/ExpensesSeverless-backend.git)
- **Setup Guide**: [infrastructure/SETUP.md](infrastructure/SETUP.md)
- **AWS Lambda Best Practices**: https://docs.aws.amazon.com/lambda/latest/dg/best-practices.html
- **Terraform AWS Provider**: https://registry.terraform.io/providers/hashicorp/aws/
- **GitHub Actions Documentation**: https://docs.github.com/en/actions
- **Docker Multi-stage Builds**: https://docs.docker.com/build/building/multi-stage/

---

## 📝 API Endpoints

All endpoints require Cognito JWT authentication.

| Method | Endpoint                       | Description                    |
| ------ | ------------------------------ | ------------------------------ |
| POST   | `/expenses/create`             | Create new expense/income      |
| GET    | `/expenses/get`                | Retrieve expenses with filters |
| PUT    | `/expenses/update/{expenseId}` | Update existing expense        |
| DELETE | `/expenses/delete/{expenseId}` | Delete expense record          |

---

## 🚧 Future Enhancements

Potential production improvements:

- [ ] AWS X-Ray distributed tracing
- [ ] API rate limiting with AWS WAF
- [ ] CloudWatch Insights queries and dashboards
- [ ] Automated backup strategy for DynamoDB
- [ ] Blue/green deployment strategy
- [ ] Integration tests in CI/CD
- [ ] Slack/Teams integration for alerts
- [ ] Cost optimization with Lambda reserved concurrency
- [ ] Multi-region deployment support

---

## 📄 License

This project is created for educational and portfolio purposes.

---

## 👨‍💻 About This Project

This DevOps-enhanced project extends the original serverless expense tracker with enterprise-grade automation, monitoring, and deployment practices. It was developed to demonstrate:

- **Cloud Engineering** capabilities on AWS
- **DevOps practices** including CI/CD and IaC
- **Production-ready** monitoring and observability
- **Modern development** workflows with Docker and GitHub Actions

**Perfect for showcasing skills in Cloud Engineer and DevOps Engineer roles.**

---

**Built with ☁️ AWS • 🐳 Docker • ⚙️ Terraform • 🚀 GitHub Actions**
