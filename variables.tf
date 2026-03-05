variable "region" {
  description = "AWS Region"
  type        = string
  default     = "us-east-1"
}

variable "cluster_name" {
  description = "EKS Cluster Name"
  type        = string
  default     = "manual-eks-cluster"
}

variable "cluster_version" {
  description = "EKS Kubernetes Version"
  type        = string
  default     = "1.29"
}

variable "vpc_cidr" {
  description = "VPC CIDR Block"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "Public Subnet CIDRs"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  description = "Private Subnet CIDRs"
  type        = list(string)
  default     = ["10.0.3.0/24", "10.0.4.0/24"]
}

variable "instance_type" {
  description = "Worker Node Instance Type"
  type        = string
  default     = "t3.medium"
}

variable "desired_size" {
  description = "Node group desired size"
  type        = number
  default     = 1
}

variable "min_size" {
  description = "Minimum node size"
  type        = number
  default     = 1
}

variable "max_size" {
  description = "Maximum node size"
  type        = number
  default     = 1
}