terraform {
  backend "s3" {
    bucket = "gignac-cha"
    key = "github-actions/test-terraform.txt"
  }
}

provider "aws" {}

resource "aws_s3_object" "object" {
  bucket = "gignac-cha"
  key    = "github-actions/test-terraform.json"
  source = "test-terraform.json"

  # The filemd5() function is available in Terraform 0.11.12 and later
  # For Terraform 0.11.11 and earlier, use the md5() function and the file() function:
  # etag = "${md5(file("test-terraform.json"))}"
  etag = filemd5("test-terraform.json")
}