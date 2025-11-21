variable "aws_region" {
  description = "The AWS region to create resources in."
  type        = string
  default     = "us-east-1"
}

variable "cluster_name" {
  description = "The name for the EKS cluster."
  type        = string
  default     = "my-cluster"
}

variable "vpc_id" {
  description = "The ID of the VPC where the EKS cluster will be deployed."
  type        = string
}

variable "subnet_ids" {
  description = "A list of subnet IDs where the EKS cluster and nodes will be deployed."
  type        = list(string)
}
