provider "aws" {
  region     = "ap-northeast-2"
  access_key = ""
  secret_key = ""
}

# 1. create VPC
#   - Associate VPC w/ Internet GW : 자동적으로 attach됨
resource "aws_vpc" "main" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "tf-vpc-prod-hansol01"
  }
}

# 2. create Internet GW

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "tf-igw-prod"
  }
}

# 3. Create Custom Route Table
resource "aws_route_table" "route-table" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "tf-rt-prod"
  }
}

# 4. Create Subnet

# variable "subnet-prefix" {
#   description = "cidr block for subnet"
# }

resource "aws_subnet" "subnet-1" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.1.0/24"
  # cidr_block = var.subnet-prefix
  availability_zone = "ap-northeast-2a"

  tags = {
    Name = "tf-subnet-prod"
  }
}

# #############################
# resource "aws_subnet" "subnet-1" {
#   vpc_id     = aws_vpc.main.id
#   cidr_block = var.subnet-prefix[0].cidr_block
#   # cidr_block = var.subnet-prefix
#   availability_zone = "ap-northeast-2a"

#   tags = {
#     Name = var.subnet-prefix[0].name
#   }
# }

# resource "aws_subnet" "subnet-2" {
#   vpc_id     = aws_vpc.main.id
#   cidr_block = var.subnet-prefix[1].cidr_block
#   # cidr_block = var.subnet-prefix
#   # availability_zone = "us-east-1a"
#   availability_zone = "ap-northeast-2a"
#   tags = {
#     Name = var.subnet-prefix[1].name
#   }
# }

# #############################


# 5. Associate Subnet with Route Table
resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.subnet-1.id
  route_table_id = aws_route_table.route-table.id
}


# 6. Create Security Group to allow port 22, 80, 443

resource "aws_security_group" "allow_web" {
  name        = "allow_web_changed"
  description = "Allow web inbound traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "HTTPS from VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP from VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # ingress {
  #   description = "SSH from VPC"
  #   from_port   = 22
  #   to_port     = 22
  #   protocol    = "tcp"
  #   cidr_blocks = ["0.0.0.0/0"]
  # }

  # ingress {
  #   description = "HTTP from VPC"
  #   from_port   = 8080
  #   to_port     = 8080
  #   protocol    = "tcp"
  #   cidr_blocks = ["0.0.0.0/0"]
  # }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_web"
  }
}

# 7. create network interface w/ an ip in ther subnet 4 that was create step 4
resource "aws_network_interface" "web-server-nic" {
  subnet_id       = aws_subnet.subnet-1.id
  private_ips     = ["10.0.1.50"]
  security_groups = [aws_security_group.allow_web.id]

}
# 8. Assgn Elastic IP to the network interface in step 7
resource "aws_eip" "one" {
  vpc                       = true
  network_interface         = aws_network_interface.web-server-nic.id
  associate_with_private_ip = "10.0.1.50"
  depends_on                = [aws_internet_gateway.gw]
}

output "public_server_ip" {
  value = aws_eip.one.public_ip
}

# 9. create Ubuntu server and install/enable apache2

# resource "aws_instance" "web-server" {
#   ami = "ami-081511b9e3af53902"
#   # ami = "ami-04d29b6f966df1537"
#   instance_type     = "t2.micro"
#   availability_zone = "ap-northeast-2a"
#   # key_name          = "hippo-key"

#   network_interface {
#     device_index         = 0
#     network_interface_id = aws_network_interface.web-server-nic.id
#   }
# }


# user_data = <<-EOF
#             #!/bin/bash
#             sudo apt update -y
#             sudo apt install apache2 -y
#             sudo systemctl start apache2
#             sudo bash -c 'echo your first web server > /var/www/html/index.html'
#             EOF

# user_data = <<-EOF
#             #!/bin/bash
#             sudo yum update -y
#             sudo yum install apache2 -y
#             sudo service apache2 start
#             sudo bash -c 'echo your first web server > /var/www/html/index.html'
#             EOF

# commnet 처리
# user_data = <<-EOF
#             #!/bin/bash
#             echo 'Hello world' > index.html
#             nohup busybox httpd -f -p 8080 &
#             EOF

#   tags = {
#     Name = "tf-example-ec2"
#   }
# }
# commnet 처리

# resource "aws_instance" "example" {
#   # ami           = "ami-04d29b6f966df1537"
#   ami           = "ami-0b827f3319f7447c6"
#   instance_type = "t2.micro"

#   tags = {
#     Name = "terraform-example"
#   }
# }