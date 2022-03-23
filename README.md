# Terraform + Ansible + Jenkins + EC2
- [x] Status:  Ainda em desenvolvimento.
###
### O Projeto utiliza Terraform para criar na AWS os recursos: Vpc, subnets(publicas e privadas), network Acls, route tables, internet gateway, security group, ec2, key-pair.
### Ansible para provisionar o Jenkins e Docker na Instancia EC2.
### Para utilizar este módulo é necessário os seguintes arquivos especificados logo abaixo:

   <summary>versions.tf - Arquivo com as versões dos providers.</summary>

```hcl
terraform {
  required_version = ">= 0.15.4"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.0"
    }
  }
}
```
#
<summary>main.tf - Arquivo que irá consumir os módulo para criar a infraestrutura proposto no projeto.</summary>

```hcl
provider "aws" {
  region = var.region
}


module "network" {
  source          = "git::https://github.com/israeldoamaral/terraform-vpc-aws"
  region          = var.region
  cidr            = var.cidr
  count_available = var.count_available
  vpc             = module.network.vpc
  tag_vpc         = var.tag_vpc
  nacl            = var.nacl
}


module "security_group" {
  source  = "git::https://github.com/israeldoamaral/terraform-sg-aws"
  vpc     = module.network.vpc
  sg-cidr = var.sg-cidr
  tag-sg = "Jenkins"

}


module "ssh-key" {
  source    = "git::https://github.com/israeldoamaral/terraform-sshkey-aws"
  namespace = var.namespace

  depends_on = [
    module.network
  ]
}


module "ec2" {
  source         = "git::https://github.com/israeldoamaral/terraform-ec2-aws"
  ami_id         = var.ami_id
  instance_type  = var.instance_type
  subnet_id      = module.network.public_subnet[0]
  security_group = module.security_group.security_group_id
  key_name       = module.ssh-key.key_name
  userdata       = "data/data.sh"
  tag_name       = var.tag_name

  depends_on = [
    module.network
  ]

}


resource "null_resource" "ansible_provisioner" {
  triggers = {
    public_ip = module.ec2.public_ip
  }

  provisioner "local-exec" {
    command = "ansible-playbook -u ubuntu -i '${module.ec2.public_ip},' --private-key ${module.ssh-key.key_name}.pem ansible/jenkins_docker.yml '--ssh-common-args=-o StrictHostKeyChecking=no'"
  }

  depends_on = [
    module.ec2
  ]
}
```
#
<summary>variables.tf - Arquivo que contém os inputs para as variáveis que os módulos irão utilizar e que podem ter seus valores alterados de acordo com a sua necessidade.</summary>

```hcl
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
  description = "Tag name da VPC"
  type        = string
  default     = "Jenkins"
}

variable "namespace" {
  description = "Tag name da ssh-key"
  type = string
  default = "Jenkins"

}

variable "ami_id" {
  description = "Nome da ami que sera usado para criar a ec2"
  type = string
  default = "ami-04505e74c0741db8d"
  
}

variable "instance_type" {
  description = "Tpo de instancia da AWS"
  type = string
  default = "t2.micro"
}

variable "tag_name" {
  description = "Tag name da instancia EC2"
  type = string
  default = "Jenkins"
  
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

```
#
<summary>outputs.tf - Disponibiliza informações sobre a infraestrutura na linha de comando e podem expor informações para outras configurações do Terraform usarem. Os valores de saída são semelhantes aos valores de retorno em linguagens de programação.</summary>

```hcl
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


```

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.15.4 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 3.0 |

