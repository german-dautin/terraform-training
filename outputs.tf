output public_ip {
  description = "The public IP attached to the instance"
  value       = aws_instance.test.public_ip
}
