# -------------------------
# EC2 IAM Role
# -------------------------

resource "aws_iam_role" "ec2" {
  name = "${var.environment}-go-api-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Principal = {
          Service = "ec2.amazonaws.com"
        }

        Action = "sts:AssumeRole"
      }
    ]
  })
}

# -------------------------
# S3 Policy
# -------------------------

resource "aws_iam_role_policy" "s3_logs" {
  name = "${var.environment}-s3-logs"
  role = aws_iam_role.ec2.id

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Action = [
          "s3:PutObject"
        ]

        Resource = "${aws_s3_bucket.logs.arn}/logs/*"
      }
    ]
  })
}

# -------------------------
# S3 Bucket
# -------------------------

resource "aws_s3_bucket" "logs" {
  bucket_prefix = "${var.environment}-go-api-logs-"

  force_destroy = true

  tags = {
    Name = "${var.environment}-go-api-logs"
  }
}

# -------------------------
# Block Public Access
# -------------------------

resource "aws_s3_bucket_public_access_block" "logs" {
  bucket = aws_s3_bucket.logs.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# -------------------------
# Instance Profile
# -------------------------

resource "aws_iam_instance_profile" "ec2" {
  name = "${var.environment}-go-api-instance-profile"
  role = aws_iam_role.ec2.name
}
