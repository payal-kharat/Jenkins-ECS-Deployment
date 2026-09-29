# app-1 Terraform infrastructure

This version creates the networking instead of using the AWS default VPC.

## Network

- VPC: 10.0.0.0/16
- Public subnets: 10.0.1.0/24, 10.0.2.0/24
- Private subnets: 10.0.11.0/24, 10.0.12.0/24
- Internet Gateway
- One NAT Gateway (cost-saving design)
- Public route table for ALBs/NAT
- Private route table for ECS tasks

## ECS placement

- ALBs are in public subnets.
- Frontend, backend and DB ECS tasks are in private subnets.
- ECS tasks do not receive public IPs.
- NAT Gateway provides outbound internet access for ECS image pulls and AWS API access.

## Security groups

- ALB: internet -> TCP 80
- ECS: ALB -> TCP 80/8000 and ECS -> backend TCP 8000
- DB: ECS -> TCP 3306 only

## Important database requirement

`db_root_password` is required. Do not commit a real password to Git.
For Jenkins, store the password as a Jenkins secret and expose it as `TF_VAR_db_root_password`.

Example for local testing:

```bash
export TF_VAR_db_root_password='change-this-for-testing'
terraform init
terraform validate
terraform plan
terraform apply
```

## Existing infrastructure warning

The previous configuration used the AWS default VPC. This configuration creates a new VPC.
If the old Terraform state is used, Terraform will replace resources that were attached to the old VPC.
Review `terraform plan` carefully before applying.

Do not commit `terraform.tfstate` or `terraform.tfstate.backup` to Git.
For Jenkins, configure an S3 remote backend before using this as a shared CI/CD pipeline.
