output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.eks_vpc.id
}

output "public_subnets" {
  description = "Public Subnet IDs"
  value = [
    aws_subnet.public_1.id,
    aws_subnet.public_2.id
  ]
}

output "private_subnets" {
  description = "Private Subnet IDs"
  value = [
    aws_subnet.private_1.id,
    aws_subnet.private_2.id
  ]
}

output "cluster_name" {
  description = "EKS Cluster Name"
  value       = aws_eks_cluster.eks_cluster.name
}

output "cluster_endpoint" {
  description = "EKS Cluster Endpoint"
  value       = aws_eks_cluster.eks_cluster.endpoint
}

output "cluster_security_group_id" {
  description = "EKS Cluster Security Group"
  value       = aws_eks_cluster.eks_cluster.vpc_config[0].cluster_security_group_id
}

output "node_group_arn" {
  description = "Node Group ARN"
  value       = aws_eks_node_group.node_group.arn
}

output "pod_namespace" {
  description = "Namespace where the pod is created"
  value       = kubernetes_namespace_v1.pod_ns.metadata[0].name
}

output "pod_name" {
  description = "Name of the created pod"
  value       = kubernetes_pod_v1.app.metadata[0].name
}
