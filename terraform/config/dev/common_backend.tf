terraform {
  required_version = ">= 0.12.2"

  backend "s3" {
    region         = "us-east-1"
    bucket         = "pelicanpieinthesky-dev-terraform-state"
    key            = "backend.tfstate"
    dynamodb_table = "pelicanpieinthesky-dev-terraform-state-lock"
    profile        = "terraform"
    role_arn       = ""
    encrypt        = "true"
  }
}
