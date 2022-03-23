output "vpc" {
  description = "Idendificador da VPC"
  value       = module.network.vpc

}

output "public_subnet" {
  description = "Subnet public "
  value       = module.network.public_subnet

}

output "private_subnet" {
  description = "Subnet private "
  value       = module.network.private_subnet

}


output "security_Group" {
  description = "Security Group"
  value       = module.security_group.security_group_id

}


output "ssh_keypair" {
  value = module.ssh-key.ssh_keypair
  sensitive = true

}


output "key_name" {
  value = module.ssh-key.key_name

}

output "IP_Jenkins" {
  description = "Retorna o ip da instancia Jenkins"
  value = format("%s:8080",module.ec2.public_ip)

}

output "ec2_ip" {
  description = "Retorna o ip da instancia"
  value = module.ec2.public_ip

}
