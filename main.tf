provider "aws" {
  region  = "us-east-1"   # ajuste conforme necessário
}

# VPC Configuration (if needed)
resource "aws_vpc" "rds_vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "rds_vpc"
  }
}

resource "aws_subnet" "public_subnet" {
  vpc_id            = aws_vpc.rds_vpc.id
  cidr_block        = "10.0.1.0/24"

  tags = {
    Name = "public_subnet"
  }
}

# Security group to allow access to RDS
resource "aws_security_group" "rds_security_group" {
  vpc_id = aws_vpc.rds_vpc.id
  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # permite acesso de qualquer IP. Ajuste conforme necessário.
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "rds_security_group"
  }
}

# Create the RDS instance
resource "aws_db_instance" "rds_mysql" {
  allocated_storage      = 20
  engine                 = "mysql"
  engine_version         = "8.0"
  instance_class         = "db.t3.micro" # ajuste conforme necessário
  db_name                = "mydb"
  username               = "admin"
  password               = "password123" # altere para uma senha segura
  parameter_group_name   = "default.mysql8.0"
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  skip_final_snapshot    = true
  publicly_accessible    = true

  tags = {
    Name = "my-rds-instance"
  }
}

resource "aws_security_group" "rds_sg" {
  name        = "rds_sg"
  description = "Allow inbound MySQL traffic"

  ingress {
    description = "MySQL from anywhere"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Output for database endpoint
output "db_endpoint" {
  value = aws_db_instance.rds_mysql.endpoint
}