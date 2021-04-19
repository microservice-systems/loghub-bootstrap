provider "aws" {
  profile = "default"
  region = "us-east-1"
}

resource "aws_kms_key" "encryption_key" {
  is_enabled = true
  enable_key_rotation = false
  key_usage = "ENCRYPT_DECRYPT"
  customer_master_key_spec = "SYMMETRIC_DEFAULT"
  deletion_window_in_days = 30

  tags = {
    loghub = "true"
  }
}

resource "aws_s3_bucket" "bucket" {
  bucket = "loghub-account-company"
  acl = "private"

  versioning {
    enabled = false
    mfa_delete = false
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = aws_kms_key.encryption_key.arn
        sse_algorithm = "aws:kms"
      }
    }
  }

  lifecycle_rule {
    id = "event"
    enabled = true

    transition {
      days = 60
      storage_class = "GLACIER"
    }

    expiration {
      days = 180
    }

    tags = {
      type = "event"
    }
  }

  lifecycle_rule {
    id = "metric"
    enabled = true

    transition {
      days = 60
      storage_class = "GLACIER"
    }

    expiration {
      days = 180
    }

    tags = {
      type = "metric"
    }
  }

  tags = {
    loghub = "true"
  }
}
