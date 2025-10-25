Terraform EKS Cluster Deployment
This set of Terraform scripts will provision a fully functional Amazon EKS (Elastic Kubernetes Service) cluster with a managed node group.

Prerequisites
Terraform Installed: You need to have Terraform installed on your local machine.

AWS Account and Credentials: You must have an AWS account and have your credentials configured for Terraform to use. This is typically done via environment variables (AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY) or an AWS credentials file.

Existing VPC and Subnets: You must have a pre-existing VPC with public and/or private subnets that the EKS cluster can use. The subnets must be tagged appropriately for EKS.

For public subnets, add the tag: kubernetes.io/role/elb = 1

For private subnets, add the tag: kubernetes.io/role/internal-elb = 1

How to Use

1. Create a terraform.tfvars file:
Create a file named terraform.tfvars in the same directory as the .tf files and populate it with your specific values. This file will be automatically loaded by Terraform.

# Example terraform.tfvars

aws_region   = "us-east-1"
cluster_name = "production-eks-cluster"
vpc_id       = "vpc-xxxxxxxxxxxxxxxxx"
subnet_ids   = ["subnet-xxxxxxxxxxxxxxxxx", "subnet-yyyyyyyyyyyyyyyyy", "subnet-zzzzzzzzzzzzzzzzz"]

2. Initialize Terraform:
Open your terminal in this directory and run the following command to initialize the Terraform workspace and download the necessary providers.

terraform init

3.Plan the Deployment:
Run the plan command to see what resources Terraform will create. This is a good way to verify that everything is configured correctly before you apply the changes.

terraform plan

4. Apply the Configuration:
If the plan looks correct, apply the configuration to create the EKS cluster and associated resources.

terraform apply

Terraform will ask for confirmation. Type yes and press Enter. The process of creating an EKS cluster can take 10-15 minutes.

5. Configure kubectl:
After the terraform apply command completes, it will output the necessary information to configure kubectl to connect to your new cluster. You can use the AWS CLI to update your kubeconfig file:

aws eks --region $(terraform output -raw aws_region) update-kubeconfig --name $(terraform output -raw cluster_name)

6. Verify Cluster Access:
Check if you can connect to your cluster and see the nodes.

kubectl get nodes

7. Destroy the Resources:
When you no longer need the EKS cluster, you can destroy all the created resources using Terraform to avoid incurring further costs.

terraform destroy

Again, Terraform will ask for confirmation. Type yes and press Enter.