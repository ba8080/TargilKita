terraform {
  required_version = ">= 1.6.0"
  required_providers {
    aws = { source = "hashicorp/aws", version = "~> 5.0" }
  }
}

provider "aws" { region = var.region }

# --- Create/ensure S3 bucket using AWS CLI to avoid GetObjectLockConfiguration permission issues ---
resource "null_resource" "s3_bootstrap" {
  triggers = {
    bucket = var.state_bucket_name
    region = var.region
  }

  provisioner "local-exec" {
    interpreter = ["/bin/bash","-lc"]
    command = <<'EOT'
set -euo pipefail
BUCKET="${bucket}"
REGION="${region}"

# Create bucket if missing (us-east-1 has special rule: no LocationConstraint)
if aws s3api head-bucket --bucket "$BUCKET" 2>/dev/null; then
  echo "[OK] Bucket $BUCKET already exists."
else
  if [ "$REGION" = "us-east-1" ]; then
    aws s3api create-bucket --bucket "$BUCKET" --acl private
  else
    aws s3api create-bucket --bucket "$BUCKET" --acl private --create-bucket-configuration LocationConstraint="$REGION"
  fi
  echo "[OK] Created bucket $BUCKET in $REGION."
fi

# Block all public access
aws s3api put-public-access-block --bucket "$BUCKET"   --public-access-block-configuration BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true

# Enable versioning (for state history)
aws s3api put-bucket-versioning --bucket "$BUCKET" --versioning-configuration Status=Enabled

# Default SSE-S3 encryption
aws s3api put-bucket-encryption --bucket "$BUCKET"   --server-side-encryption-configuration '{"Rules":[{"ApplyServerSideEncryptionByDefault":{"SSEAlgorithm":"AES256"}}]}'
EOT
  }
}

# DynamoDB table for state locking
resource "aws_dynamodb_table" "tf_locks" {
  name         = var.lock_table_name
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}
