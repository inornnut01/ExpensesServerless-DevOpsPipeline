terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }

  //Terraform state backend
  backend "s3" {
  bucket = "terraformstate32455"
  key    = "expense-tracker/terraform.tfstate"
  region = "us-east-1"
  }
}

provider "aws" {
  region = var.aws_region
}

