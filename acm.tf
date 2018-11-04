resource "aws_acm_certificate" "wildcard-certificate-euwest1" {
  domain_name               = "is.${var.domain}"
  subject_alternative_names = ["*.is.${var.domain}"]
  validation_method         = "DNS"
  tags {
    Name = "${var.domain}"
    Project = "Core"
  }
}
resource "aws_route53_record" "wildcard-certificate-euwest1-validation" {
  name    = "${aws_acm_certificate.wildcard-certificate-euwest1.domain_validation_options.0.resource_record_name}"
  type    = "${aws_acm_certificate.wildcard-certificate-euwest1.domain_validation_options.0.resource_record_type}"
  zone_id = "${data.aws_route53_zone.domain.id}"
  records = ["${aws_acm_certificate.wildcard-certificate-euwest1.domain_validation_options.0.resource_record_value}"]
  ttl     = 60
}
resource "aws_acm_certificate_validation" "wildcard-certificate-euwest1" {
  certificate_arn         = "${aws_acm_certificate.wildcard-certificate-euwest1.arn}"
  validation_record_fqdns = ["${aws_route53_record.wildcard-certificate-euwest1-validation.fqdn}"]
}