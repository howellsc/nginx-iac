variable "name" {
  description = "The unique name for the resource set"
  type        = string
}

variable "vpc_name" {
  description = "VPC Name"
  type        = string
}

variable "region" {
  description = "The region where resources will be created"
  type        = string
  # Default value
}

variable "nginx_backend_mig_id" {
  description = "The Nginx backend MIG Id"
  type        = string
  default     = ""
}

variable "nginx_backend_neg_id" {
  description = "The Nginx backend NEG Id"
  type        = string
  default     = ""
}

variable "vpc_subnet_name" {
  description = "VPC subnet name"
  type        = string
}