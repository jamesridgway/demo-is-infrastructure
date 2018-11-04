data "aws_vpc" "main" {
}
data "aws_subnet" "eu-west-1a" {
  availability_zone = "eu-west-1a"
}

data "aws_subnet" "eu-west-1b" {
  availability_zone = "eu-west-1b"
}

data "aws_subnet" "eu-west-1c" {
  availability_zone = "eu-west-1c"
}
