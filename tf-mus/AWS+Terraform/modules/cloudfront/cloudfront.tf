resource "aws_s3_bucket" "cf_bucket" {
  provider      = "aws.second"
  bucket        = "${var.cf_bucket_name}"
  acl           = "${var.cf_bucket_acl}"
  force_destroy = "${var.cf_bucket_force_destroy}"
}

resource "aws_s3_bucket" "app_bucket" {
  bucket = "${var.app_bucket_name}"
  acl    = "${var.app_bucket_acl}"
}

locals {
  s3_origin_id = "${var.s3_origin_id}"
}

resource "aws_cloudfront_distribution" "cf_distribution" {
  origin {
    domain_name = "${aws_s3_bucket.cf_bucket.bucket_regional_domain_name}"
    origin_id   = "${local.s3_origin_id}"
  }

  enabled             = true

  default_cache_behavior {
    allowed_methods  = "${var.allowed_methods}"
    cached_methods   = "${var.cached_methods}"
    target_origin_id = "${local.s3_origin_id}"

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "allow-all"
    min_ttl                = 0
    default_ttl            = 86400
    max_ttl                = 31536000
  }

  price_class = "PriceClass_All"

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  tags {
    Environment = "${var.env_name}"
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
}
