output s3_state_bucket_name {
  value       = aws_s3_bucket.s3_tf_state_storage.id
  description = "S3 state bucket name"
}

output dynamodb_state_lock_table_name {
  value       = aws_dynamodb_table.this.id
  description = "Dynamodb state lock table name"
}