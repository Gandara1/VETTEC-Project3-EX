variable "instance_type" {
  description = "Type for the EC2 instance"
  type        = string
}

variable "vpc_cidr_block" {
  description = "CIDR block for the VPC"
  type        = string
}
variable "availability_zones" {
    description = "Us east AVZ"
  type    = list(string)
  
}

variable "eks_subnet_count" {
    description = "subnet count for eks subnets"
    type = number
}

variable "private_subnet_count" {
    description = "subnet count for private subnets"
    type = number
}