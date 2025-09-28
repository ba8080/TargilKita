variable "project_name"   { type = string }
variable "ami_owner"      { type = string }
variable "instance_type"  { type = string }
variable "key_name"       { type = string }
variable "root_volume_gb" { type = number }

variable "vpc_id"            { type = string }
variable "public_subnet_id"  { type = string }
variable "private_subnet_ids"{ type = list(string) }

variable "bastion_sg_id" { type = string }
variable "app_sg_id"     { type = string }
