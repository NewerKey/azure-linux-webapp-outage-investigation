variable "subscription_id" {
  description = "Azure subscription ID"
  type        = string
}

variable "location" {
  description = "Azure region for the lab"
  type        = string
  default     = "polandcentral"

}

variable "resource_group_name" {
  description = "Resource group that contains the lab"
  type        = string
  default     = "rg-tf-support-lab"
}

variable "name_prefix" {
  description = "Prefix for resource names"
  type        = string
  default     = "tf-support-lab"

}
