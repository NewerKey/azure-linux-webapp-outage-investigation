variable "location" {
  description = "Azure region for the lab."
  type        = string
  default     = "polandcentral"

}

variable "resource_group_name" {
  description = "Resource group that contains the lab."
  type        = string
  default     = "rg-tf-support-outage-lab"
}

variable "name_prefix" {
  description = "Prefix for resource names."
  type        = string
  default     = "support-outage-lab"

}

variable "vnet_address_space" {
  description = "Address prefix for the VM subnet; must be inside the VNet address space."
  type        = string
  default     = "10.20.1.0/24"
}

variable "vm_size" {
  description = "Azure VM size"
  type        = string
  default     = "Standard_B1s"
}

variable "admin_username" {
  description = "Linux administrator username."
  type        = string
  default     = "supportuser"
}

variable "ssh_public_key" {
  description = "Contents of the SSH public key."
  type        = string
}

variable "ssh_source_cidr" {
  description = "Public IPv4 CIDR allowed to connect over SSH."
  type        = string

  validation {
    condition     = can(cidrnetmask(var.ssh_source_cidr))
    error_message = "ssh_source_cidr must be a valid IPv4 CIDR, such as an address with /32."
  }
}


