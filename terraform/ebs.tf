# ============================================================
# AWS EBS CSI DRIVER EKS ADD-ON
# ============================================================

resource "aws_eks_addon" "ebs_csi" {
  cluster_name = aws_eks_cluster.main.name

  addon_name = "aws-ebs-csi-driver"

  service_account_role_arn = aws_iam_role.ebs_csi_driver.arn

  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"

  depends_on = [
    aws_iam_role_policy_attachment.ebs_csi_driver,
    aws_eks_node_group.main
  ]

  tags = {
    Name    = "${var.cluster_name}-ebs-csi"
    Project = var.cluster_name
  }
}

# ============================================================
# EBS STORAGE CLASS
# ============================================================

resource "kubernetes_storage_class_v1" "ebs" {
  metadata {
    name = "ebs-sc"

    annotations = {
      "storageclass.kubernetes.io/is-default-class" = "true"
    }
  }

  storage_provisioner = "ebs.csi.aws.com"

  reclaim_policy      = "Delete"
  volume_binding_mode = "WaitForFirstConsumer"

  parameters = {
    type      = "gp3"
    encrypted = "true"
  }

  depends_on = [
    aws_eks_addon.ebs_csi
  ]
}


