module "network" {
  source        = "./modules/network"
  project_name  = var.project_name
  vpc_cidr      = var.vpc_cidr
  azs           = var.azs
  public_cidr   = var.public_cidr
  private_cidrs = var.private_cidrs
}

module "security" {
  source            = "./modules/security"
  vpc_id            = module.network.vpc_id
  lb_ingress_cidrs  = ["0.0.0.0/0"]  # פתוח ל-80 לציבור (NLB הוא L4)
}

module "compute" {
  source            = "./modules/compute"
  project_name      = var.project_name
  ami_owner         = "137112412989"
  instance_type     = var.instance_type
  key_name          = var.key_name
  root_volume_gb    = var.root_volume_gb

  vpc_id            = module.network.vpc_id
  public_subnet_id  = module.network.public_subnet_id
  private_subnet_ids= module.network.private_subnet_ids

  bastion_sg_id     = module.security.bastion_sg_id
  app_sg_id         = module.security.app_sg_id
}

module "elb" {
  source               = "./modules/elb"
  project_name         = var.project_name
  vpc_id               = module.network.vpc_id
  public_subnet_id     = module.network.public_subnet_id
  target_instance_ids  = module.compute.app_instance_ids
  target_port          = 8000
  lb_sg_id             = module.security.lb_sg_id
}
