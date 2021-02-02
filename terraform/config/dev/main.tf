variable env {
  default = "dev"
}

provider aws {
  region = "us-east-1"
  profile = "terraform"
}

# You cannot create a new backend by simply defining this and then
# immediately proceeding to "terraform apply". The S3 backend must
# be bootstrapped according to the simple yet essential procedure in
# https://github.com/cloudposse/terraform-aws-tfstate-backend#usage
module "terraform_state_backend" {
  source = "cloudposse/tfstate-backend/aws"
  version     = "0.30.0"
  namespace  = "pelicanpieinthesky"
  stage      = var.env
  name       = "terraform"
  attributes = ["state"]

  terraform_backend_config_file_path = "."
  terraform_backend_config_file_name = "common_backend.tf"
  terraform_backend_config_template_file = "../../templates/backend.tf.tpl"
  terraform_state_file               = "backend.tfstate"
  force_destroy                      = false

  profile = "terraform"
  billing_mode = "PAY_PER_REQUEST"
}
