
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
variable "instance_name" {default = "[Zachary] Terraform FusionHub"}
provider "aws"{
  region  = "us-east-1" //N. Virgina
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

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1" // any protocol
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_subnet" "my_subnet" {
  vpc_id     = aws_vpc.my_vpc.id
  cidr_block = "10.0.0.0/24"
  tags       = { Name = "[Zachary] Terraform Subnet" }
}

resource "aws_instance" "ubuntu" {
  tags                   = { Name = "[Zachary] Terraform fusionhub" }
  ami                    = "ami-0098c6e7b556afbc2"
  instance_type          = var.instance_type
  vpc_security_group_ids = [aws_security_group.my_sg.id]
  subnet_id              = aws_subnet.my_subnet.id
  lifecycle {
  create_before_destroy = true
  ignore_changes = [instance_type, key_name]
  prevent_destroy = false
  create_action {
  action        = "stop"
  timeout       = "1m"
  run_once      = true
  skip_destroy  = true
  }
}
}

resource "aws_instance" "example_instance" {
  ami                    = "ami-0c7217cdde317cfec"
  instance_type          = "t2.micro"
  tags                   = { Name = "[Zachary] Terraform user_data" }
  vpc_security_group_ids = [aws_security_group.my_sg.id]
  subnet_id              = aws_subnet.my_subnet.id
  associate_public_ip_address = true

  user_data = <<-EOF
    #!/bin/bash
    yum update -y
    service httpd start
    chkconfig httpd on
  EOF

  lifecycle {
  create_before_destroy = true
  ignore_changes = [instance_type, key_name]
  prevent_destroy = false
  create_action {
  action        = "stop"
  timeout       = "1m"
  run_once      = true
  skip_destroy  = true
  }
}
}

resource "aws_ec2_instance_state" "ubuntu" {
  instance_id = aws_instance.ubuntu.id
  state       = "stopped"#stopped
}

output "instance_ami" {value = aws_instance.ubuntu.ami}
output "instance_arn" {value = aws_instance.ubuntu.arn}
output "instance_private_ip" {value = aws_instance.ubuntu.private_ip}
output "instance_public_ip" {value = aws_instance.ubuntu.public_ip}

