# Terraform EKS build code
## Prerequisites

* AWS user with Programmatic access and AdministratorAccess
* Terraform to be installed "https://learn.hashicorp.com/tutorials/terraform/install-cli"
* Kubectl to be installed "https://kubernetes.io/docs/tasks/tools/install-kubectl/"

## variables to adjust
You need to fill "terraform.tfvars" with the values for:
- AWS_ACCESS_KEY=""
- AWS_SECRET_KEY=""
- region="eu-west-1"
- app_name=""
- cluster-name=""

## Applying/Updating Terraform code

`terraform init` </br>
`terraform apply`

