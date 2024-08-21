output "cluster_id" {
  value = aws_eks_cluster.ofagbule.id
}

output "node_group_id" {
  value = aws_eks_node_group.ofagbule.id
}

output "vpc_id" {
  value = aws_vpc.ofagbule_vpc.id
}

output "subnet_ids" {
  value = aws_subnet.ofagbule_subnet[*].id
}
