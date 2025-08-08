locals {
  state_bucket_region = "europe-west2"
}

provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
}

terraform {
  backend "gcs" {
    bucket = "${var.project_id}-terraform-state"
    prefix = "terraform/tfstate"
  }
}

resource "google_storage_bucket" "external_state" {
  name                        = "${var.project_id}-terraform-state"
  location                    = local.state_bucket_region
  uniform_bucket_level_access = true
}

module "gce_instances" {
  source = "./modules/instances"

  project_id      = var.project_id
  region          = var.region
  zone            = var.zone
  vpc_name        = module.vpc_network.vpc_name
  vpc_subnet_name = module.vpc_network.vpc_subnet_name
}

module "vpc_network" {
  source = "./modules/vpc"
  region = var.region
}
