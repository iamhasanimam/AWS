variable "project_name" { default = "microservices-app" }
variable "vpc_cidr"     { default = "10.0.0.0/16" }
variable "public_subnets" {
  default = ["10.0.1.0/24", "10.0.2.0/24"]
}