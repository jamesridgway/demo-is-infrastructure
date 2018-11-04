data "aws_security_group" "default" {
  vpc_id   = "${data.aws_vpc.main.id}"
  name = "default"
}

resource "aws_security_group" "ssh" {
  name        = "SSH"
  description = "Allow SSH traffic"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "SSH"
    Project = "Core"
  }
}

resource "aws_security_group" "http_8080" {
  name        = "HTTP (8080)"
  description = "HTTP (8080)"

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["172.16.0.0/12"]
  }

  tags {
    Name = "HTTP (8080)"
    Project = "Core"
  }
}