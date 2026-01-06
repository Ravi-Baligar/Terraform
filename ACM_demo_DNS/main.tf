provider "aws" {
  region = "us-east-1"
}

resource "aws_vpc" "myvpc" {
  cidr_block = var.cidr_range
  region = "us-east-1"
}

resource "aws_subnet" "pub-sub-1" {
  vpc_id = aws_vpc.myvpc.id
  availability_zone = "us-east-1a"
  cidr_block = "10.0.1.0/24"
  map_public_ip_on_launch = true
}

resource "aws_subnet" "pub-sub-2" {
  vpc_id = aws_vpc.myvpc.id
  availability_zone = "us-east-1b"
  cidr_block = "10.0.2.0/24"
  map_public_ip_on_launch = true
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.myvpc.id
}

resource "aws_route_table" "rt" {
  vpc_id = aws_vpc.myvpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

resource "aws_route_table_association" "rt-asso" {
  subnet_id = aws_subnet.pub-sub-1.id
  route_table_id = aws_route_table.rt.id
}

resource "aws_route_table_association" "rt-asso-2" {
  subnet_id      = aws_subnet.pub-sub-2.id
  route_table_id = aws_route_table.rt.id
}

resource "aws_security_group" "sg" {
  vpc_id = aws_vpc.myvpc.id

  ingress {
    protocol  = "tcp"
    from_port = 22
    to_port   = 22
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    protocol  = "tcp"
    from_port = 80
    to_port   = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "myec2" {
  ami = "ami-0360c520857e3138f"
  instance_type = "t2.micro"
  subnet_id = aws_subnet.pub-sub-1.id
  security_groups = [ aws_security_group.sg.id ]
  user_data_base64 = base64encode(file("userdata.sh"))
}

resource "aws_lb" "test" {
  name               = "test-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.sg.id]
  subnets            = [aws_subnet.pub-sub-1.id, aws_subnet.pub-sub-2.id ]
  tags = {
    Name = "Web"
  }
}

resource "aws_lb_target_group" "test" {
  name     = "tf-example-lb-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.myvpc.id
  health_check {
    path = "/"
    port = "traffic-port" # It is like taffic or redirection
  }
}

resource "aws_lb_target_group_attachment" "test" {
  target_group_arn = aws_lb_target_group.test.arn
  target_id        = aws_instance.myec2.id
  port             = 80
}

resource "aws_lb_listener" "alb-listener" {
  load_balancer_arn = aws_lb.test.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.test.arn
  }
}

resource "aws_route53_zone" "main" {
  name = "dev-demo.com"  # Replace with your domain
}

resource "aws_route53_record" "ravi_baligar" {
  zone_id = aws_route53_zone.main.zone_id
  name    = "ravi.baligar.dev-demo.com"
  type    = "A"

  alias {
    name                   = aws_lb.test.dns_name
    zone_id                = aws_lb.test.zone_id
    evaluate_target_health = true
  }
}


output "dns_name" {
  value = aws_route53_record.ravi_baligar.name
}