##
## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_network"></a> [module_network](https://github.com/israeldoamaral/terraform-vpc-aws.git) | github.com/israeldoamaral/terraform-vpc-aws | n/a |
| <a name="module_security_group"></a> [module_security_group](https://github.com/israeldoamaral/terraform-sg-aws.git) | github.com/israeldoamaral/terraform-sg-aws | n/a |
| <a name="module_ssh-key"></a> [module_ssh-key](https://github.com/israeldoamaral/terraform-sshkey-aws.git) | github.com/israeldoamaral/terraform-sshkey-aws | n/a |
| <a name="module_ec2"></a> [module_ec2](https://github.com/israeldoamaral/terraform-ec2-aws.git) | github.com/israeldoamaral/terraform-ec2-aws | n/a |

##
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_region"></a> [region](#input\_region) | Região na AWS para a infraestrutura | `string` | `us-east-1` | yes |
| <a name="input_cidr"></a> [cidr](#input\_cidr) | Bloco de rede para a VPC | `string` | `10.10.0.0/16` | yes |
| <a name="input_count_available"></a> [count\_available](#input\_count\_available) | Numero de Zonas de disponibilidade | `number` | `2` | yes |
| <a name="input_tag_vpc"></a> [count\_tag_vpc](#input\_tag_vpc) | Tag name da VPC | `string` | `Jenkins` | yes |
| <a name="input_namespace"></a> [count\_namespace](#input\_namespace) | Tag name da ssh-key | `string` | `Jenkins` | yes |
| <a name="input_ami_id"></a> [count\_ami_id](#input\_ami_id) | Nome da ami que sera usado para criar a ec2 | `string` | `ami-04505e74c0741db8d` | yes |
| <a name="input_instance_type"></a> [count\_instance_type](#input\_instance_type) | Tipo de instancia da AWS | `string` | `t2.micro` | yes |
| <a name="input_tag_name"></a> [count\_tag_name](#input\_tag_name) | Tag name da instancia EC2 | `string` | `Jenkins` | yes |
| <a name="input_nacl"></a> [nacl](#input\_nacl) | Regras de Network Acls AWS | `map(object)` | `"ver no arquivo"` | yes |
| <a name="input_sg-cidr"></a> [tag\_sg-cidr](#input\_sg-cidr) | Mapa de portas de acesso | `map(object)` | `22   = { to_port = 22, description = "Entrada ssh", protocol = "tcp", cidr_blocks = ["0.0.0.0/0"] }`\n`8080 = { to_port = 8080, description = "Entrada custom para app", protocol = "tcp", cidr_blocks = ["0.0.0.0/0"] ` | yes |


## Outputs

No outputs.
#
## Como usar.
  - Para utilizar localmente crie os arquivos descritos no começo deste tutorial, main.tf, versions.tf, variables.tf e outputs.tf.
  - Após criar os arquivos, atente-se aos valores default das variáveis, pois podem ser alterados de acordo com sua necessidade. 
  - A variável `count_available` define o quantidade de zonas de disponibilidade, públicas e privadas que seram criadas nessa Vpc.
  - Certifique-se que possua as credenciais da AWS - **`AWS_ACCESS_KEY_ID`** e **`AWS_SECRET_ACCESS_KEY`**.

### Comandos
Para consumir os módulos deste repositório é necessário ter o terraform instalado ou utilizar o container do terraform dentro da pasta do seu projeto da seguinte forma:

* `docker run -it --rm -v $PWD:/app -w /app --entrypoint "" hashicorp/terraform:light sh` 
    
Em seguida exporte as credenciais da AWS:

* `export AWS_ACCESS_KEY_ID=sua_access_key_id`
* `export AWS_SECRET_ACCESS_KEY=sua_secret_access_key`
    
Agora é só executar os comandos do terraform:

* `terraform init` - Comando irá baixar todos os modulos e plugins necessários.
* `terraform fmt` - Para verificar e formatar a identação dos arquivos.
* `terraform validate` - Para verificar e validar se o código esta correto.
* `terraform plan` - Para criar um plano de todos os recursos que serão utilizados.
* `terraform apply` - Para aplicar a criação/alteração dos recursos. 
* `terraform destroy` - Para destruir todos os recursos que foram criados pelo terraform. 
