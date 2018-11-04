resource "aws_key_pair" "demo" {
  key_name   = "demo"
  public_key = "${file("../demo-salt/salt/users/files/demo_id.pub")}"
}
resource "aws_key_pair" "jenkins" {
  key_name   = "EC2 Jenkins Slave"
  public_key = "${file("../demo-salt/salt/users/files/jenkins_id.pub")}"
}