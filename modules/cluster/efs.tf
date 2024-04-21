resource "aws_security_group" "efs" {
  name ="${module.eks.cluster_name}-efs-sg"
  description = "Allow traffic"
  vpc_id = var.vpc_id

  ingress {
    description = "nfs"
    from_port = 2049
    to_port = 2049
    protocol = "TCP"
    security_groups = [module.eks.node_security_group_id]
  }
  tags = local.tags
  }

resource "aws_efs_file_system" "efs" {
  creation_token = "${module.eks.cluster_name}-efs"
  encrypted = true
  tags = merge(local.tags, {
    Name = "${module.eks.cluster_name}-efs"
  })
}

resource "aws_efs_mount_target" "efs" {
  for_each = toset(var.subnet_ids)
  subnet_id = each.key
  file_system_id = aws_efs_file_system.efs.id
  security_groups = [aws_security_group.efs.id]
}


