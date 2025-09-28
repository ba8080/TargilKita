# Prefer a project-scoped credentials file if present; fall back to your global ~/.aws
AWS_PROFILE ?= default
AWS_SDK_LOAD_CONFIG ?= 1
ifeq ($(wildcard .aws/credentials), .aws/credentials)
  export AWS_SHARED_CREDENTIALS_FILE := $(PWD)/.aws/credentials
endif
export AWS_PROFILE
export AWS_SDK_LOAD_CONFIG

.PHONY: precheck bootstrap init plan apply provision destroy destroy-all

precheck:
	@command -v aws >/dev/null 2>&1 || (echo "ERROR: aws CLI not found"; exit 1)
	@command -v terraform >/dev/null 2>&1 || (echo "ERROR: terraform not found"; exit 1)
	@command -v jq >/dev/null 2>&1 || (echo "ERROR: jq not found"; exit 1)
	@aws sts get-caller-identity >/dev/null 2>&1 || (echo "ERROR: AWS credentials not detected. Use CloudShell/Cloud9 OR create .aws/credentials (see .aws/credentials.TEMPLATE) OR export env vars."; exit 1)
	@echo "[OK] Precheck passed (aws/terraform/jq + credentials). Using profile: $(AWS_PROFILE)"
	@if [ -n "$$AWS_SHARED_CREDENTIALS_FILE" ]; then echo "[OK] Using project-scoped credentials: $$AWS_SHARED_CREDENTIALS_FILE"; fi

bootstrap: precheck
	cd terraform/bootstrap_state && terraform init && terraform apply -auto-approve \
	  -var="region=us-east-1" \
	  -var="state_bucket_name=ori-tf-state-$(shell date +%s)" \
	  -var="lock_table_name=tf-locks"

init: precheck
	cd terraform/main && terraform init -backend-config=../env/backend.hcl -migrate-state

plan: precheck
	cd terraform/main && terraform plan -var-file=../env/dev.tfvars

apply: precheck
	cd terraform/main && terraform apply -auto-approve -var-file=../env/dev.tfvars

provision: precheck
	./scripts/03_ansible_provision.sh

destroy: precheck
	cd terraform/main && terraform destroy -auto-approve -var-file=../env/dev.tfvars

destroy-all:
	$(MAKE) destroy || true
	cd terraform/bootstrap_state && terraform destroy -auto-approve || true
