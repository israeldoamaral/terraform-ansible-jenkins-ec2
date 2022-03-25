# Região na AWS
region = "us-east-1"

# CIDR da VPC
cidr = "10.10.0.0/16"

# Quantidade de subnets desejada
count_available = 2

# Tag name da VPC
tag_vpc = "Jenkins"

# Tag name da ssh-key
namespace = "Jenkins"

# Id da AMI que sera usado para criar a ec2
ami_id = "ami-04505e74c0741db8d"

# Tipo de instancia da AWS
instance_type = "t2.micro"

# Tag name da instancia EC2
tag_name = "Jenkins"


# Regras de Network Acls AWS
nacl = {
    100 = { protocol = "tcp", action = "allow", cidr_blocks = "0.0.0.0/0", from_port = 22, to_port = 22 }
    105 = { protocol = "tcp", action = "allow", cidr_blocks = "0.0.0.0/0", from_port = 80, to_port = 80 }
    110 = { protocol = "tcp", action = "allow", cidr_blocks = "0.0.0.0/0", from_port = 443, to_port = 443 }
    150 = { protocol = "tcp", action = "allow", cidr_blocks = "0.0.0.0/0", from_port = 1024, to_port = 65535 }
}


# Tag name do Security Group
tag-sg = "Jenkins"

# Regras de acesso do security group
sg-cidr = {
    22   = { to_port = 22, description = "Entrada ssh", protocol = "tcp", cidr_blocks = ["0.0.0.0/0"] }
    8080 = { to_port = 8080, description = "Entrada custom para app", protocol = "tcp", cidr_blocks = ["0.0.0.0/0"] }
}
