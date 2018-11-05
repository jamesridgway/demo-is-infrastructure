resource "aws_lb" "core-alb" {
  name               = "core-alb"
  internal           = false
  load_balancer_type = "application"
  subnets            = ["${data.aws_subnet.eu-west-1a.id}", "${data.aws_subnet.eu-west-1b.id}", "${data.aws_subnet.eu-west-1c.id}"]
  security_groups    = ["${data.aws_security_group.default.id}", "${aws_security_group.HTTPS.id}", "${aws_security_group.HTTP.id}"]

  tags {
    Name = "Core ALB"
    Project = "Core"
  }
}

resource "aws_route53_record" "alb" {
  zone_id = "${data.aws_route53_zone.domain.zone_id}"
  name    = "*.is.${var.domain}"
  type    = "A"
  alias {
    name                   = "${aws_lb.core-alb.dns_name}"
    zone_id                = "${aws_lb.core-alb.zone_id}"
    evaluate_target_health = false
  }
}


resource "aws_security_group" "HTTP" {
  name        = "HTTP"
  description = "Allow HTTP traffic"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "HTTPS"
    Project = "Core"
  }
}

resource "aws_security_group" "HTTPS" {
  name        = "HTTPS"
  description = "Allow HTTPS traffic"

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "HTTPS"
    Project = "Core"
  }
}


resource "aws_lb_listener" "https" {
  load_balancer_arn = "${aws_lb.core-alb.arn}"
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2015-05"
  certificate_arn   = "${aws_acm_certificate.wildcard-certificate-euwest1.arn}"

  default_action {
    target_group_arn = "${aws_lb_target_group.website.arn}"
    type             = "forward"
  }
}


resource "aws_lb_target_group" "website" {
  name     = "website"
  port     = 3000
  protocol = "HTTP"
  vpc_id   = "${data.aws_vpc.main.id}"

  health_check {
    path = "/api/v1/version"
  }

  tags {
    Name = "website"
    Project = "website"
  }
}

resource "aws_security_group" "rails_app" {
  name        = "Rails App"
  description = "Allow internal HTTP traffic"

  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["172.16.0.0/12"]
  }

  tags {
    Name = "Rails App"
    Project = "website"
  }
}


resource "aws_lb_listener_rule" "website" {
  listener_arn = "${aws_lb_listener.https.arn}"
  priority     = 1

  action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.website.arn}"
  }

  condition {
    field  = "host-header"
    values = ["webapp.is.${var.domain}"]
  }
}


resource "aws_iam_policy" "website" {
  name        = "website"
  description = "Allow website to access pricing and EC2 information"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
        {
            "Sid": "",
            "Action": [
                "ec2:DescribeInstances",
                "ec2:DescribeSpotPriceHistory",
                "pricing:GetProducts",
                "iam:GetRole"
            ],
            "Effect": "Allow",
            "Resource": [
                "*"
            ]
        }
    ]
}
EOF
}


resource "aws_iam_policy_attachment" "website" {
  name       = "website"
  roles      = ["${aws_iam_role.website.name}"]
  policy_arn = "${aws_iam_policy.website.arn}"
}

resource "aws_iam_instance_profile" "website" {
  name = "website"
  role = "${aws_iam_role.website.name}"
}

resource "aws_iam_role" "website" {
  name = "website"
  description = "IAM role for Website"
  path = "/"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}