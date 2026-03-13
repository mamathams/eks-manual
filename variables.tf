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

variable "cluster_authentication_mode" {
  description = "EKS cluster authentication mode (must be API or API_AND_CONFIG_MAP to use EKS Access Entries)"
  type        = string
  default     = "API_AND_CONFIG_MAP"
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

variable "node_ami_type" {
  description = "Managed node group AMI type (set to AL2023 to avoid Amazon Linux 2 deprecation)"
  type        = string
  default     = "AL2023_x86_64_STANDARD"
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

variable "pod_namespace" {
  description = "Namespace for the example pod"
  type        = string
  default     = "demo"
}

variable "pod_name" {
  description = "Name for the example pod"
  type        = string
  default     = "nginx"
}

variable "pod_image" {
  description = "Container image for the example pod"
  type        = string
  default     = "nginx:1.27-alpine"
}

variable "eks_access_principal_arn" {
  description = "IAM principal ARN (user/role) to grant EKS console Kubernetes UI access (leave empty to skip)"
  type        = string
  default     = ""
}

variable "eks_access_policy_arn" {
  description = "EKS cluster access policy ARN to associate with eks_access_principal_arn"
  type        = string
  default     = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSViewPolicy"
}

variable "manage_kubernetes_resources" {
  description = "Whether Terraform should manage in-cluster Kubernetes resources (namespace/pod). Disable to destroy the EKS infra even if the cluster API is unreachable."
  type        = bool
  default     = true
}
