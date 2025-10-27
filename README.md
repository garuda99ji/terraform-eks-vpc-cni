# Terraform-EKS-VPCCNI
A sample repo to spin up EKS cluster with VPC CNI
Terraform EKS Cluster Deployment
These terraform scripts will provision an EKS (Elastic Kubernetes Service) cluster with a managed node group. The size of node group can ne changed in the file "eks-cluster-ng.tf". Search for line -  scaling_config {.

Prerequisites
1. Terraform Installed: - https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli
2. AWS CLI: https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html
3. AWS Account and Credentials: You should have an AWS account and have your credentials configured for Terraform to use. This is typically done via environment variables (AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY)
4.  VPC must be created along with subnets ( public, private), route tables, internet gateway.

For public subnets, add a tag

For private subnets, add a tag

## How to Use

1. Create a terraform.tfvars file:
Create a file named terraform.tfvars in the same directory as the .tf files and populate it with your specific values. This file will be automatically loaded by Terraform.

Example terraform.tfvars

aws_region   = "us-east-1"
cluster_name = "production-eks-cluster"
vpc_id       = "vpc-xxxxxxxxxxxxxxxxx"
subnet_ids   = ["subnet-xxxxxxxxxxxxxxxxx", "subnet-yyyyyyyyyyyyyyyyy", "subnet-zzzzzzzzzzzzzzzzz"]

2. Initialize Terraform:
Open your terminal in this directory and run the following command to initialize the Terraform workspace and download the necessary providers.

```bash
terraform init
```

3.Plan the Deployment:
Run the plan command to see what resources Terraform will create. This is a good way to verify that everything is configured correctly before you apply the changes.

```bash
terraform plan
```

4. Apply the Configuration:
If the plan looks correct, apply the configuration to create the EKS cluster and associated resources.

```bash
terraform apply
```

Terraform will ask for confirmation. Type yes and press Enter. Wait for 10-15 minutes, the EKS cluster will be created along with defined node group.

5. Configure kubectl:
After the terraform apply command completes, it will output the necessary information to configure kubectl to connect to your new cluster. You can use the AWS CLI to update your kubeconfig file:

```bash
aws eks --region $(terraform output -raw aws_region) update-kubeconfig --name $(terraform output -raw cluster_name)
```

6. Verify Cluster Access:
Check if you can connect to your cluster and see the nodes.

```bash
kubectl get nodes
```

7. Destroy the Resources:
When you no longer need the EKS cluster, you can destroy all the created resources using Terraform to avoid incurring further costs.

```bash
terraform destroy
```

Again, Terraform will ask for confirmation. Type yes and press Enter.


## Potential errors

1. VPC is not properly configured - check internet gateway, security group outbound rules and route table.
2. Define only public subnet - otherwise node could be launched in private subnet and would require a NAT gateway to talk to the internet.
