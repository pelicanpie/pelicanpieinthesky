terraform {
  backend "s3" {}
}

provider "aws" {
  region = "us-east-1"
}

module "recipe_dynamodb_table" {
  source   = "terraform-aws-modules/dynamodb-table/aws"

  name     = "recipe-${var.env}"
  hash_key = "recipe_id"
  range_key = "various"

  attributes = [
    {
      name = "recipe_id"
      type = "N"
    },
    {
      name = "various"
      type = "S"
    }
  ]

  tags = {
    Terraform   = "true"
    Environment = "staging"
    Project = "pelicanpieinthesky"
    Role = "storage"
  }
}

