# VPC
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  tags = { 
    Name = "DiegoVPC"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags = { 
    Name = "DiegoIGW" 
  }
}

# Subred pública
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-west-2a"
  map_public_ip_on_launch = true
  tags = { 
    Name = "DiegoRedPublica"
  }
}

# Subred privada
resource "aws_subnet" "private" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-west-2b"
  tags = { 
    Name = "DiegoRedPrivada" 
  }
}

# Route table pública
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = { 
    Name = "DiegoRTPublica" 
  }
}

# Asociar la route table pública
resource "aws_route_table_association" "public_assoc" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

resource "aws_security_group" "web_sg" {
  name        = "DiegoSGEC2"
  description = "Allow HTTP, HTTPS, SSH"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
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

resource "aws_security_group" "db_sg" {
  name        = "DiegoSGbbdd"
  description = "Allow MySQL from webserver"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # opcional SSH
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Generar par de claves RSA con Terraform
resource "tls_private_key" "diego_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Subir la clave pública a AWS
resource "aws_key_pair" "diego_key" {
  key_name   = "DiegoKey"
  public_key = tls_private_key.diego_key.public_key_openssh
}

# Guardar la clave privada localmente
resource "local_file" "private_pem" {
  content  = tls_private_key.diego_key.private_key_pem
  filename = "${path.module}/../Ansible/DiegoKey.pem"
}

# Webserver en subred pública
resource "aws_instance" "web" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.web_sg.id]
  key_name               = aws_key_pair.diego_key.key_name

  tags = {
    Name = "DiegoEC2Web"
    role = "web"
  }
}

# Database en subred privada
resource "aws_instance" "db" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.db_sg.id]
  key_name               = aws_key_pair.diego_key.key_name

  tags = {
    Name = "DiegoEC2bbdd"
    role = "db"
  }
}