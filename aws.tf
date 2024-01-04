
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
  required_version = "~> 1.2"
}
variable "instance_type" {default = "t2.nano"}
variable "instance_name" {default = "[Zachary] Terraform Wordpress"}
provider "aws"{
  region  = "us-east-1"
  #shared_credentials_files = ["/Users/tf_user/.aws/creds"]
  #profile                  = "default"
}
resource "aws_vpc" "my_vpc" {
  cidr_block = "10.0.0.0/16"
    tags = {Name = "[Zachary] Terraform 10.0/16"}

}
resource "aws_security_group" "my_sg" {
  name        = "[Zachary] Terraform SG"
  vpc_id      = aws_vpc.my_vpc.id
}
resource "aws_subnet" "my_subnet" {
  vpc_id     = aws_vpc.my_vpc.id
  cidr_block = "10.0.0.0/24"
  tags = {Name = "[Zachary] Terraform Subnet"}
}

resource "aws_instance" "ubuntu" {
  ami           = "ami-0098c6e7b556afbc2"
  instance_type = var.instance_type
  tags          = { Name = var.instance_name }
  #vpc_security_group_ids = []
  subnet_id              = ""
  vpc_security_group_ids = [aws_security_group.my_sg.id]
  #subnet_id     = aws_subnet.my_subnet.id

}

resource "aws_ec2_instance_state" "ubuntu" {
  instance_id = aws_instance.ubuntu.id
  state       = "running"#stopped
}

output "instance_ami" {value = aws_instance.ubuntu.ami}
output "instance_arn" {value = aws_instance.ubuntu.arn}
output "instance_private_ip" {value = aws_instance.ubuntu.private_ip}
output "instance_public_ip" {value = aws_instance.ubuntu.public_ip}

