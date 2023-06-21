resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "Airborne-vpc"
  }
}


# Public East-1a Subnet
resource "aws_subnet" "pub_sbnet_nat_1a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"
  tags = {
    Name = "Airborne-Public-1a"
  }
}


# Public East-1b Subnet
resource "aws_subnet" "pub_sbnet_nat_1b" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-1b"
  tags = {
    Name = "Airborne-Public-1b"
  }
}

# Private East-1a Subnet for EC2
resource "aws_subnet" "pvt_sbnet_ec2_1b" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.4.0/24"
  availability_zone = "us-east-1b"
  tags = {
    Name = "Airborne-EC2-Private-1b"
  }
}