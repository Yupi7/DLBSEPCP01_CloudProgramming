variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "service_plan_name" {
  type = string
}

variable "web_app_name" {
  type = string
}

variable "region_role" {
  type = string
}

variable "project_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "app_service_sku" {
  type = string
}

variable "autoscale_minimum" {
  type = number
}

variable "autoscale_default" {
  type = number
}

variable "autoscale_maximum" {
  type = number
}

variable "scale_out_threshold" {
  type = number
}

variable "scale_in_threshold" {
  type = number
}
