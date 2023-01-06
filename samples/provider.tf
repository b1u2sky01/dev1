provider "aws" {
  region = var.region

  default_tags {
    tags = {
      Environment      = var.env
      Project          = var.pjt
      COST_CENTER      = var.pjt
      TerraformManaged = true
    }
  }
}

provider "aws" {
  alias      = "ucmp_owner"
  region     = var.region
  access_key = var.ucmp-access-key
  secret_key = var.ucmp-access-secret

  default_tags {
    tags = {
      Environment      = var.env
      Project          = var.pjt
      COST_CENTER      = var.pjt
      TerraformManaged = true
    }
  }
}

terraform {
  required_version = ">= 1.1.7"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "> 4.0.0, <= 4.9.0"
    }
  }
}
