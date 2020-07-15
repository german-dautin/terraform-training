# output public_ip {
#   description = "The public IP attached to the instance"
#   value       = aws_instance.test.public_ip
# }

output "alb_dns_name" {
    description = "CNAME of of load balancer"
    value       = aws_lb.example.dns_name
}