## IAC frameworks considered for this project
- CDK
- Serverless
- Terraform

Terraform was chosen to get a deeper understanding of the framework and to explore how I can use it better at work.

There are a couple ways to structure and manage Terraform state. 
## Terraform approaches considered
- Standard setup with all `.tf` files in `/terraform`
- Terraform cloud with workspaces
- Terragrunt
- Terraform cli with aws backend

For this project I want two environments to learn about terraform workspaces more deeply. 

Terragrunt could be an interesting route to explore in the future as it seems to be widely used and solves the same problems as workspaces but with a few more features.

Terraform cloud requires AWS secret keys to be configured and I want to use github actions for the ci/cd so I've opted for the Terraform cli with aws backend for now.

## ../scripts/tf.sh
To manage the terraform workspaces and keep the backends separate from the terraform code I have captured all the terraform cli arguments required to work with the below folder structure.

## Folder structue
### /config
This folder contains all the backend config and tfvars for each of the environments and stacks for this project.

Terraform backend created with: https://github.com/cloudposse/terraform-aws-tfstate-backend

- /config
    - /dev
        - common_backend.tf
        - common.tfvars
        - main.tf 
            - This is where the cloudposse module was defined to create the tf backend resources
        - recipe_backend.tfvars

### /stacks
This folder contains the stacks where related resources are defined. Variables to substitute in environment specific naming are defined in the `config` folder.

Modules are used where possible.

- /stacks
    - /recipe_backend
        - main.tf
        - variables.tf

## AWS setup
My AWS account is configured with an IAM user with Viewer/Read-Only access.
There are two roles configured that only my IAM user can assume
- Admin
   - Requires an MFA `token` to be provided
   - Admin privileges
- Terraform
    - Requires an `external_id` to be provided
    - Specific permissions provided based on only what is needed

Locally I have set up two profiles in my `~/.aws/credentials` file for the `admin` and `terraform` roles according to: https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-role.html

The `admin` profile is set up with `role_arn`, `source_profile` (default), and `mfa_serial` (arn retrieved from my IAM user).

The `terraform` profile is set up with `role_arn`, `source_profile` (default), and `external_id` and the profile 'terraform` is specified in the terraform provider block.

With this setup, for any admin aws commands I run locally I just need to add `--profile admin` to the end and I will be prompted to enter an MFA code.

As I don't expect to do this often I think this is acceptable to protect admin access to my AWS account.

## Terraform backend config
All resources are to be created in the us-east-1 region which is the cheapest region to run resources according to https://www.concurrencylabs.com/blog/choose-your-aws-region-wisely/

Partial backend configuration is used and managed with the tf.sh wrapper.
Further info: https://www.terraform.io/docs/language/settings/backends/configuration.html#partial-configuration

## Troubleshooting notes
I am running terraform in an Ubuntu distribution using the Windows Subsystem for Linux (WSL). I ran into TLS issues running `terraform plan` using `WSL2` which appears to be related to this open issue: https://github.com/microsoft/WSL/issues/4698.
For now I have switched back to `WSL1` and I'm no longer having TLS issues.
