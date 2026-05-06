variable "vnet1" {
  description = "map od vnets"
  type        = map(string)
  default = {
    siec0 = "10.0.0.0/16"
    siec1 = "10.1.0.0/16"
    siec2 = "10.2.0.0/16"
  }
}

variable "vnet2" {
  description = "map od vnets"
  type        = map(string)
  default = {
    hub0 = "10.5.0.0/16"
  }
}

variable "region" {
  description = "Azure region"
  type        = string
  default     = "polandcentral"
}

variable "subscription_id" {
  type = string
}