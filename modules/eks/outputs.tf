output "cluster_endpoint" {
  value = aws_eks_cluster.this.endpoint
}

output "cluster_security_group_id" {
  value = aws_eks_cluster.this.vpc_config[0].cluster_security_group_id
}

output "cluster_name" {
  value = aws_eks_cluster.this.name
}

output "oidc_provider_arn" {
  value = aws_iam_openid_connect_provider.this.arn
}

output "node_group_role_arn" {
  value = aws_iam_role.nodes.arn
}
