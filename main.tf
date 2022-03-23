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
