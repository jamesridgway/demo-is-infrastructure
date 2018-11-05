resource "aws_route53_record" "jenkins" {
  zone_id = "${data.aws_route53_zone.domain.zone_id}"
  name    = "jenkins.is.${var.domain}"
  type    = "A"

  alias {
    name                   = "${aws_lb.core-alb.dns_name}"
    zone_id                = "${aws_lb.core-alb.zone_id}"
    evaluate_target_health = false
  }
}

resource "aws_spot_fleet_request" "jenkins-master" {
  iam_fleet_role      = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/aws-ec2-spot-fleet-tagging-role"
  allocation_strategy = "lowestPrice"
  target_capacity     = 1
  valid_until         = "2028-08-03T16:00:00Z"
  instance_interruption_behaviour = "stop"
  launch_specification {
    ami      = "${data.aws_ami.jenkins_master_ami.id}"
    instance_type = "t3.small"
    iam_instance_profile_arn = "${aws_iam_instance_profile.jenkins_ci_master.arn}"
    key_name = "demo"
    vpc_security_group_ids = ["${aws_security_group.ssh.id}",
                       "${aws_security_group.http_8080.id}",
                       "${data.aws_security_group.default.id}"]
    tags {
      Name = "Jenkins"
      Project = "Core"
    }
  }
  target_group_arns = ["${aws_lb_target_group.jenkins.arn}"]
}


resource "aws_lb_target_group" "jenkins" {
  name     = "Jenkins"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = "${data.aws_vpc.main.id}"

  health_check {
    path = "/login"
  }

  tags {
    Name = "jenkins"
    Project = "Core"
  }
}

resource "aws_lb_listener_rule" "jenkins" {
  listener_arn = "${aws_lb_listener.https.arn}"
  priority     = 2

  action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.jenkins.arn}"
  }

  condition {
    field  = "host-header"
    values = ["jenkins.is.${var.domain}"]
  }
}


resource "aws_iam_policy" "jenkins_ci_master_spot_instances" {
  name        = "jenkins_ci_master_spot_instances"
  description = "Allow Jenkins CI master to spawn EC2 spot instances"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "Stmt1312295543082",
      "Action": [
        "ec2:CancelSpotInstanceRequests",
        "ec2:CreateTags",
        "ec2:DeleteTags",
        "ec2:DescribeAvailabilityZones",
        "ec2:DescribeImages",
        "ec2:DescribeInstances",
        "ec2:DescribeKeyPairs",
        "ec2:DescribeRegions",
        "ec2:DescribeSecurityGroups",
        "ec2:DescribeSpotInstanceRequests",
        "ec2:DescribeSpotPriceHistory",
        "ec2:DescribeSubnets",
        "ec2:GetConsoleOutput",
        "ec2:RequestSpotInstances",
        "ec2:RunInstances",
        "ec2:StartInstances",
        "ec2:StopInstances",
        "ec2:TerminateInstances",
        "iam:CreateServiceLinkedRole",
        "iam:GetInstanceProfile",
        "iam:PassRole"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_policy" "read_jenkins_slave_private_key" {
  name        = "read_jenkins_slave_private_key"
  description = "Read Jenkins Slave Private Key secret"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "VisualEditor0",
      "Effect": "Allow",
      "Action": [
        "secretsmanager:GetResourcePolicy",
        "secretsmanager:GetSecretValue",
        "secretsmanager:DescribeSecret",
        "secretsmanager:ListSecretVersionIds"
      ],
      "Resource": [
        "${aws_secretsmanager_secret.jenkins_slave_private_key.arn}",
        "${aws_secretsmanager_secret.jenkins_master.arn}"
      ]
    }
  ]
}
EOF
}

