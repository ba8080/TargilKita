#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/../terraform/main"
terraform init -backend-config=../env/backend.hcl -migrate-state
terraform apply -auto-approve -var-file=../env/dev.tfvars
