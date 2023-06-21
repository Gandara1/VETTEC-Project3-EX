resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "Airborne-vpc"
  }
}


# Public East-1a Subnet  #1
resource "aws_subnet" "pub_sbnet_nat_1a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"
  tags = {
    Name = "Airborne-Public-1a"
  }
}


# Public East-1b Subnet  #2
resource "aws_subnet" "pub_sbnet_nat_1b" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-1b"
  tags = {
    Name = "Airborne-Public-1b"
  }
}

# Private East-1a Subnet for EKS  #3
resource "aws_subnet" "pvt_sbnet_eks_1a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "us-east-1a"
  tags = {
    Name = "Airborne-EC2-Private-1a"
  }
}

# Private East-1a Subnet for EKS  #4
resource "aws_subnet" "pvt_sbnet_eks_1b" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.4.0/24"
  availability_zone = "us-east-1b"
  tags = {
    Name = "Airborne-EC2-Private-1b"
  }
}

# Private East-1a Subnet for RDS   #5
resource "aws_subnet" "pvt_sbnet_rds_1a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.5.0/24"
  availability_zone = "us-east-1a"
  tags = {
    Name = "Airborne-RDS"
  }
}
# Private East-1b Subnet for RDS   #6
resource "aws_subnet" "pvt_sbnet_rds_1b" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.6.0/24"
  availability_zone = "us-east-1b"
  tags = {
    Name = "Airborne-RDS"
  }
}


# IGW is needed for public access
# Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
}

# Public and Private Route Tables
# Public route table
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "coffeePublicRouteTable"
  }
}

# Create a private route table
resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "AirbornePrivateRouteTable"
  }
}

# Route Table associations for traffic 
# Associate public route table with pub_sbnet_nat_1a
resource "aws_route_table_association" "pub_sbnet_nat_1a_association" {
  subnet_id      = aws_subnet.pub_sbnet_nat_1a.id
  route_table_id = aws_route_table.public_route_table.id
}
# Associate public route table with pub_sbnet_nat_1b
resource "aws_route_table_association" "pub_sbnet_nat_1b_association" {
  subnet_id      = aws_subnet.pub_sbnet_nat_1b.id
  route_table_id = aws_route_table.public_route_table.id
}

# Associate private route table with pvt_sbnet_ec2_1a
resource "aws_route_table_association" "pvt_sbnet_ec2_1a_association" {
  subnet_id      = aws_subnet.pvt_sbnet_ec2_1a.id
  route_table_id = aws_route_table.private_route_table.id
}

# Associate private route table with private subnet 4
resource "aws_route_table_association" "pvt_sbnet_ec2_1b_association" {
  subnet_id      = aws_subnet.pvt_sbnet_ec2_1b.id
  route_table_id = aws_route_table.private_route_table.id
}

# Associate private route table with pvt_sbnet_rds_1a
resource "aws_route_table_association" "pvt_sbnet_rds_1a_association" {
  subnet_id      = aws_subnet.pvt_sbnet_rds_1a.id
  route_table_id = aws_route_table.private_route_table.id
}

# Associate private route table with pvt_sbnet_rds_1b
resource "aws_route_table_association" "pvt_sbnet_rds_1b_association" {
  subnet_id      = aws_subnet.pvt_sbnet_rds_1b.id
  route_table_id = aws_route_table.private_route_table.id
}

# Network Address Translation for Public Subnet
# NAT Gateway
resource "aws_nat_gateway" "nat_gateway" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.pub_sbnet_nat_1a.id

  tags = {
    Name = "AirborneNATGateway"
  }
}

# Elastic IP address for NAT Gatway
# EIP for the NAT Gateway
resource "aws_eip" "nat_eip" {
  vpc = true
  tags = {
    Name = "AirborneNATGatewayEIP"
  }
}

# Route in the private route table for the NAT Gateway
resource "aws_route" "private_route" {
  route_table_id         = aws_route_table.private_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat_gateway.id
}

# Route in the private route table for the RDS subnets
resource "aws_route" "private_to_rds_route1" {
  route_table_id         = aws_route_table.private_route_table.id
  destination_cidr_block = aws_subnet.subnet5.cidr_block
  nat_gateway_id         = aws_nat_gateway.nat_gateway.id
}

# Route in the private route table for the RDS subnets
resource "aws_route" "private_to_rds_route2" {
  route_table_id         = aws_route_table.private_route_table.id
  destination_cidr_block = aws_subnet.subnet6.cidr_block
  nat_gateway_id         = aws_nat_gateway.nat_gateway.id
}

# Route in the private route table for the RDS subnets
resource "aws_vpc_endpoint" "ssm" {
  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.us-east-1.ssm"
  vpc_endpoint_type = "Interface"
}

resource "aws_vpc_endpoint" "ssmmessages" {
  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.us-east-1.ssmmessages"
  vpc_endpoint_type = "Interface"
}

resource "aws_vpc_endpoint" "ec2" {
  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.us-east-1.ec2"
  vpc_endpoint_type = "Interface"
}

resource "aws_vpc_endpoint" "ec2messages" {
  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.us-east-1.ec2messages"
  vpc_endpoint_type = "Interface"
}