resource "aws_iam_role" "jenkins_ci_slave" {
  name = "jenkins_ci_slave"
  description = "IAM role for Jenkins CI slave"
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

resource "aws_iam_policy" "jenkins_ci_slave_packer_build" {
  name        = "jenkins_ci_slave_packer_build"
  description = "Allow Jenkins CI slaves to build packer AMIs"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
        {
            "Sid": "PackerEC2",
            "Action": [
                "ec2:AuthorizeSecurityGroupIngress",
                "ec2:CancelSpotFleetRequests",
                "ec2:CancelSpotInstanceRequests",
                "ec2:CreateImage",
                "ec2:CreateKeyPair",
                "ec2:CreateSecurityGroup",
                "ec2:CreateSnapshot",
                "ec2:CreateTags",
                "ec2:DeleteKeyPair",
                "ec2:DeleteSecurityGroup",
                "ec2:DeleteSnapshot",
                "ec2:DeleteTags",
                "ec2:DeregisterImage",
                "ec2:DescribeAvailabilityZones",
                "ec2:DescribeImages",
                "ec2:DescribeInstances",
                "ec2:DescribeKeyPairs",
                "ec2:DescribeRegions",
                "ec2:DescribeSecurityGroups",
                "ec2:DescribeSnapshots",
                "ec2:DescribeSpotFleetInstances",
                "ec2:DescribeSpotFleetRequests",
                "ec2:DescribeSpotFleetRequestHistory",
                "ec2:DescribeSpotInstanceRequests",
                "ec2:DescribeSpotPriceHistory",
                "ec2:DescribeSubnets",
                "ec2:GetConsoleOutput",
                "ec2:ModifySpotFleetRequest",
                "ec2:RebootInstances",
                "ec2:RegisterImage",
                "ec2:RequestSpotFleet",
                "ec2:RequestSpotInstances",
                "ec2:RevokeSecurityGroupIngress",
                "ec2:RunInstances",
                "ec2:StartInstances",
                "ec2:StopInstances",
                "ec2:TerminateInstances",
                "ec2:DescribeVolumeAttribute",
                "ec2:DescribeVolumes",
                "ec2:DescribeVolumeStatus",
                "ec2:AttachVolume",
                "ec2:CreateVolume",
                "ec2:DeleteVolume",
                "ec2:DetachVolume",
                "iam:CreateServiceLinkedRole",
                "iam:PassRole",
                "elasticloadbalancing:DescribeTargetHealth",
                "elasticloadbalancing:DescribeTargetGroups"
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


resource "aws_iam_policy_attachment" "jenkins_ci_slave" {
  name       = "jenkins-slave-attachment"
  roles      = ["${aws_iam_role.jenkins_ci_slave.name}"]
  policy_arn = "${aws_iam_policy.jenkins_ci_slave_packer_build.arn}"
}

resource "aws_iam_instance_profile" "jenkins_ci_slave" {
  name = "jenkins_ci_slave"
  role = "${aws_iam_role.jenkins_ci_slave.name}"
}


resource "aws_iam_role" "jenkins_ci_master" {
  name = "jenkins_ci_master"
  description = "IAM role for Jenkins CI master"
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

resource "aws_iam_role" "aws-ec2-spot-fleet-tagging-role" {
  name = "aws-ec2-spot-fleet-tagging-role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "spotfleet.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}
resource "aws_iam_role_policy_attachment" "AmazonEC2SpotFleetTaggingRole-policy-attachment" {
  role = "${aws_iam_role.aws-ec2-spot-fleet-tagging-role.name}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2SpotFleetTaggingRole"
}

resource "aws_iam_policy_attachment" "jenkins_ci_master_spot" {
  name       = "test-attachment"
  roles      = ["${aws_iam_role.jenkins_ci_master.name}"]
  policy_arn = "${aws_iam_policy.jenkins_ci_master_spot_instances.arn}"
}


resource "aws_iam_policy_attachment" "jenkins_ci_master_read_jenkins_slave_private_key" {
  name       = "read_jenkins_slave_private_key"
  roles      = ["${aws_iam_role.jenkins_ci_master.name}"]
  policy_arn = "${aws_iam_policy.read_jenkins_slave_private_key.arn}"
}

resource "aws_iam_instance_profile" "jenkins_ci_master" {
  name = "jenkins_ci_master"
  role = "${aws_iam_role.jenkins_ci_master.name}"
}

resource "aws_secretsmanager_secret" "jenkins_slave_private_key" {
  name        = "jenkins_slave_private_key"
  description = "Private key for 'jenkins' user on Jenkins Slaves"
  tags {
    Project = "Jenkins"
  }
}

resource "aws_secretsmanager_secret_version" "jenkins_slave_private_key" {
  secret_id     = "${aws_secretsmanager_secret.jenkins_slave_private_key.id}"
  secret_string = "${file("../demo-salt/salt/users/files/jenkins_id")}"
}


resource "aws_secretsmanager_secret" "jenkins_master" {
  name        = "jenkins_master"
  description = "Private key for 'jenkins' user on Jenkins Slaves"
  tags {
    Project = "Jenkins"
  }
}

resource "aws_secretsmanager_secret_version" "jenkins_master" {
  secret_id     = "${aws_secretsmanager_secret.jenkins_master.id}"
  secret_string = "${jsonencode(map("admin_username", "${var.admin_username}", "admin_password", "${var.admin_password}", "github_token", "${var.github_token}", "github_webhook_username", "${var.github_webhook_username}", "github_webhook_password", "${var.github_webhook_password}", "github_webhook_secret", "${var.github_webhook_secret}", "github_username", "${var.github_username}", "github_repos", "${var.github_repos}", "jenkins_url", "https://jenkins.is.${var.domain}"))}"
}
