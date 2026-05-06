variable "region" {
  description = "azure region"
  type        = string
}

variable "rg_name" {
  description = "name of resource group"
  type        = string
}

variable "vnets_map" {
  description = "map of vnets"
  type        = map(string)
}

variable "subnet_count" {
  description = "count of subnets in vnet"
  type        = number
}