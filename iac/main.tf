# Set the AWS provider credentials
provider "aws" {
  region     = "us-east-1" # Change to your desired region
  access_key = "your_access_key"
  secret_key = "your_secret_key"
}

# Create an RDS instance
resource "aws_db_instance" "example" {
  allocated_storage    = 20
  storage_type         = "gp2"
  engine               = "postgres"
  engine_version       = "12.5"
  instance_class       = "db.t2.micro"
  name                 = "mydb"
  username             = "db_user"
  password             = "db_password"
  parameter_group_name = "default.postgres12"

  # Enable automatic backups
  skip_final_snapshot = true

  tags = {
    Name = "MyDatabase"
  }
}

# Create a security group for RDS instance
resource "aws_security_group" "rds_sg" {
  name        = "rds_security_group"
  description = "Allow incoming database connections"
}

# Allow incoming database connections on the default port (5432)
resource "aws_security_group_rule" "rds_ingress" {
  type        = "ingress"
  from_port   = 5432
  to_port     = 5432
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"] # You may restrict this to specific IP ranges
  security_group_id = aws_security_group.rds_sg.id
}

# Create an IAM role for your API
resource "aws_iam_role" "api_role" {
  name = "api_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "apigateway.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

# Attach a policy to the IAM role to access RDS
resource "aws_iam_policy_attachment" "api_rds_access" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonRDSFullAccess" # Or create a custom policy
  name       = "api_rds_access"
  roles      = [aws_iam_role.api_role.name]
}
