terraform {
  required_version = ">= 1.6"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }

    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }
}

provider "aws" {
  region = "us-east-1"

  default_tags {
    tags = {
      Project         = var.project_name
      Environment     = var.environment
      ManagedBy       = "terraform"
      ComplianceScope = "cge-p-lab"
    }
  }
}


resource "random_id" "suffix" {
  byte_length = 4
}


locals {
  bucket_suffix = var.bucket_suffix != "" ? var.bucket_suffix : random_id.suffix.hex

  bucket_name = "${var.project_name}-${var.environment}-${local.bucket_suffix}"
}


#
# Primary compliant bucket
#
resource "aws_s3_bucket" "primary" {
  bucket = local.bucket_name
}


#
# Logging bucket
#
resource "aws_s3_bucket" "log" {
  bucket = "${local.bucket_name}-logs"
}


#
# Versioning
#
resource "aws_s3_bucket_versioning" "primary" {

  bucket = aws_s3_bucket.primary.id

  versioning_configuration {
    status = "Enabled"
  }
}


#
# SC-28 Encryption at Rest
#
resource "aws_s3_bucket_server_side_encryption_configuration" "primary" {

  bucket = aws_s3_bucket.primary.id

  rule {

    apply_server_side_encryption_by_default {

      sse_algorithm = "AES256"

    }
  }
}
resource "aws_s3_bucket_server_side_encryption_configuration" "log" {
  bucket = aws_s3_bucket.log.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

#
# AC-3 Access Enforcement
#
resource "aws_s3_bucket_public_access_block" "primary" {

  bucket = aws_s3_bucket.primary.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_public_access_block" "log" {
  bucket                  = aws_s3_bucket.log.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

#
# Bucket ownership enforcement
#
resource "aws_s3_bucket_ownership_controls" "primary" {

  bucket = aws_s3_bucket.primary.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}
