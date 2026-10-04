variable "location" {
  description = "Azure region for the lab."
  type        = string
  default     = "polandcentral"

  validation {
    condition     = contains(["polandcentral"], lower(var.location))
    error_message = "This lab is currently restricted to polandcentral. Add other confirmed subscription-approved regions before changing it."
  }
}

variable "name_prefix" {
  description = "Prefix for resource names."
  type        = string
  default     = "support-outage-lab"

}

variable "vnet_address_space" {
  description = "Address prefix for the vm subnet; must be inside the VNet address space."
  type        = string
  default     = "10.20.0.0/16"
}

variable "subnet_address_prefix" {
  description = "Address prefix for the VM subnet; must be inside the VNet address space."
  type        = string
  default     = "10.20.1.0/24"
}

variable "vm_size" {
  description = "Azure VM size"
  type        = string
  default     = "Standard_B2als_v2"
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

