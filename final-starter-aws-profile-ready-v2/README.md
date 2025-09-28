# Terraform + Ansible – פרויקט הכנה (AWS Academy Sandbox)

## תקציר
- Terraform מקים VPC, 2×Private Subnets, 1×Public Subnet, Security Groups, 2×EC2 לאפליקציה (פרטיים), 1×Bastion/Ansible (ציבורי), ו-**NLB** שמאזן בין שני ה-EC2.
- Ansible מתקין Python, Nginx, Gunicorn, וקוד הפרויקט האמצעי.
- Remote state מנוהל ב-S3 + נעילה ב-DynamoDB – נבנים באמצעות Terraform (bootstrap), ואז מבצעים migration ל-remote backend.

## דרישות מוקדמות
- חשבון AWS Academy (Sandbox), Region: `us-east-1`
- Terraform ≥ 1.6, Ansible ≥ 2.14, `jq` מותקן
- מפתח SSH של המעבדה (labsuser.pem / vockey)

## זרימת עבודה מהירה
```bash
make bootstrap             # יוצר S3 + DynamoDB ל-remote state
# ערוך terraform/env/backend.hcl עם שם ה-bucket והטבלה שנוצרו
make init                  # terraform init עם backend-config + migrate-state
make apply                 # מקים את כל התשתיות
make provision             # מריץ Ansible על השרתים
# גש לאפליקציה דרך ה-NLB DNS name (terraform output lb_dns_name)
make destroy               # הורס את הסביבה הראשית
make destroy-all           # הורס גם את ה-bootstrap (S3/DDB) – זהירות
```

## איך Ansible מקבל נתונים מ-Terraform?
`scripts/03_ansible_provision.sh` מריץ `terraform output -json`, מפיק bastion/app IPs ו-LB DNS, ומייצר `ansible/inventory/hosts.ini` + `group_vars/all.yml`.

## קבצים עיקריים
- `terraform/bootstrap_state/*`: S3 + DynamoDB.
- `terraform/env/backend.hcl`: הגדרת backend (לעריכה ידנית).
- `terraform/main/modules/*`: מודולים לתשתיות.
- `ansible/*`: פלייבוקים ורולים לפריסת האפליקציה.

## Destroy
1. `make destroy` – מוחק VPC/EC2/NLB וכו'.
2. `make destroy-all` – מוחק גם את ה-S3/DynamoDB (רק אם אין שימוש נוסף).
