terraform {
  cloud {
    organization = "zac-aws"
    workspaces {name = "learn-terraform-cloud"}
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.31.0"
    }
  }
  required_version = "~> 1.6.6"
}
provider "aws"{
  region  = "us-east-1" //N. Virgina
}
resource "aws_vpc" "my_vpc" {
  enable_dns_hostnames = true
  cidr_block = "10.100.100.0/16"
  tags = {Name = "[Zachary] Terraform 10.100/16"}
}
resource "aws_subnet" "my_subnet" {
  vpc_id     = aws_vpc.my_vpc.id
  cidr_block = "10.100.100.0/24"
  tags       = { Name = "[Zachary] Terraform Subnet" }
}
resource "aws_network_interface" "aws_network_interface-1fd5b0a9" {
  subnet_id = aws_subnet.my_subnet.id
  private_ips = ["10.100.100.100",]
}
resource "aws_instance" "ubuntu" {
  ami                    = "ami-0c7217cdde317cfec"
  instance_type          = "t2.micro"
  tags                   = { Name = "[Zachary] Terraform user_data" }
  #vpc_security_group_ids = [aws_security_group.my_sg.id]
  subnet_id              = aws_subnet.my_subnet.id
  associate_public_ip_address = true
  user_data = <<-EOF
    #!/bin/bash
    yum update -y
    service httpd start
    chkconfig httpd on

    sudo shutdown +30 
    #30min
  EOF
  lifecycle {
  create_before_destroy = true
  ignore_changes = [tags, instance_type, key_name]
  prevent_destroy = false
}
}
resource "aws_ec2_instance_state" "ubuntu" {
  instance_id = aws_instance.ubuntu.id
  state       = "running"#stopped running
}
output "instance_private_ip" {value = aws_instance.ubuntu.private_ip}
output "instance_public_ip" {value = aws_instance.ubuntu.public_ip}

