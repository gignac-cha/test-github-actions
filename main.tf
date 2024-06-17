terraform {
  backend "s3" {
    bucket = "gignac-cha"
    key = "github-actions/test-terraform.txt"
  }
}

provider "aws" {}

variable "ratio" {
  type = number
  default = -1
}

resource "aws_s3_object" "test_object" {
  bucket = "gignac-cha"
  key    = "github-actions/test-terraform-${var.ratio}.json"
  source = "test-terraform.json"

  # The filemd5() function is available in Terraform 0.11.12 and later
  # For Terraform 0.11.11 and earlier, use the md5() function and the file() function:
  # etag = "${md5(file("test-terraform.json"))}"
  # etag = filemd5("test-terraform.json")
}

resource "aws_cloudfront_distribution" "staging" {
  enabled = true
  staging = true

  origin {
    origin_id = "test-s3"
    domain_name = "geek-news-crawler.s3.ap-northeast-2.amazonaws.com"
    # domain_name = "d3h07rymcluadc.cloudfront.net"
  }

  default_cache_behavior {
    cached_methods = ["HEAD", "GET"]
    viewer_protocol_policy = "allow-all"
    target_origin_id = "test-s3"
    allowed_methods = ["OPTIONS", "HEAD", "GET", "POST", "PUT", "PATCH", "DELETE"]

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    ssl_support_method = "sni-only"
  }
}

resource "aws_cloudfront_continuous_deployment_policy" "test_distribution" {
  enabled = true

  staging_distribution_dns_names {
    items    = [aws_cloudfront_distribution.staging.domain_name]
    # items = ["d3h07rymcluadc"]
    # items = ["d3h07rymcluadc.cloudfront.net"]
    # items = ["geek-news-crawler.s3.ap-northeast-2.amazonaws.com"]
    quantity = 1
  }

  traffic_config {
    type = "SingleWeight"
    single_weight_config {
      weight = "0.01"
    }
  }
}
resource "aws_cloudfront_distribution" "production" {
  enabled = true
  staging = false

  continuous_deployment_policy_id = aws_cloudfront_continuous_deployment_policy.test_distribution.id

  origin {
    origin_id = "test-s3"
    domain_name = "geek-news-crawler.s3.ap-northeast-2.amazonaws.com"
    # domain_name = "d3h07rymcluadc.cloudfront.net"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  default_cache_behavior {
    cached_methods = ["HEAD", "GET"]
    viewer_protocol_policy = "allow-all"
    target_origin_id = "test-s3"
    allowed_methods = ["OPTIONS", "HEAD", "GET", "POST", "PUT", "PATCH", "DELETE"]

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }
  }

  viewer_certificate {
    ssl_support_method = "sni-only"
  }
}
