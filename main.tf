# ==========================================
# 1. IAM ROLE FOR REPLICATION
# ==========================================

resource "aws_iam_role" "replication_role" {
  name = "tf-s3-replication-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = { Service = "s3.amazonaws.com" }
    }]
  })
}


resource "aws_iam_role_policy_attachment" "replication_full_access" {
  role       = aws_iam_role.replication_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess" # Using managed policy for quick lab setup
}


# ==========================================
# 2. PRIMARY BUCKET (us-east-1)
# ==========================================
resource "aws_s3_bucket" "primary" {
  # Uses the default provider automatically
  bucket_prefix = "ovr-primary-data-"
  force_destroy = true # Makes cleanup easy later
}


resource "aws_s3_bucket_versioning" "primary_versioning" {
  bucket = aws_s3_bucket.primary.id
  versioning_configuration { status = "Enabled" }
}


# ==========================================
# 3. REPLICA BUCKET (us-west-2)
# ==========================================

resource "aws_s3_bucket" "replica" {
  # THE MAGIC: Explicitly routing this resource to Oregon!
  provider      = aws.west 
  bucket_prefix = "ovr-replica-backup-"
  force_destroy = true
}



resource "aws_s3_bucket_versioning" "replica_versioning" {
  provider = aws.west # Must specify the provider for the versioning block too!
  bucket   = aws_s3_bucket.replica.id
  versioning_configuration { status = "Enabled" }
}

# ==========================================
# 4. THE REPLICATION RULE
# ==========================================

resource "aws_s3_bucket_replication_configuration" "replication" {
  # Must depend on versioning being fully applied first
  depends_on = [aws_s3_bucket_versioning.primary_versioning]

  role   = aws_iam_role.replication_role.arn
  bucket = aws_s3_bucket.primary.id

  rule {
    id     = "replicate-all-to-west"
    status = "Enabled"

    destination {
      bucket = aws_s3_bucket.replica.arn
    }
  }
}