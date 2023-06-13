// RDS subnet group
resource "aws_db_subnet_group" "groom_rds_subnet_group" {
  name       = "rds_subnet_group"
  subnet_ids = module.vpc.private_subnets

  tags = {
    Name = "rds_subnet_group"
  }
}

// RDS Security group
resource "aws_security_group" "groom_rds_security_group" {
  name   = "rds_security_group"
  vpc_id = module.vpc.vpc_id

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "rds_security_group"
  }
}

//DB parameter group
resource "aws_db_parameter_group" "groom_db_parameter_group" {
  name   = "dbparametergroup"
  family = "mariadb10.6"

  # parameter {
  #   name  = "log_connections"
  #   value = "1"
  # }
}

//RDS Instance

resource "aws_db_instance" "groom_rds" {
  
  identifier             = "groomrds"
  db_name                = "groomdb" #초기데이터베이스
  instance_class         = "db.t2.micro"
  allocated_storage      = 20
  storage_type           = "gp2"
#   name                   = "groomdb"
  engine                 = "mariadb"
  engine_version         = "10.6.12"
  username               = "root"
  password               = var.db_password
  db_subnet_group_name   = aws_db_subnet_group.groom_rds_subnet_group.name
  vpc_security_group_ids = [aws_security_group.groom_rds_security_group.id]
  parameter_group_name   = aws_db_parameter_group.groom_db_parameter_group.name
  publicly_accessible    = true
  skip_final_snapshot    = true
}
