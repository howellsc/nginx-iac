variable "name" {
  description = "The unique name for the resource set"
  type        = string
}

variable "vpc_name" {
  description = "VPC Name"
  type        = string
}

variable "vpc_subnet_gke_name" {
  description = "VPC GKE subnet name"
  type        = string
}

variable "nginx_image_url" {
  description = "The Nginx Image URL"
  type        = string
}

variable "vpc_subnet_gke_secondary_ip_range" {
  description = "VPC GKE subnet secondary ip range"
  type        = list(string)
}
