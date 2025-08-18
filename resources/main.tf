locals {
  state_bucket_region = var.region
  nginx_image_url     = "gcr.io/${var.project_id}/nginx-static-site:v1"
}

provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
}

terraform {
  # backend "gcs" {
  #   bucket = "terraform-state"
  #   prefix = "terraform/tfstate"
  # }
  backend "local" {}
}

resource "google_storage_bucket" "external_state" {
  name                        = "${var.project_id}-${var.name}-terraform-state"
  location                    = local.state_bucket_region
  uniform_bucket_level_access = true
}

module "gce_instances" {
  source = "./modules/instances"

  project_id           = var.project_id
  region               = var.region
  zone                 = var.zone
  vpc_name             = module.vpc_network.vpc_name
  vpc_subnet_name      = module.vpc_network.vpc_subnet_name
  nginx_healthcheck_id = module.lb.nginx_healthcheck_id
  name                 = var.name
  nginx_image_url      = local.nginx_image_url
}

module "vpc_network" {
  source = "./modules/vpc"
  region = var.region
  name   = var.name
}

module "serverless" {
  source          = "./modules/serverless"
  project_id      = var.project_id
  name            = var.name
  region          = var.region
  nginx_image_url = local.nginx_image_url
}

module "lb" {
  source               = "./modules/lb"
  project_id           = var.project_id
  name                 = var.name
  vpc_name             = module.vpc_network.vpc_name
  vpc_subnet_name      = module.vpc_network.vpc_subnet_name
  region               = var.region
  nginx_backend_mig_id = module.gce_instances.nginx_mig_id
  nginx_backend_neg_id = module.serverless.nginx_neg_id
}

module "gke" {
  source                            = "./modules/gke"
  name                              = var.name
  region                            = var.region
  vpc_name                          = module.vpc_network.vpc_name
  vpc_subnet_gke_name               = module.vpc_network.vpc_subnet_gke_name
  vpc_subnet_gke_secondary_ip_range = module.vpc_network.vpc_subnet_gke_secondary_ip_range
  nginx_image_url                   = local.nginx_image_url
}
