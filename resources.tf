resource "aws_vpc" "main" {
  #cidr_block = cidrsubnet("10.0.0.0/16", 4, 3)
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "Terraform-Reto"
  }
}

# Create Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "Terraform-Reto-IGW"
  }
}



# Route Table creation
resource "aws_route_table" "route-table" {
  vpc_id = aws_vpc.main.id

  route {
    //associated subnet can reach everywhere
    cidr_block = "0.0.0.0/0" //CRT uses this IGW to reach internet
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "Terraform-Reto-RouteTable"
  }
}





#Se agregan las asociaciones de redes con tablas de ruteo.
resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.public_a.id
  route_table_id = aws_route_table.route-table.id
}

resource "aws_route_table_association" "b" {
  subnet_id      = aws_subnet.public_b.id
  route_table_id = aws_route_table.route-table.id
}

resource "aws_route_table_association" "c" {
  subnet_id      = aws_subnet.public_c.id
  route_table_id = aws_route_table.route-table.id
}

# Subnet creation
resource "aws_subnet" "public_a" {
  vpc_id = aws_vpc.main.id

  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "Public-A"
  }
}

resource "aws_subnet" "public_b" {
  vpc_id = aws_vpc.main.id

  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-1b"

  tags = {
    Name = "Public-B"
  }
}

resource "aws_subnet" "public_c" {
  vpc_id = aws_vpc.main.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "us-east-1c"

  tags = {
    Name = "Public-C"
  }
}

#Elastic LoadBalancer
resource "aws_lb" "alb" {
  name               = "LoadBalancer"
  internal           = false
  load_balancer_type = "application"
  #security_groups    = [aws_security_group.lb_sg.id]
  subnet_mapping {
    subnet_id = aws_subnet.public_a.id
  }

  enable_deletion_protection = true

  tags = {
    Environment = "production"
  }
}

