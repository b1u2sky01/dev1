terraform {
  required_version = ">= 1.1.7"

  required_providers {
    aws = {
      source                = "hashicorp/aws"
      version               = "> 4.0.0, <= 4.9.0"
      configuration_aliases = [aws.ucmp_owner]
    }
  }
}
