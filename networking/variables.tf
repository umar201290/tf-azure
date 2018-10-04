variable "RG" {
  default = "Test-RG"
}

variable "loc" {
  default = "eastus"
}

variable "vnet-name" {
  default = "test-vnet"
}

variable "vnet-cidr" {
  default = "10.0.0.0/16"
}

variable "subnet-name" {
  default = "test-subnet"
}

variable "subnet-cidr" {
  default = "10.0.1.0/24"
}

variable "public-ip" {
  default = "Public"
}

variable "vm-name" {
  default = "test-vm"
}
