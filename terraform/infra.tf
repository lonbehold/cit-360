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
  
  egress {
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = ["0.0.0.0/0"]
  }
}

#security group for vpc access to DB
resource "aws_security_group" "rds" {
  name = "sgforrds"

  ingress {
      from_port = 3306
      to_port = 3306
      protocol = "tcp"
      cidr_blocks = ["172.31.0.0/16"]
  }
  
  egress {
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = ["0.0.0.0/0"]
  }
}

#security group for the 2 instances
resource "aws_security_group" "for2in" {
  name = "sgforwebservers"

  ingress {
      from_port = 80
      to_port = 80
      protocol = "tcp"
      cidr_blocks = ["172.31.0.0/16"]
  }
  ingress {
      from_port = 22
      to_port = 22
      protocol = "tcp"
      cidr_blocks = ["172.31.0.0/16"]
  }
  
  egress {
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = ["0.0.0.0/0"]
  }
}

#security group for the elb
resource "aws_security_group" "forelb" {
  name = "sgforelb"

  ingress {
      from_port = 80
      to_port = 80
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
  }
  
  egress {
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = ["0.0.0.0/0"]
  }
}
	
#bastion instance
resource "aws_instance" "bastion" {
    ami = "ami-c4469aa4"
    instance_type = "t2.micro"
    subnet_id = "${aws_subnet.public_subnet_a.id}"
	associate_public_ip_address = true
	vpc_security_group_ids = ["${aws_security_group.myip.id}"]
	key_name = "cit360"
	
	tags{
		Name = "bastioni"
	}
}

#subnet group to reference private_a and private_b
resource "aws_db_subnet_group" "privateab" {
    name = "main"
    subnet_ids = ["${aws_subnet.private_subnet_a.id}", "${aws_subnet.private_subnet_b.id}"]
    
	tags {
        Name = "My DB subnet group"
    }
}

#rds instance
resource "aws_db_instance" "mariadbi" {
  allocated_storage    = 5
  engine               = "mariadb"
  engine_version       = "10.0.24"
  instance_class       = "db.t2.micro"
  name                 = "mydb"
  identifier           = "rdsiofmariadb"
  username             = "foo"
  password             = "${var.password}"
  db_subnet_group_name = "${aws_db_subnet_group.privateab.id}"
  vpc_security_group_ids = ["${aws_security_group.rds.id}"]
  multi_az = false
}

#Create a new elastic load balancer
resource "aws_elb" "bar" {
  name = "elb"
  subnets = ["${aws_subnet.public_subnet_b.id}", "${aws_subnet.public_subnet_c.id}"]

  listener {
    instance_port = 80
    instance_protocol = "http"
    lb_port = 80
    lb_protocol = "http"
  }

  health_check {
    healthy_threshold = 2
    unhealthy_threshold = 2
    timeout = 5
    target = "HTTP:80/"
    interval = 30
  }

  instances = ["${aws_instance.web1.id}", "${aws_instance.web2.id}"]
  connection_draining = true
  connection_draining_timeout = 60
  security_groups = ["${aws_security_group.forelb.id}"]

  tags {
    Name = "myelb"
  }
}

#web1 instance
resource "aws_instance" "web1" {
    ami = "ami-d2c924b2"
    instance_type = "t2.micro"
    subnet_id = "${aws_subnet.private_subnet_b.id}"
	vpc_security_group_ids = ["${aws_security_group.for2in.id}"]
	key_name = "cit360"
	
	tags {
		Name = "webserver-b"
		service = "cirriculum"
	}
}

#web2 instance
resource "aws_instance" "web2" {
    ami = "ami-d2c924b2"
    instance_type = "t2.micro"
    subnet_id = "${aws_subnet.private_subnet_c.id}"
	vpc_security_group_ids = ["${aws_security_group.for2in.id}"]
	key_name = "cit360"
	
	tags {
		Name = "webserver-c"
		service = "cirriculum"
	}
}