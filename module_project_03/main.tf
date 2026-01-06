

############################################
# VPC Module
############################################
module "vpc" {
  source               = "./modules/vpc"
  environment          = var.environment
  vpc_cidr             = var.vpc_cidr
  availability_zones   = var.availability_zones
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  allowed_ssh_cidr     = var.allowed_ssh_cidr
}

data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

module "compute" {
  source             = "./modules/compute"
  environment        = var.environment
  vpc_id             = module.vpc.vpc_id
  ami_id             = data.aws_ami.amazon_linux_2.id
  instance_type      = var.instance_type
  user_data_file     = "/home/ravi/Documents/Terraform/module_project_03/userdata1.sh"
  private_subnet_ids = module.vpc.private_subnet_ids
  public_subnet_ids  = module.vpc.public_subnet_ids
  asg_min            = var.asg_min
  asg_max            = var.asg_max
  asg_desired        = var.asg_desired
}

