# Aviatrix Controller and CoPilot Build Terraform

## Prerequisites

- AWS Terraform provider authentication should be configured. See https://registry.terraform.io/providers/hashicorp/aws/latest/docs#authentication
- Increase VPC and Elastic IP quotas in us-east-1 (or region where controller is to be deployed)
- Subscribe to the following AMIs:
  - Aviatrix Controller: 2208-Universal and BYOL
  - Aviatrix CoPilot: https://aws.amazon.com/marketplace/pp?sku=bjl4xsl3kdlaukmyctcb7np9s
 

## Build Controller and CoPilot

- Update values in `terraform.tfvars`.
- If the Aviatrix IAM roles already exist in the AWS account to be used (possibly because an Aviatrix Controller was previously launched), IAM role creation can be disabled by setting `create_iam_roles` to false.
- If you don't want to deploy an Application Load Balancer, set `create_alb` to false.
- If restricting the IPs that can connect to the Aviatrix Controller in `terraform.tfvars`, also include the VPC CIDR `192.168.2.0/24` so that the Lamba function is able to connect and intialize the Controller.
  ```
  incoming_ssl_cidr   = ["x.x.x.x/32", "192.168.2.0/24"]
  ```
- A successful deployment and intialization will have a message similar to the following in the Terraform output:
  ```
  result = "{\"status\": true, \"message\": \"Successfully initialized an Aviatrix Controller: x.x.x.x\"}"
  ```
- If the deployment fails for any reason (e.g. not subscribed to the required AMIs), fix the problems first. It is then recommended to `terraform destroy` everything and run `terraform apply` again.


## terraform destroy

- When running terraform destroy, the created VPC will fail to delete. The Aviatrix Controller applies security groups to the VPC which Terraform is not aware of. The workaround is to delete the VPC from the AWS Console and then rerun `terraform destroy`.

  ```
  │ Error: error deleting EC2 VPC (vpc-0d119642abc1484fa): DependencyViolation: The vpc 'vpc-0d119642abc1484fa' has dependencies and cannot be deleted.
  │ 	status code: 400, request id: 952e8a97-2f8d-4ffa-833c-f34a47c01184
  ```
