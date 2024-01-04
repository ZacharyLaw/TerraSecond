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
variable "instance_type" {default = "t2.micro"}
variable "instance_name" {default = "[Zachary] Terraform Wordpress"}
provider "aws"{
  region  = "us-east-1"
  #shared_credentials_files = ["/Users/tf_user/.aws/creds"]
  #profile                  = "default"
}
data "aws_ami" "ubuntu" {
  most_recent = true
  filter {
    name   = "name"
    values = ["(SupportedImages) - Wordpress - Ubuntu 20*"]
  }
}
resource "aws_vpc" "zachary-terraform" {
  cidr_block = "10.0.0.0/16"
    tags = {Name = "[Zachary] Terraform 10.0/16"}
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

output "instance_ami" {value = aws_instance.ubuntu.ami}
output "instance_arn" {value = aws_instance.ubuntu.arn}
output "instance_private_ip" {value = aws_instance.ubuntu.private_ip}
output "instance_public_ip" {value = aws_instance.ubuntu.public_ip}

