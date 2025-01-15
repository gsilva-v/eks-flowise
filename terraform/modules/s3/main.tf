# modules/s3/main.tf
resource "aws_s3_bucket" "this" {
  bucket = var.bucket_name
  versioning {
    enabled = true
  }
  lifecycle {
    prevent_destroy = true
  }

  tags = {
    Name = "Flowise-Models-Bucket"
  }
}

output "bucket_name" {
  value = aws_s3_bucket.this.bucket
}
