variable "vpc_id" {
  type = string
}

terraform { 
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }
  required_version = ">= 1.2.0"
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_security_group" "docker_sg" {
  name_prefix = "docker_sg"
  description = "Security group for Docker containers"
  vpc_id      = var.vpc_id

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

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

  ingress {
    from_port   = 3323
    to_port     = 3323
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "docker_instance" {
  ami                    = "ami-08a0d1e16fc3f61ea" # перевірте, що цей AMI — Amazon Linux
  instance_type          = "t3.micro"
  key_name               = "keyforlab4"
  vpc_security_group_ids = [aws_security_group.docker_sg.id]

  user_data = <<-EOF
    #!/bin/bash
    sudo yum update -y
    sudo yum install -y nginx
    sudo systemctl start nginx
    sudo systemctl enable nginx
    echo "<h3>Brigada:</h3><hr><h3>Rozmetov Tymur 3<br>Parshin Mark 6<br>Sergiichuk Olexandr</h3>" | sudo tee /usr/share/nginx/html/index.html
  EOF


  tags = {
    Name = "Docker Instance"
  }
}

