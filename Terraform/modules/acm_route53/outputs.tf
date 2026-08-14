output "certificate_arn" {
  value       = aws_acm_certificate_validation.cert_handshake.certificate_arn
  description = "The validated ARN of the SSL/TLS certificate"
}
