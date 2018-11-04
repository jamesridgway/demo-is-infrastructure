provider "aws" {
  region = "${var.region}"
  profile = "demo"
}
provider "aws" {
  region = "us-east-1"
  profile = "demo"
  alias  = "cloudfront_acm"
}
data "aws_caller_identity" "current" {}
