resource "kubernetes_namespace_v1" "pod_ns" {
  count = var.manage_kubernetes_resources ? 1 : 0

  metadata {
    name = var.pod_namespace
  }

  depends_on = [
    aws_eks_cluster.eks_cluster,
    aws_eks_node_group.node_group,
    aws_eks_addon.vpc_cni,
    aws_eks_addon.kube_proxy,
    aws_eks_addon.coredns,
  ]
}

resource "kubernetes_pod_v1" "app" {
  count = var.manage_kubernetes_resources ? 1 : 0

  metadata {
    name      = var.pod_name
    namespace = kubernetes_namespace_v1.pod_ns[0].metadata[0].name

    labels = {
      app = var.pod_name
    }
  }

  spec {
    container {
      name  = "app"
      image = var.pod_image

      port {
        container_port = 80
      }
    }
  }

  depends_on = [
    aws_eks_cluster.eks_cluster,
    aws_eks_node_group.node_group,
    aws_eks_addon.vpc_cni,
    aws_eks_addon.kube_proxy,
    aws_eks_addon.coredns,
  ]
}
