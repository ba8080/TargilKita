output "bastion_public_ip" { value = module.compute.bastion_public_ip }
output "app_private_ips"  { value = module.compute.app_private_ips }
output "lb_dns_name"      { value = module.elb.lb_dns_name }
