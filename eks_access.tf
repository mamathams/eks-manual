locals {
  enable_eks_access_entry = var.eks_access_principal_arn != ""
}

resource "aws_eks_access_entry" "console_user" {
  count         = local.enable_eks_access_entry ? 1 : 0
  cluster_name  = aws_eks_cluster.eks_cluster.name
  principal_arn = var.eks_access_principal_arn
  type          = "STANDARD"

  depends_on = [aws_eks_cluster.eks_cluster]
}

resource "aws_eks_access_policy_association" "console_user" {
  count         = local.enable_eks_access_entry ? 1 : 0
  cluster_name  = aws_eks_cluster.eks_cluster.name
  principal_arn = var.eks_access_principal_arn
  policy_arn    = var.eks_access_policy_arn

  access_scope {
    type = "cluster"
  }

  depends_on = [aws_eks_access_entry.console_user]
}
