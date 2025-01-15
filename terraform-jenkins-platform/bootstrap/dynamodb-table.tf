resource "aws_dynamodb_table" "this" {
  name = var.state_lock_table_name
  hash_key = "LockID"
  billing_mode = "PAY_PER_REQUEST"
 
  attribute {
    name = "LockID"
    type = "S"
  }

  server_side_encryption {
    enabled = true
  }
}