output "vpc_id" {
  value = aws_vpc.main.id
}

output "public_subnet_id" {
  value = aws_subnet.public.id
}

output "private_active_subnet_id" {
  value = aws_subnet.private_active.id
}

output "private_inactive_subnet_id" {
  value = aws_subnet.private_inactive.id
}
