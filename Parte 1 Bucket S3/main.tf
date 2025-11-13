# 1. Crear el bucket S3 para hosting
resource "aws_s3_bucket" "static_website" {
  bucket = "diegos3terraformfinal"

  tags = {
    Name        = "BucketWeb"
  }
}

# 2. Desactivar bloqueos de acceso público
resource "aws_s3_bucket_public_access_block" "static_website" {
  bucket                  = aws_s3_bucket.static_website.id
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

# 3. Política pública para permitir lectura de objetos
resource "aws_s3_bucket_policy" "static_website_policy" {
  bucket = aws_s3_bucket.static_website.id

  depends_on = [
    aws_s3_bucket_public_access_block.static_website
  ]

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicReadGetObject"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.static_website.arn}/*"
      }
    ]
  })
}

# 4. Crear archivos HTML localmente para subir
resource "local_file" "index_html" {
  content  = "<h1>Practica realizada por Diego Guadalupe</h1>"
  filename = "${path.module}/index.html"
}

resource "local_file" "error_html" {
  content  = "<h1>Error 404 - Página no encontrada</h1>"
  filename = "${path.module}/error.html"
}

# 5. Subir los archivos al bucket vía Terraform
resource "aws_s3_object" "index_html" {
  bucket = aws_s3_bucket.static_website.id
  key    = "index.html"
  source = local_file.index_html.filename
  content_type = "text/html"
}

resource "aws_s3_object" "error_html" {
  bucket = aws_s3_bucket.static_website.id
  key    = "error.html"
  source = local_file.error_html.filename
  content_type = "text/html"
}

# 6. Configuración de Hosting de Sitio Web Estático
resource "aws_s3_bucket_website_configuration" "static_website_config" {
  bucket = aws_s3_bucket.static_website.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}

# 7. Output del endpoint del sitio web (CORREGIDO)
output "website_endpoint" {
  description = "URL del S3 static website"
  # ¡Este es el atributo correcto!
  value = aws_s3_bucket_website_configuration.static_website_config.website_endpoint
}