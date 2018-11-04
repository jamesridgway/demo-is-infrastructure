data "aws_ami" "core_ami" {
  most_recent      = true
  filter {
    name   = "name"
    values = ["ubuntu-1804*"]
  }
  owners     = ["self"]
  tags {
    Project = "Core"
  }
}
data "aws_ami" "jenkins_master_ami" {
  most_recent      = true
  filter {
    name   = "name"
    values = ["jenkins-master*"]
  }
  owners     = ["self"]
  tags {
    Project = "Core"
  }
}