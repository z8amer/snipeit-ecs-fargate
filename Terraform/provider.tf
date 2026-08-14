terraform {
  required_version = ">= 1.6.0"

  backend "s3" {
    bucket  = "terraform-state-zain" # ◄ Put your actual bucket name here
    key     = "snipe-it/terraform.tfstate"
    region  = "eu-north-1"
    encrypt = true
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = "eu-north-1"
}
