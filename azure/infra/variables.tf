variable "tenant_id" {
}
variable "region" {
  default = "eastus2"
}

variable "resource_group_name" {
  default = "kthw"
}

variable "private_domain" {
  default = "cloud-native.dev"
}

variable "vnet_cidr" {
  default = "10.240.0.0/24"
}

variable "vm_size" {
  default = "Standard_D2as_v5"
}

variable "admin_username" {
  default = "azure"
}

variable "spot_max_price" {
  default = 0.01
}




variable "k8s_subnet_cidr" {
  default = "10.240.0.0/27"
}

variable "control_plane_cidr" {
  default = "10.240.0.128/28"
}

variable "nodes_cidr" {
  default = "10.240.0.144/28"
}


variable "utility_cidr" {
  default = "10.240.0.224/28"
}


variable "dmz_subnet_cidr" {
  default = "10.240.0.240/28"
}
