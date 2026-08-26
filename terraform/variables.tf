variable "aws_region" {
  default = "us-west-2"
}

variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

variable "cluster_name" {
  default = "eks-cluster"
}

variable "kubernetes_version" {
  default = "1.33"
}

variable "jwt_secret" {
  description = "JWT signing secret for backend auth"
  type        = string
  sensitive   = true
}

variable "mongo_uri" {
  description = "MongoDB connection URI"
  type        = string
  sensitive   = true
}

variable "cloudinary_name" {
  description = "Cloudinary cloud name"
  type        = string
  sensitive   = true
}

variable "cloudinary_api_key" {
  description = "Cloudinary API key"
  type        = string
  sensitive   = true
}

variable "cloudinary_secret_key" {
  description = "Cloudinary API secret key"
  type        = string
  sensitive   = true
}