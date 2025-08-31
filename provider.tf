terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      # version = "~> 5.0"  # ~ means accept minor version 5.xx.
      version = ">= 5.90"
    }
  }

  required_version = ">= 1.2.0"
}

# provider "aws" {
#   region = "ap-southeast-1"
#   profile = "ddkarpenter"
# }