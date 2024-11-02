# vpc.tf | VPC Configuration

data "aws_vpc" "aws-vpc" {
  id = var.vpc_id
}
