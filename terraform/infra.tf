# Add your VPC ID to default below
variable "vpc_id" {
  description = "VPC ID for usage throughout the build process"
  default = "vpc-fd918099"
}

provider "aws" {
  region = "us-west-2"
}

#internet gateway
resource "aws_internet_gateway" "gw" {
  vpc_id = "${var.vpc_id}"

  tags = {
    Name = "default_ig"
  }
}

#elastic ip for nat gateway
resource "aws_eip" "ng" {
  vpc      = true
}

#nat gateway
resource "aws_nat_gateway" "natgw" {
    allocation_id = "${aws_eip.ng.id}"
    subnet_id = "${aws_subnet.private_subnet_a.id}"
}

#public route table
resource "aws_route_table" "public_routing_table" {
  vpc_id = "${var.vpc_id}"
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.gw.id}"
  }

  tags {
    Name = "public_routing_table"
  }
}

#private route table
resource "aws_route_table" "private_routing_table" {
  vpc_id = "${var.vpc_id}"
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_nat_gateway.natgw.id}"
  }

  tags {
    Name = "private_routing_table"
  }
}

#public subneta
resource "aws_subnet" "public_subnet_a" {
    vpc_id = "${var.vpc_id}"
    cidr_block = "172.31.0.0/24"
    availability_zone = "us-west-2a"

    tags {
        Name = "public_a"
    }
}

#public subnetb
resource "aws_subnet" "public_subnet_b" {
    vpc_id = "${var.vpc_id}"
    cidr_block = "172.31.1.0/24"
    availability_zone = "us-west-2b"

    tags {
        Name = "public_b"
    }
}

#public subnetc
resource "aws_subnet" "public_subnet_c" {
    vpc_id = "${var.vpc_id}"
    cidr_block = "172.31.2.0/24"
    availability_zone = "us-west-2c"

    tags {
        Name = "public_c"
    }
}

#private subneta
resource "aws_subnet" "private_subnet_a" {
    vpc_id = "${var.vpc_id}"
    cidr_block = "172.31.4.0/22"
    availability_zone = "us-west-2a"

    tags {
        Name = "private_a"
    }
}

#private subnetb
resource "aws_subnet" "private_subnet_b" {
    vpc_id = "${var.vpc_id}"
    cidr_block = "172.31.8.0/22"
    availability_zone = "us-west-2b"

    tags {
        Name = "private_b"
    }
}

#private subnetc
resource "aws_subnet" "private_subnet_c" {
    vpc_id = "${var.vpc_id}"
    cidr_block = "172.31.12.0/22"
    availability_zone = "us-west-2c"

    tags {
        Name = "private_c"
    }
}

#associate public subneta with public route table
resource "aws_route_table_association" "public_subnet_a_rt_assoc" {
    subnet_id = "${aws_subnet.public_subnet_a.id}"
    route_table_id = "${aws_route_table.public_routing_table.id}"
}

#associate public subnetb with public route table
resource "aws_route_table_association" "public_subnet_b_rt_assoc" {
    subnet_id = "${aws_subnet.public_subnet_b.id}"
    route_table_id = "${aws_route_table.public_routing_table.id}"
}

#associate public subnetc with public route table
resource "aws_route_table_association" "public_subnet_c_rt_assoc" {
    subnet_id = "${aws_subnet.public_subnet_c.id}"
    route_table_id = "${aws_route_table.public_routing_table.id}"
}

#associate private subneta with public route table
resource "aws_route_table_association" "private_subnet_a_rt_assoc" {
    subnet_id = "${aws_subnet.private_subnet_a.id}"
    route_table_id = "${aws_route_table.private_routing_table.id}"
}

#associate private subnetb with public route table
resource "aws_route_table_association" "private_subnet_b_rt_assoc" {
    subnet_id = "${aws_subnet.private_subnet_b.id}"
    route_table_id = "${aws_route_table.private_routing_table.id}"
}

#associate private subnetc with public route table
resource "aws_route_table_association" "private_subnet_c_rt_assoc" {
    subnet_id = "${aws_subnet.private_subnet_c.id}"
    route_table_id = "${aws_route_table.private_routing_table.id}"
}

#security group to allow access
resource "aws_security_group" "myip" {
  name = "allowmyip"
  description = "only my ip"

  ingress {
      from_port = 22
      to_port = 22
      protocol = "tcp"
      cidr_blocks = ["76.174.19.212/29"]
  }
}
	
#bastion instance
resource "aws_instance" "bastion" {
    ami = "ami-c4469aa4"
    instance_type = "t2.micro"
    subnet_id = "${aws_subnet.public_subnet_c.id}"
	associate_public_ip_address = true
	vpc_security_group_ids = ["${aws_security_group.myip.id}"]
	key_name = "cit360"
}