variable "region" {
  type        = string
  description = "Região na AWS"
  default     = "us-east-1"
}

variable "cidr" {
  description = "CIDR da VPC"
  type        = string
  default     = "10.10.0.0/16"
}

variable "count_available" {
  type        = number
  description = "Numero de Zonas de disponibilidade"
  default     = 2
}

variable "tag_vpc" {
  description = "Tag Name da VPC"
  type        = string
  default     = "Jenkins"
}


variable "nacl" {
  description = "Regras de Network Acls AWS"
  type        = map(object({ protocol = string, action = string, cidr_blocks = string, from_port = number, to_port = number }))
  default = {
    100 = { protocol = "tcp", action = "allow", cidr_blocks = "0.0.0.0/0", from_port = 22, to_port = 22 }
    105 = { protocol = "tcp", action = "allow", cidr_blocks = "0.0.0.0/0", from_port = 80, to_port = 80 }
    110 = { protocol = "tcp", action = "allow", cidr_blocks = "0.0.0.0/0", from_port = 443, to_port = 443 }
    150 = { protocol = "tcp", action = "allow", cidr_blocks = "0.0.0.0/0", from_port = 1024, to_port = 65535 }
  }
}


variable "sg-cidr" {
  description = "Mapa de portas de serviços"
  default = {
    22   = { to_port = 22, description = "Entrada ssh", protocol = "tcp", cidr_blocks = ["0.0.0.0/0"] }
    8080 = { to_port = 8080, description = "Entrada custom para app", protocol = "tcp", cidr_blocks = ["0.0.0.0/0"] }
  }
}
