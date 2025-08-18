variable "project_id" {
  description = "The Google Cloud project ID"
  type        = string
}

variable "name" {
  description = "The unique name for the resource set"
  type        = string
}

variable "region" {
  description = "The region where resources will be created"
  type        = string
}

variable "nginx_image_url" {
  description = "The Nginx Image URL"
  type        = string
}

variable "cloud_run_sa_email" {
  description = "SA Email we wish to give run privs to"
  type        = string
}