# networking.tf | Network Configuration

data "aws_subnets" "public" {
  filter {
    name = "vpc-id"
    values = [
      data.aws_vpc.aws-vpc.id
    ]
  }

  filter {
    name = "map-public-ip-on-launch"
    values = [true]
  }
}

data "aws_subnet" "public" {
  for_each = toset(data.aws_subnets.public.ids)
  id       = each.value
}
