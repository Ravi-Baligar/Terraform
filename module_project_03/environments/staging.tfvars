region = "us-east-1"
environment = "staging"

vpc_cidr = "10.0.0.0/16"

availability_zones = ["us-east-1a", "us-east-1b"]

public_subnet_cidrs =[ "10.0.0.0/24" , "10.0.1.0/24"]

private_subnet_cidrs = [ "10.0.2.0/24" , "10.0.3.0/24"]

# allowed_ssh_cidr =[]

# instance_count = 1

instance_type =  "t2.micro"

ssh_key_name = "us-region.pem"

asg_min = 3

asg_max = 6

asg_desired = 3