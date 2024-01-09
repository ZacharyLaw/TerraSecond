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
resource "aws_security_group" "web_server" {
  name = "server_name"
  ingress {
    protocol    = "tcp"
    from_port   = 22
    to_port     = 22
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol    = -1
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}
resource "aws_instance" "ubuntu" {
  ami                    = "ami-0c7217cdde317cfec"
  instance_type          = "t2.micro"
  tags                   = { Name = "[Zachary] Terraform user_data" }
  vpc_security_group_ids = [aws_security_group.web_server.id]
  associate_public_ip_address = true
  user_data = <<-EOF
    #!/bin/bash
    sudo apt update -y
    sudo apt install apache2 -y
    
    sudo shutdown +30 
    #30min
  EOF
  lifecycle {
  create_before_destroy = true
  ignore_changes = [tags, instance_type, key_name]
  prevent_destroy = false
  }
}
resource "aws_key_pair" "deployer" {
  key_name   = "ssh_key_name"
  public_key = file("C:/Users/zacharylaw/Desktop/ZacharyPep_SSH")
}
resource "aws_ec2_instance_state" "ubuntu" {
  instance_id = aws_instance.ubuntu.id
  state       = "running"#stopped running
}
output "instance_private_ip" {value = aws_instance.ubuntu.private_ip}
output "instance_public_ip" {value = aws_instance.ubuntu.public_ip}

