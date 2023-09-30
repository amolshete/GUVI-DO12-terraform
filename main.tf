terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "ap-south-1"
}


##aws ec2 instance

# resource "aws_instance" "web" {
#   ami           = "ami-067c21fb1979f0b27"
#   instance_type = "t2.medium"
#   key_name = "linux-os-key"
  

#   tags = {
#     Name = "Machine from terraform - 2"
#   }
# }


# resource "aws_eip" "test-eip" {
#   instance = aws_instance.web.id
#   domain   = "vpc"
# }

#aws vpc

resource "aws_vpc" "card-website-vpc" {
  cidr_block       = "10.10.0.0/16"

  tags = {
    Name = "Card-website-vpc"
  }
}


#subnet creation

resource "aws_subnet" "card-website-subnet-1a" {
  vpc_id     = aws_vpc.card-website-vpc.id
  cidr_block = "10.10.0.0/24"
  availability_zone = "ap-south-1a"
  map_public_ip_on_launch = "true"

  tags = {
    Name = "Card-website-subnet-1a"
  }
}


resource "aws_subnet" "card-website-subnet-1b" {
  vpc_id     = aws_vpc.card-website-vpc.id
  cidr_block = "10.10.1.0/24"
  availability_zone = "ap-south-1b"
  map_public_ip_on_launch = "true"

  tags = {
    Name = "Card-website-subnet-1b"
  }
}


resource "aws_subnet" "card-website-subnet-1c" {
  vpc_id     = aws_vpc.card-website-vpc.id
  cidr_block = "10.10.2.0/24"
  availability_zone = "ap-south-1c"

  tags = {
    Name = "Card-website-subnet-1c"
  }
}

#instance creation

resource "aws_instance" "card-website-instance" {
  ami           = "ami-0f5ee92e2d63afc18"
  instance_type = "t2.micro"
  subnet_id = aws_subnet.card-website-subnet-1a.id
  key_name = aws_key_pair.card-website-instance-key.id
  associate_public_ip_address = "true"
  vpc_security_group_ids = [aws_security_group.allow_ssh.id]

  tags = {
    Name = "card-wesbsite-instance-01"
  }
}

resource "aws_key_pair" "card-website-instance-key" {
  key_name   = "card-website-instance-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDbAqcyWgsuOhUt4zGVZMssdKkItijmwW1/NC6D5A/XQugSzPNVQhlkBIjUqs57J1JAkpfwou+3rNqkW2hjNumeXQwSSH0Jp9B8efkOo066Ek/O65jkpR5udyFqksD3vLOZoc3kSDAOdYkPHEIuHVdvjXbV8Gdju39ShOdpSaag15Jt4SX0q3LG1cl82av7Is0QTmb1yqiRqNfTVrbP1xEjzbVwz0R7kSUkoAuKN7NJMja/rAVBA/EE1kz1rDJfrBHVMSqRAHTkhviNbSXr+i4e0+BNhbZNAQ1Ax2yjNp9Rqgzgayr6XhreJWXzcIUTBxhc0zYPaALkPN7K3BTHfUJSZPjXEf0pbAfSyVATIUmx2TNlG87YqvEnymeKSzMmutICeJFS7UVucTEHZeTrQRb96c+THn+YTrbgbmlQ36SgaRToxCIdG2EeUaB1JJYfrCaOHTj5EqmzyIzXQZL99/47j7Bkf38i7d5w3x+NUUUyAVG/FGUAlbeomo89W/AJmTk= Amol@DESKTOP-2MVQBON"
}

resource "aws_instance" "card-website-instance-2" {
  ami           = "ami-0f5ee92e2d63afc18"
  instance_type = "t2.micro"
  subnet_id = aws_subnet.card-website-subnet-1b.id
  key_name = aws_key_pair.card-website-instance-key.id
  associate_public_ip_address = "true"
  vpc_security_group_ids = [aws_security_group.allow_ssh.id]

  tags = {
    Name = "card-wesbsite-instance-02"
  }
}

# Internet GW

resource "aws_internet_gateway" "card-website-vpc-IG" {
  vpc_id = aws_vpc.card-website-vpc.id

  tags = {
    Name = "card-website-vpc-IG"
  }
}

# Public RT

resource "aws_route_table" "card-WB-RT-public" {
  vpc_id = aws_vpc.card-website-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.card-website-vpc-IG.id
  }


  tags = {
    Name = "card-WB-RT-public"
  }
}

# Private RT

resource "aws_route_table" "card-WB-RT-private" {
  vpc_id = aws_vpc.card-website-vpc.id


  tags = {
    Name = "card-WB-RT-private"
  }
}

#assoiate RT with subnets

resource "aws_route_table_association" "card-WB-RT-association-1a" {
  subnet_id      = aws_subnet.card-website-subnet-1a.id
  route_table_id = aws_route_table.card-WB-RT-public.id
}


resource "aws_route_table_association" "card-WB-RT-association-1b" {
  subnet_id      = aws_subnet.card-website-subnet-1b.id
  route_table_id = aws_route_table.card-WB-RT-public.id
}


resource "aws_route_table_association" "card-WB-RT-association-1c" {
  subnet_id      = aws_subnet.card-website-subnet-1c.id
  route_table_id = aws_route_table.card-WB-RT-private.id
}

#creation of SG

resource "aws_security_group" "allow_ssh" {
  name        = "allow_ssh"
  description = "Allow ssh inbound traffic"
  vpc_id      = aws_vpc.card-website-vpc.id

  ingress {
    description      = "SSH from anywhere"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  ingress {
    description      = "HTTP from anywhere"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_ssh"
  }
}

# Launch template

resource "aws_launch_template" "card-website-LT" {
    image_id = "ami-0f5ee92e2d63afc18"
    key_name = aws_key_pair.card-website-instance-key.id
    vpc_security_group_ids = [aws_security_group.allow_ssh.id]
    instance_type = "t2.micro"
    user_data = filebase64("userdata.sh")

    tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "card-website-via-asg"
    }
  }

}

# ASG

resource "aws_autoscaling_group" "card-website-asg" {
  
  vpc_zone_identifier = [aws_subnet.card-website-subnet-1a.id, aws_subnet.card-website-subnet-1b.id]
  desired_capacity   = 2
  max_size           = 5
  min_size           = 2

  launch_template {
    id      = aws_launch_template.card-website-LT.id
    version = "$Latest"
  }
}