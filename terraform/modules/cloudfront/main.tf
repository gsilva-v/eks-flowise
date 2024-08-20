resource "aws_s3_bucket" "my_bucket" {
  bucket = var.cdn-bucket-name
  # bucket = "test-toolz-devops"
  acl    = "private"
}

resource "aws_cloudfront_distribution" "cdn" {
  origin {
    domain_name = "${aws_s3_bucket.my_bucket.bucket_regional_domain_name}" 
    # origin_id   = "myS3Origin"
    origin_id   = var.origin-id
  }

  enabled             = true
  is_ipv6_enabled     = true
  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = var.origin-id
    # target_origin_id = "myS3Origin"

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  tags = {
    Name = "cdn-distribution"
  }
}