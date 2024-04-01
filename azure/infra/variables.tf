variable "tenant_id" {
}
variable "region" {
  default = "eastus2"
}

variable "resource_group_name" {
  default = "kubernetes-the-hard-way"
}


variable "vnet_cidr" {
  default = "10.240.0.0/24"
}

variable "vm_size" {
  default = "Standard_D2as_v5"
}


variable "spot_max_price" {
  default = 0.01
}


variable "control_plane" {
  type = object({
    name        = string
    subnet_cidr = string
  })

  default = {
    name        = "k8s-control-plane"
    subnet_cidr = "10.240.0.32/28"
  }
}


variable "nodes" {
  type = object({
    name        = string
    subnet_cidr = string
  })
  default = {
    name        = "k8s-nodes"
    subnet_cidr = "10.240.0.64/27"
  }
}

variable "api_server_lb" {
  type = object({
    name       = string
    private_ip = string
    public_ip  = object({
      name = string
    })
  })
  default = {
    name       = "api-server-lb"
    private_ip = "10.240.0.37" //the first 4 ips and last ip are reserved.
    public_ip  = {
      name = "api-server-pip"
    }
  }
}

variable "dmz_zone" {
  type = object({
    cidr          = string
    load_balancer = object({
      name       = string
      private_ip = string
      public_ip  = object({
        name = string
      })
    })
  })

  default = {
    cidr          = "10.240.0.240/28"
    load_balancer = {
      name       = "lb-api-server"
      private_ip = "10.240.0.244" //the first 4 ips and last ip are reserved.
      public_ip  = {
        name = "kubernetes-the-hard-way"
      }
    }
  }
}

# configuration for both control plane and worker nodes are in the same subnet
variable "kubernetes" {
  type = object({
    name = string
    cidr = string
  })

  default = {
    name = "kubernetes"
    cidr = "10.240.0.0/27"
  }
}


variable "workers" {
  type = object({
    name = string
    cidr = string
  })

  default = {
    name = "workers"
    cidr = "10.240.0.144/28"
  }
}


variable "vm_instance" {
  type = object({
    ssh_key = object({
      username      = string
      vm_public_key = string
      lb_public_key = string
    })
  })

  default = {
    ssh_key = {
      username      = "azureuser"
      vm_public_key = "id_vm.pub"
      lb_public_key = "~/.ssh/id_rsa.pub"
    }
  }
}

variable "vm_image" {
  type = object({
    publisher = string
    offer     = string
    sku       = string
    version   = string
  })

  default = {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-LTS"
    version   = "latest"
  }
}