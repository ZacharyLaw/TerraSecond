terraform {
  cloud {
    organization = "zac-aws"
    workspaces {name = "self-made"}
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.31.0"
    }
  }
  //required_version = "~> 1.2"
}
variable "instance_type" {default = "t2.nano"}
variable "instance_name" {default = "[Zachary] Terraform"}
provider "aws"{
  region  = "us-east-1"
  //shared_credentials_files = ["/Users/tf_user/.aws/creds"]
  //profile                  = "default"
}
data "aws_ami" "ubuntu" {
  most_recent = true
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["099720109477"] # Canonical
}
resource "aws_vpc" "zachary-terraform" {
  cidr_block = "10.0.0.0/16"
}
resource "aws_instance" "ubuntu" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_type
  tags          = {Name = var.instance_name}
}
resource "aws_ec2_instance_state" "ubuntu" {
  instance_id = aws_instance.ubuntu.id
  state       = "stopped"
}
resource "aws_instance_state" "ubuntu" {
  instance_id = aws_instance.ubuntu.id
  state       = "stopped"
}
output "instance_ami" {value = aws_instance.ubuntu.ami}
output "instance_arn" {value = aws_instance.ubuntu.arn}