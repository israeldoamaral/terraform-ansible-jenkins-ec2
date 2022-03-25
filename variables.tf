variable "region" {
  type        = string
  description = "Região na AWS"
}

variable "cidr" {
  description = "CIDR da VPC"
  type        = string
}

variable "count_available" {
  type        = number
  description = "Quantidade de subnets desejada"
}

variable "tag_vpc" {
  description = "Tag name da VPC"
  type        = string
}

variable "namespace" {
  description = "Tag name da ssh-key"
  type        = string
}

variable "ami_id" {
  description = "Nome da ami que sera usado para criar a ec2"
  type        = string
}

variable "instance_type" {
  description = "Tipo de instancia da AWS"
  type        = string
}

variable "tag_name" {
  description = "Tag name da instancia EC2"
  type        = string
}


variable "nacl" {
  description = "Regras de Network Acls AWS"
  type        = map(object({ protocol = string, action = string, cidr_blocks = string, from_port = number, to_port = number }))
}


variable "tag-sg" {
  description = "Tag name do Security Group"
  type        = string
}

variable "sg-cidr" {
  description = "Regras de acesso do security group"
  type        = map(any)
}
