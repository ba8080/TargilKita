output "state_bucket" { value = var.state_bucket_name }
output "lock_table"   { value = aws_dynamodb_table.tf_locks.name }
