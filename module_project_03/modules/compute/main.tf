############################################
# Security Groups
############################################

# ALB SG - allow HTTP from internet
resource "aws_security_group" "alb_sg" {
  name        = "${var.environment}-alb-sg"
  vpc_id      = var.vpc_id
  description = "ALB security group"

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

  tags = {
    Name = "${var.environment}-alb-sg"
  }
}

# App SG - allow only from ALB SG
resource "aws_security_group" "app_sg" {
  name        = "${var.environment}-app-sg"
  vpc_id      = var.vpc_id
  description = "App security group"

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

  tags = {
    Name = "${var.environment}-app-sg"
  }
}

############################################
# Launch Template
############################################
resource "aws_launch_template" "app" {
  name_prefix            = "${var.environment}-app-template"
  image_id               = var.ami_id
  instance_type          = var.instance_type
  vpc_security_group_ids = [aws_security_group.app_sg.id]
  user_data              = base64encode(file(var.user_data_file))

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "${var.environment}-app-instance"
      Env  = var.environment
    }
  }
}

############################################
# Auto Scaling Group
############################################
resource "aws_autoscaling_group" "app_asg" {
  name                = "${var.environment}-app-asg"
  desired_capacity    = var.asg_desired
  max_size            = var.asg_max
  min_size            = var.asg_min
  vpc_zone_identifier = var.private_subnet_ids
  health_check_type   = "ELB"
  target_group_arns   = [aws_lb_target_group.app_tg.arn]

  launch_template {
    id      = aws_launch_template.app.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "${var.environment}-asg-app-instance"
    propagate_at_launch = true
  }
}

############################################
# Application Load Balancer
############################################
resource "aws_lb" "alb" {
  name               = "${var.environment}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = var.public_subnet_ids

  tags = {
    Name = "${var.environment}-alb"
  }
}

resource "aws_lb_target_group" "app_tg" {
  name     = "${var.environment}-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    path                = "/"
    port                = "traffic-port"
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 10
    interval            = 30
  }

  tags = {
    Name = "${var.environment}-tg"
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_tg.arn
  }
}


