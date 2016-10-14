variable "aws_access_key" {}
variable "aws_secret_key" {}
variable "security_group" {default = "ose-demo"}
variable "keypair" {default = "osekeypair"}
variable "master_instance_type" {default = "c3.large"}
variable "node_instance_type" {default = "c3.large"}
variable "aws_availability_zone" {default = "us-east-1"}
variable "aws_region" {default = "us-east-1"}
variable "ebs_root_block_size" {default = "50"}
variable "aws_ami" {default = "ami-12663b7a"}
variable "num_nodes" { default = "2" }

provider "aws" {
    access_key = "${var.aws_access_key}"
    secret_key = "${var.aws_secret_key}"
    region = "${var.aws_region}"
}

resource "aws_instance" "ose-master" {
    ami = "${var.aws_ami}"
    instance_type = "${var.master_instance_type}"
    security_groups = [ "default", "${var.security_group}" ]
    availability_zone = "${var.aws_availability_zone}"
    key_name = "${var.keypair}"
    tags {
        Name = "master"
        sshUser = "ec2-user"
        role = "masters"
    }
	root_block_device = {
		volume_type = "gp2"
		volume_size = "${var.ebs_root_block_size}"
	}
}

resource "aws_instance" "ose-node" {
    count = "${var.num_nodes}"
    ami = "${var.aws_ami}"
    instance_type = "${var.node_instance_type}"
    security_groups = [ "default", "${var.security_group}" ]
    availability_zone = "${var.aws_availability_zone}"
    key_name = "${var.keypair}"
    tags {
        Name = "node${count.index}"
        sshUser = "ec2-user"
        role = "nodes"
    }
	root_block_device = {
		volume_type = "gp2"
		volume_size = "${var.ebs_root_block_size}"
	}
}
