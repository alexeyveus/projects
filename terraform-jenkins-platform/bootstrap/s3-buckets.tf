resource "aws_s3_bucket" "s3_tf_state_storage" {
  bucket = var.state_bucket_name

  tags = {
    AppRole = "Storage"
    AppID   = "${var.jenkinsDNSName}-platform-ECS"
    Name    = "${var.jenkinsDNSName}-platform-ECS"
  }
}

#tfsec:ignore:aws-s3-encryption-customer-key
resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  bucket = aws_s3_bucket.s3_tf_state_storage.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_versioning" "versioning_state_bucket" {
  bucket = aws_s3_bucket.s3_tf_state_storage.id

  versioning_configuration {
    status = "Disabled"
  }
}

resource "aws_s3_bucket_public_access_block" "this" {
  bucket                  = aws_s3_bucket.s3_tf_state_storage.id
  
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
