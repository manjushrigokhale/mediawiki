terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}
#cloud provider#
provider "aws" {
  region = "us-east-1"
  profile = "mediawiki"
}
#availability zone#
data "aws_availability_zones" "az" {
  state = "available"  
}
#vpc#
resource "aws_vpc" "media_vpc" {
  cidr_block = "192.168.0.0/16"
  tags = {
      Name = "mediawiki"
      Project = "mediawiki"
  }
}

# Subnets #
resource "aws_subnet" "public_1" {
  vpc_id = "aws_vpc.media_vpc.id"
  availability_zone = "data.aws_availability_zones.az.names[0]"
  cidr_block = "192.168.0.0/24"
  map_public_ip_on_launch = true
  
  tags = { 
      Name = "mediawiki_public_1"
      Project = "mediawiki"
  }
}

resource "aws_subnet" "public_2" {
  vpc_id = "aws_vpc.media_vpc.id"
  availability_zone = "data.aws_availability_zones.az.names[1]"
  cidr_block = "192.168.1.0/24"
  map_public_ip_on_launch = true
  
  tags = { 
      Name = "mediawiki_public_2"
      Project = "mediawiki"
  }
}

resource "aws_subnet" "private_1" {
  vpc_id = "aws_vpc.media_vpc.id"
  availability_zone = "data.aws_availability_zones.az.names[0]"
  cidr_block = "192.168.2.0/24"
  
  tags = {
      Name = "mediawiki_private_1"
  }
}

#internet gateway#
resource "aws_internet_gateway" "media_igw" {
  vpc_id ="aws_vpc.media_vpc.id"
  
  tags = {
      Name = "mediawiki"
    }
}

#route tables#
resource "aws_route_table" "rt_public" {
  vpc_id = "aws_vpc.media_vpc.id"
  route{
      cidr_block = "0.0.0.0/0"
      gateway_id = "aws_internet_gateway.media_igw.id"
  }

  tags = {
      Name = "rt_public"
  }
}

resource "aws_route_table" "rt_private" {
  vpc_id = "aws_vpc.media_vpc.id"

  tags = {
      Name = "rt_private"
  }
}

#rt and subnet association#
resource "aws_route_table_association" "rta_public_1" {
  route_table_id = "aws_route_table.rt_public.id"
  subnet_id = "aws_subnet.public_1.id"
}

resource "aws_route_table_association" "rta_public_2" {
  route_table_id = "aws_route_table.rt_public.id"
  subnet_id = "aws_subnet.public_2.id"
}

resource "aws_route_table_association" "rta_private_1" {
  route_table_id = "aws_route_table.rt_private.id"
  subnet_id = "aws_subnet.private_1.id"
}

#security group#

resource "aws_security_group" "sg_public" {
  name = "web_access"
  description = "EC2 created under public subnet will have access to ports 80 and 22"
  vpc_id = "aws_vpc.media_vpc.id"

  tags = {
      Name = "sg_public"
  }

  #ssh
  ingress{
      from_port = 22
      to_port = 22
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
  }

  #http
  ingress{
      from_port = 80
      to_port = 80
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
  }

  egress{
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "sg_private" {
  name = "database_access"
  description = "EC2 created under public subnet will have access to ports 22 and 3306"
  vpc_id = "aws_vpc.media_vpc.id"

  tags = {
      Name = "sg_private"
  }

  #ssh
  ingress{
      from_port = 22
      to_port = 22
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
  }

  #mysql
  ingress{
      from_port = 3306
      to_port = 3306
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
  }

  egress{
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = ["0.0.0.0/0"]
  }
}
#key-pair#
resource "aws_key_pair" "media_key" {
  key_name = "var.key_name"
  public_key = file("/files/mediawiki.pub")
}

#EC2 setup#
resource "aws_instance" "media_web_1" {
  ami = "var.ami"
  instance_type = "var.web_instance_type"
  key_name = "aws_key_pair.media_key.id"
  vpc_security_group_ids = ["aws_security_group.sg_public.id"]
  subnet_id = "aws_subnet.public_1.id"

  tags = {
    Name = "media_web_1"
    Project = "mediawiki"
  }
  root_block_device {
    volume_size           = 50
    delete_on_termination = "true"
    encrypted             = "true"
  }
  volume_tags = {
    Name       = "MEDIAWIKI-WEB-SERVER"
  }

}

resource "aws_instance" "media_web_2" {
  ami = "var.ami"
  instance_type = "var.web_instance_type"
  key_name = "aws_key_pair.media_key.id"
  vpc_security_group_ids = ["aws_security_group.sg_public.id"]
  subnet_id = "aws_subnet.public_2.id"

  tags = {
    Name = "media_web_2"
    Project = "mediawiki"
  }
    root_block_device {
    volume_size           = 50
    delete_on_termination = "true"
    encrypted             = "true"
  }
  volume_tags = {
    Name       = "MEDIAWIKI-WEB-SERVER"
  }

}


resource "aws_instance" "media_db" {
  ami = "var.ami"
  instance_type = "var.db_instance_type"
  key_name = "aws_key_pair.media_key.id"
  vpc_security_group_ids = ["aws_security_group.sg_private.id"]
  subnet_id = "aws_subnet.private_1.id"

  tags = {
    Name = "media_db"
    Project = "mediawiki"
  }
}

#ELB#
resource "aws_elb" "media_elb" {
  name = "media-elb"
  subnets = ["aws_subnet.public_1.id", "aws_subnet.public_2.id"]
  instances = ["aws_instance.media_web_1.id", "aws_instance.media_web_1.id"]
  security_groups = ["aws_securitygroup.sg_public.id"]

  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

  health_check {
    healthy_threshold   = "2"
    unhealthy_threshold = "3"
    timeout             = "3"
    target              = "TCP:80"
    interval            = "30"
  }

  cross_zone_load_balancing   = true
  idle_timeout                = 300
  connection_draining         = true
  connection_draining_timeout = 300

  tags = {
    Name = "media-elb"
    Project = "mediawiki"
  }
}

resource "aws_lb_cookie_stickiness_policy" "media_lb_policy" {
  name                     = "media-lb-policy"
  load_balancer            = "aws_elb.media_elb.id"
  lb_port                  = 80
  cookie_expiration_period = 600
}
