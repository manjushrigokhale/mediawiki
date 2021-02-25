#vpc#
resource "aws_vpc" "mediawiki" {
  cidr_block = "192.168.0.0/16"
  enable_dns_hostnames = true  
  tags = {
      Name = "mediawiki-vpc"
  }
}

# Subnets #
resource "aws_subnet" "public_1" {
  vpc_id = aws_vpc.mediawiki.id
  availability_zone = "us-east-1a"
  cidr_block = "192.168.0.0/24"
  map_public_ip_on_launch = true
  
  tags = { 
      Name = "mediawiki_public_1"
  }
}

resource "aws_subnet" "public_2" {
  vpc_id = aws_vpc.mediawiki.id
  availability_zone = "us-east-1b"
  cidr_block = "192.168.1.0/24"
  map_public_ip_on_launch = true
  
  tags = { 
      Name = "mediawiki_public_2"
  }
}

resource "aws_subnet" "private_1" {
  vpc_id = aws_vpc.mediawiki.id
  availability_zone = "us-east-1a"
  cidr_block = "192.168.2.0/24"
  
  tags = {
      Name = "mediawiki_private_1"
  }
}

#internet gateway#
resource "aws_internet_gateway" "media_igw" {
  vpc_id = aws_vpc.mediawiki.id
  
  tags = {
      Name = "mediawiki-igw"
    }
}

#route tables#
resource "aws_route_table" "rt_public" {
  vpc_id = aws_vpc.mediawiki.id
  route{
      cidr_block = "0.0.0.0/0"
      gateway_id = "aws_internet_gateway.media_igw.id"
  }

  tags = {
      Name = "rt_public"
  }
}

resource "aws_route_table" "rt_private" {
  vpc_id = "aws_vpc.mediawiki.id"

  tags = {
      Name = "rt_private"
  }
}

