terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.9"  # This means "any version 5.x.x, but NOT 6.0"
    }
  }
}

# Default Provider (Used if no provider is explicitly stated)
provider "aws" {
  region = "us-east-1"
}

# Aliased Provider (Must be explicitly called in a resource block)
provider "aws" {
  alias  = "west"
  region = "us-west-2"
}



