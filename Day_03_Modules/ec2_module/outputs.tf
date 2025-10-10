output "public_ip_ec2_instance" {
  description = "Public IP of the instance"
  value = aws_instance.myec2.public_ip
}