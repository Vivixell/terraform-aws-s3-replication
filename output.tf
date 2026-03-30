output "primary_bucket_name" {
  description = "The name of the primary S3 bucket in us-east-1"
  value       = aws_s3_bucket.primary.id
}

output "replica_bucket_name" {
  description = "The name of the replica S3 bucket in us-west-2"
  value       = aws_s3_bucket.replica.id
}