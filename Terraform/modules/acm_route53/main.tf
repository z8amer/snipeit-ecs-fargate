# Route53 Public Hosted Zone
data "aws_route53_zone" "primary_zone" {
  name         = var.root_domain
  private_zone = false
}

# Request a SSL/TLS certificate from ACM.
resource "aws_acm_certificate" "acm_cert" {
  domain_name       = "${var.sub_domain}.${var.root_domain}"
  validation_method = "DNS"

  tags = {
    Name = "${var.project_name}-cert"
  }

  lifecycle {
    create_before_destroy = true
  }
}

#Loop through ACM domain validation options to produce exact CNAME records to prove domain ownership.
resource "aws_route53_record" "cert_validation_records" {
  for_each = {
    for dvo in aws_acm_certificate.acm_cert.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = var.dns_ttl
  type            = each.value.type
  zone_id         = data.aws_route53_zone.primary_zone.zone_id
}

#Terraform can only proceed when handshake is done
resource "aws_acm_certificate_validation" "cert_handshake" {
  certificate_arn         = aws_acm_certificate.acm_cert.arn
  validation_record_fqdns = [for record in aws_route53_record.cert_validation_records : record.fqdn]
}

#Maps subdomain to ALB using Route53 Alias
resource "aws_route53_record" "alb_alias" {
  zone_id = data.aws_route53_zone.primary_zone.zone_id
  name    = "${var.sub_domain}.${var.root_domain}"
  type    = "A" # Route 53 alias records must always be type A

  alias {
    name                   = var.alb_dns_name
    zone_id                = var.alb_zone_id
    evaluate_target_health = true
  }
}
