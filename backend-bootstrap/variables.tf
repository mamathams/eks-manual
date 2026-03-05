variable "region" {
  description = "AWS region for backend resources"
  type        = string
  default     = "us-east-1"
}

variable "bucket_name" {
  description = "Globally unique S3 bucket name for Terraform state"
  type        = string
  default     = "eks-manual-tf-state-136191772987"
}

variable "dynamodb_table_name" {
  description = "DynamoDB table name for Terraform state locking"
  type        = string
  default     = "eks-manual-terraform-locks"
}

variable "environment" {
  description = "Tagging environment"
  type        = string
  default     = "dev"
}
