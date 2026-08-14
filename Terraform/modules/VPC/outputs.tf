output "vpc_id" {
  description = "The ID of VPC"
  value       = aws_vpc.main_vpc.id
}

output "public_subnet_ids" {
  description = "A list of all public subnet IDs"
  value       = aws_subnet.public_subnets[*].id

}

output "private_subnet_ids" {
  description = "A list of all private subnet IDs"
  value       = aws_subnet.private_subnets[*].id

}
