vpc_name = "eks_vpc"
vpc_cidr = "10.0.0.0/16"
gw_name = "eks_gw"
avail_zones = ["us-west-2a","us-west-2b"]
private_subnets = ["10.0.1.0/24","10.0.2.0/24"]
public_subnets = ["10.0.3.0/24","10.0.4.0/24"]
public_subnet_name = ["public_subnet_1a","public_subnet_1b"]
cluster_name = "three-tier-cluster"
ami = "ami-04b70fa74e45c3917"
ec2_type = "t2.medium"
ec2_avail = "us-west-2a"