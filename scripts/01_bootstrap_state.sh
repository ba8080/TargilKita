#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/../terraform/bootstrap_state"
terraform init
terraform apply -auto-approve   -var="region=us-east-1"   -var="state_bucket_name=ori-tf-state-$(date +%s)"   -var="lock_table_name=tf-locks"
