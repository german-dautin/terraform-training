provider "aws" {
    region = "eu-central-1"
}

# resource "aws_instance" "test" {
#     ami                    = "ami-00f69856ea899baec"
#     instance_type          = "t2.micro"
#     vpc_security_group_ids = [aws_security_group.instance.id]
#     user_data              = <<-EOF
#                              #!/bin/bash
#                              echo "Hello, World" > index.html
#                              nohup busybox httpd -f -p ${var.server_port} &
#                              EOF

#     tags = {
#         Name               = "terraform-example"
#     }
# }

resource "aws_launch_configuration" "test" {
    image_id            = ""
    instance_type       = "t2.micro"
    security_groups     = [aws_security_group.instance.id]
    user_data           = <<-EOF
                            #!/bin/bash
                            echo "Hello, World" > index.html
                            nohup busybox httpd -f -p ${var.server_port} &
                            EOF
    lifecycle {
        create_before_destroy = true
    }
}

resource "aws_autoscaling_group" "test" {
    launch_configuration = aws_launch_configuration.test.name
    vpc_zone_identifier  = aws_subnet_ids.default.ids

    target_group_arns    = [aws_lb_target_group.asg.arn]
    health_check_type    = "ELB"
    min_size = 2
    max_size = 10
    tag {
        key                = "Name"
        value              = "terraform-asg-example"
        propagate_at_launch = true
    }
}

resource "aws_security_group" "instance" {
    name          = "terraform-example-instance"

    ingress {
        from_port   = var.server_port
        to_port     = var.server_port
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

resource "aws_lb" "test" {
    name = "terraform-alb-example"
    load_balancer_type = "application"
    subnets            = data.aws_subnet_ids.default.ids
    security_groups    = [aws_security_group.alb.id]
}

resource "aws_lb_listener" "http" {
    load_balancer_arn = aws_lb.example.arn
    port              = 80
    protocol          = "HTTP"

    default_action {
        type = "fixed_response"
        fixed_response {
            content_type = "text/plain"
            message_body = "404: Not found"
            status_code  = 404
        }
    }
}

resource "aws_lb_listener_rule" "asg" {
    listner_arn = aws_lb_listener.http.arn
    priority    = 100

    condition {
        field = "path_pattern"
        values = [*]
    }

    action {
        type             = "forward"
        target_group_arn = aws_lb_target_group.asg.arn
    }
}

resource "aws_security_group" "alb" {
    name = "terraform-example-elb"
    ingress {
        from_port = 80
        to_port   = 80
        protocol  = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port = 0
        to_port   = 0
        protocol  = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

resource "aws_lb_target_group" "asg" {
    name = "terraform-asg-example"
    port = var.server_port
    protocol = "HTTP"
    vpc_id   = data.aws_vpc.default.id

    health_check {
        path     = "/"
        protocol = "HTTP"
        matcher  = "200"
        interval = 15
        timeout  = 3
        healthy_threshold = 2
        unhealthy_threshold = 2вввввввв
    }
}

data "aws_vpc" "default" {
    default = true
}

data "aws_subnet_ids" "default" {
  vpc_id = data.aws_vpc.default.id
}