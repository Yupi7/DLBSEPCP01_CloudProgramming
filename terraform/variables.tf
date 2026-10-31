variable "project_name" {
  type    = string
  default = "Cloud Programming"
}

variable "environment" {
  type    = string
  default = "Development"
}

variable "resource_group_name" {
  type    = string
  default = "rg-cloudprogramming-dev"
}

variable "resource_group_location" {
  type    = string
  default = "West Europe"
}

variable "france_central_location" {
  type    = string
  default = "France Central"
}

variable "sweden_central_location" {
  type    = string
  default = "Sweden Central"
}

variable "app_service_sku" {
  type    = string
  default = "S1"
}

variable "autoscale_minimum" {
  type    = number
  default = 1
}

variable "autoscale_default" {
  type    = number
  default = 1
}

variable "autoscale_maximum" {
  type    = number
  default = 3
}

variable "scale_out_threshold" {
  type    = number
  default = 70
}

variable "scale_in_threshold" {
  type    = number
  default = 30
}
