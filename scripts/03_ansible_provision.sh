#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/../terraform/main"
TF_JSON=$(terraform output -json)

BASTION_PUBLIC_IP=$(echo "$TF_JSON" | jq -r '.bastion_public_ip.value')
APP_PRIV_IPS=$(echo "$TF_JSON" | jq -r '.app_private_ips.value[]')
LB_DNS=$(echo "$TF_JSON" | jq -r '.lb_dns_name.value')

INV_FILE="../../ansible/inventory/hosts.ini"
mkdir -p ../../ansible/inventory ../../ansible/inventory/group_vars
cat > "$INV_FILE" <<EOF
[bastion]
$BASTION_PUBLIC_IP

[app]
EOF
for ip in $APP_PRIV_IPS; do echo "$ip" >> "$INV_FILE"; done

cat > ../../ansible/inventory/group_vars/all.yml <<EOF
---
app_user: ec2-user
use_proxyjump: true
bastion_host: $BASTION_PUBLIC_IP
lb_dns_name: $LB_DNS
app_repo_url: "https://github.com/YOURORG/YOURMIDPROJECT.git"
app_port: 8000
EOF

echo "[OK] Inventory & group vars generated."

cd ../../ansible
export ANSIBLE_SSH_ARGS="-o ProxyJump=ec2-user@${BASTION_PUBLIC_IP}"
ansible-playbook -i inventory/hosts.ini playbooks/bastion.yml
ansible-playbook -i inventory/hosts.ini playbooks/site.yml
