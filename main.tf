#
# DO NOT DELETE THESE LINES UNTIL INSTRUCTED TO!
#
# Your AMI ID is:
#
#     ami-0cbf7a0c36bde57c9
#
# Your subnet ID is:
#
#     subnet-0be39c0861c5edfe9
#
# Your VPC security group ID is:
#
#     sg-089c50e2af8294089
#
# Your Identity is:
#
#     ecsd-academy-bear
#

variable "access_key" {}

variable "secret_key" {}

variable "region" {
	default = "eu-west-1"
}

variable "ami" {}
variable "instance_type" {}
variable "subnet_id" {}
variable "vpc_security_group_id" {}
variable "Identity" {}


provider "aws" {
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
  region     = "${var.region}"
}

module "server" {
	source = "./server"
  ami                    = "${var.ami}"
  instance_type          = "${var.instance_type}"
  subnet_id              = "${var.subnet_id}"
  vpc_security_group_id = "${var.vpc_security_group_id}"
	Identity = "${var.Identity}"
}

output "public_ip" {
	value = "${module.server.public_ip}"
}
