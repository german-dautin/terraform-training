output "alb_dns_name" {
    description = "CNAME of of load balancer"
    value       = aws_lb.test.dns_name
}