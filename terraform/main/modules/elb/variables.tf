variable "project_name"        { type = string }
variable "vpc_id"              { type = string }
variable "public_subnet_id"    { type = string }
variable "target_instance_ids" { type = list(string) }
variable "target_port"         { type = number }
variable "lb_sg_id"            { type = string }
