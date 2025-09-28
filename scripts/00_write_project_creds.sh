#!/usr/bin/env bash
set -euo pipefail
mkdir -p .aws
cat > .aws/credentials <<'EOF'
[default]
aws_access_key_id=REPLACE_ME
aws_secret_access_key=REPLACE_ME
aws_session_token=REPLACE_ME
EOF
echo "[OK] Wrote .aws/credentials with placeholders."
echo "Edit the file and paste your real values (from the Academy) in place of REPLACE_ME."
