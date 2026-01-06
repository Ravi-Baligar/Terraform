provider "aws" {
  region = "us-east-1"
}

resource "aws_vpc" "myvpc" {
  cidr_block = var.cidr
}

resource "aws_subnet" "sub-pub-1" {
  vpc_id                  = aws_vpc.myvpc.id
  cidr_block              = "10.0.0.0/24"
  availability_zone       = var.availability_zone_1
  map_public_ip_on_launch = true
}

resource "aws_subnet" "sub-pub-2" {
  vpc_id                  = aws_vpc.myvpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = var.availability_zone_2
  map_public_ip_on_launch = true
}

resource "aws_subnet" "sub-prv-1" {
  vpc_id            = aws_vpc.myvpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = var.availability_zone_1
}

resource "aws_subnet" "sub-prv-2" {
  vpc_id            = aws_vpc.myvpc.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = var.availability_zone_2
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

resource "aws_route_table_association" "rta-pub-sub-1" {
  route_table_id = aws_route_table.rt.id
  subnet_id      = aws_subnet.sub-pub-1.id
}

resource "aws_route_table_association" "rta-pub-sub-2" {
  route_table_id = aws_route_table.rt.id
  subnet_id      = aws_subnet.sub-pub-2.id
}

resource "aws_eip" "nat-eip-1" {
  domain = "vpc"
}

resource "aws_eip" "nat-eip-2" {
  domain = "vpc"
}

resource "aws_nat_gateway" "nat-prv-1" {
  allocation_id = aws_eip.nat-eip-1.id
  subnet_id     = aws_subnet.sub-pub-1.id
  tags = {
    Name = "nat-gw-az1"
  }

  depends_on = [aws_internet_gateway.igw]
}

resource "aws_nat_gateway" "nat-prv-2" {
  allocation_id = aws_eip.nat-eip-2.id
  subnet_id     = aws_subnet.sub-pub-2.id
  tags = {
    Name = "nat-gw-az2"
  }

  depends_on = [aws_internet_gateway.igw]
}

resource "aws_route_table" "private_rt_1" {
  vpc_id = aws_vpc.myvpc.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat-prv-1.id
  }
}

resource "aws_route_table_association" "rta-prv-sub-1" {
  subnet_id      = aws_subnet.sub-prv-1.id
  route_table_id = aws_route_table.private_rt_1.id
}


resource "aws_route_table" "private_rt_2" {
  vpc_id = aws_vpc.myvpc.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat-prv-2.id
  }
}

resource "aws_route_table_association" "rta-prv-sub-2" {
  subnet_id      = aws_subnet.sub-prv-2.id
  route_table_id = aws_route_table.private_rt_2.id
}

resource "aws_security_group" "alb_sg" {
  name   = "alb-sg"
  vpc_id = aws_vpc.myvpc.id

  ingress {
    description = "Allow HTTP from internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "sg" {
  name   = "app-sg"
  vpc_id = aws_vpc.myvpc.id

  ingress {
    description     = "Allow HTTP from ALB only"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_launch_template" "app" {
  name_prefix            = "app-template"
  image_id               = data.aws_ami.amazon_linux_2.id
  instance_type          = var.instance_type
  vpc_security_group_ids = [aws_security_group.sg.id]
  user_data              = base64encode(file("userdata1.sh"))

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "app-instance"
    }
  }
}

resource "aws_autoscaling_group" "app_asg" {
  name                = "app-asg"
  desired_capacity    = 2
  max_size            = 4
  min_size            = 2
  vpc_zone_identifier = [aws_subnet.sub-prv-1.id, aws_subnet.sub-prv-2.id]
  health_check_type   = "ELB"
  target_group_arns   = [aws_lb_target_group.alb-tg.arn]

  launch_template {
    id      = aws_launch_template.app.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "asg-app-instance"
    propagate_at_launch = true
  }
}

resource "aws_lb" "alb" {
  name               = "web-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = [aws_subnet.sub-pub-1.id, aws_subnet.sub-pub-2.id]
}

resource "aws_lb_target_group" "alb-tg" {
  name     = "alb-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.myvpc.id

  health_check {
    path                = "/"
    port                = "traffic-port" # It is like taffic or redirection
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 10
    interval            = 30
  }

}

resource "aws_lb_listener" "listner" {
  load_balancer_arn = aws_lb.alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb-tg.arn
  }
}

output "dns_namealb" {
  value = aws_lb.alb.dns_name
}