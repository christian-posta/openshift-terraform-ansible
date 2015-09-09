variable "aws_access_key" {}
variable "aws_secret_key" {}
variable "aws_region" {default = "us-east-1"}

provider "aws" {
    access_key = "${var.aws_access_key}"
    secret_key = "${var.aws_secret_key}"
    region = "${var.aws_region}"
}

variable "num_nodes" {
    description = "Number of nodes to create"
    default = "2"
}

resource "aws_instance" "ose-master" {
    ami = "ami-12663b7a"
    instance_type = "m3.large"
    security_groups = [ "default", "activemq-demo" ]
    availability_zone = "us-east-1c"
    key_name = "postakey"
    tags {
        Name = "master"
        sshUser = "ec2-user"
        role = "masters"
    }
	root_block_device = {
		volume_type = "gp2"
		volume_size = "50"
	}
}

resource "aws_instance" "ose-node" {
    count = "${var.num_nodes}"
    ami = "ami-12663b7a"
    instance_type = "m3.large"
    security_groups = [ "default", "activemq-demo" ]
    availability_zone = "us-east-1c"
    key_name = "postakey"
    tags {
        Name = "${concat("node", count.index)}"
        sshUser = "ec2-user"
        role = "nodes"
    }
	root_block_device = {
		volume_type = "gp2"
		volume_size = "50"
	}
}



resource "aws_eip" "master-eip" {
    instance = "${aws_instance.ose-master.id}"
}
resource "aws_eip" "node-eips" {
    count = "${var.num_nodes}"
    instance = "${element(aws_instance.ose-node.*.id, count.index)}"
}
