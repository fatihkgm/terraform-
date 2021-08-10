terraform {
 required_providers {
     aws = {
         source = "hashicorp/aws"
         version = "~>3.0"
     }
 }
}

# Configure the AWS provider

provider "aws" {
    region = "us-east-1"
}

# Create a VPC

resource "aws_vpc" "Pyramid-VPC"{
    cidr_block = var.cidr_block[0]

    tags = {
        Name = "Pyramid-VPC"
    }

}

resource "aws_subnet" "Pyramid-Subnet1"{
    vpc_id = aws_vpc.Pyramid-VPC.id
    cidr_block = var.cidr_block[1]

    tags = {
        Name = "Pyramid-Subnet1"
    }
}

resource "aws_internet_gateway" "Pyramid-IntGateway"{

    vpc_id = aws_vpc.Pyramid-VPC.id
    tags = {
        Name = "Pyramid-IntGateWay"
    }
}

resource "aws_security_group" "Pyramid_Sec_Group"{
    name= "Pyramid Scuerity Group"
    description = "Inbound and outboud traffic"
    vpc_id = aws_vpc.Pyramid-VPC.id
   
    dynamic ingress {
        iterator = port
        for_each = var.ports 
         content {
            from_port = port.value
            to_port =  port.value
            protocol = "tcp"
            cidr_blocks = ["0.0.0.0/0"]

         }
        

    }

    egress {
        from_port =0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"] 
    }
    tags= {
        Name = "allow traffic"
    }


}

resource "aws_route_table" "Pyramid_Routeable"{
    
    vpc_id = aws_vpc.Pyramid-VPC.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.Pyramid-IntGateway.id
    }

    tags = {
        Name = "Pyramid_RouteTable"
    }
}

resource "aws_route_table_association" "Pyramid_Assn"{
    subnet_id = aws_subnet.Pyramid-Subnet1.id
    route_table_id = aws_route_table.Pyramid_Routeable.id

}


#Jenkins 
resource "aws_instance" "Jenkins-Ec2" {
  ami           = var.ami
  instance_type = var.instance_type
  key_name = "devops-key"
  vpc_security_group_ids = [aws_security_group.Pyramid_Sec_Group.id]
  subnet_id = aws_subnet.Pyramid-Subnet1.id
  associate_public_ip_address = true
  user_data = file("./JenkinsInstallation.sh")

  tags = {
    Name = "Jenkins-EC2"
  }
}

#Ansible
resource "aws_instance" "AnsibleController" {
  ami           = var.ami
  instance_type = var.instance_type
  key_name = "devops-key"
  vpc_security_group_ids = [aws_security_group.Pyramid_Sec_Group.id]
  subnet_id = aws_subnet.Pyramid-Subnet1.id
  associate_public_ip_address = true
  user_data = file("./ansible-installation.sh")

  tags = {
    Name = "Ansible-EC2"
  }
}

# EC2 instance for Ansible - Manage  Node1 tpo host Apache Tomcat server

resource "aws_instance" "AnsibleManageNode1" {
  ami           = var.ami
  instance_type = var.instance_type
  key_name = "devops-key"
  vpc_security_group_ids = [aws_security_group.Pyramid_Sec_Group.id]
  subnet_id = aws_subnet.Pyramid-Subnet1.id
  associate_public_ip_address = true
  user_data = file("./AnsibleTomcat.sh")

  tags = {
    Name = "Ansible-ApacheTomcat"
  }
}

#Docker -Ansible Node2

resource "aws_instance" "DockerHost" {
  ami           = var.ami
  instance_type = var.instance_type
  key_name = "devops-key"
  vpc_security_group_ids = [aws_security_group.Pyramid_Sec_Group.id]
  subnet_id = aws_subnet.Pyramid-Subnet1.id
  associate_public_ip_address = true
  user_data = file("./docker-installation.sh")

  tags = {
    Name = "DockerHost"
  }
}

#Sonatype Nexus -EC2 
resource "aws_instance" "Nexus" {
  ami           = var.ami
  instance_type = var.instance_type_nexus
  key_name = "devops-key"
  vpc_security_group_ids = [aws_security_group.Pyramid_Sec_Group.id]
  subnet_id = aws_subnet.Pyramid-Subnet1.id
  associate_public_ip_address = true
  user_data = file("./nexus-installation.sh")

  tags = {
    Name = "Nexus-Host"
  }
}
