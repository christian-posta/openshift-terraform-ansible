variable "openstack_user_name" {}
variable "openstack_tenant_name" {}
variable "openstack_tenant_id" {}
variable "openstack_password" {}
variable "openstack_auth_url" {}
variable "openstack_availability_zone" {}
variable "openstack_region" {}
variable "openstack_keypair" {}
variable "num_nodes" { default = "2"}
variable "master_image_id" {}
variable "master_instance_size" {}
variable "node_image_id" {}
variable "node_instance_size" {}


provider "openstack" {
    user_name  = "${var.openstack_user_name}"
    tenant_name = "${var.openstack_tenant_name}"
    tenant_id = "${var.openstack_tenant_id}"
    password  = "${var.openstack_password}"
    auth_url  = "${var.openstack_auth_url}"
    endpoint_type = "public"
}

resource "openstack_compute_secgroup_v2" "os3-sec-group" {

  name = "os3-sec-group"
  description = "Defines well-known ports used for OS3 Master and Node deployments"
  rule {
    from_port = 22
    to_port = 22
    ip_protocol = "tcp"
    cidr = "0.0.0.0/0"
  }
  rule {
    from_port = 53
    to_port = 53
    ip_protocol = "tcp"
    cidr = "0.0.0.0/0"
  }
  rule {
    from_port = 80
    to_port = 80
    ip_protocol = "tcp"
    cidr = "0.0.0.0/0"
  }
  rule {
    from_port = 443
    to_port = 443
    ip_protocol = "tcp"
    cidr = "0.0.0.0/0"
  }
  rule {
    from_port = 1936
    to_port = 1936
    ip_protocol = "tcp"
    cidr = "0.0.0.0/0"
  }
  rule {
    from_port = 4001
    to_port = 4001
    ip_protocol = "tcp"
    cidr = "0.0.0.0/0"
  }
  rule {
    from_port = 7001
    to_port = 7001
    ip_protocol = "tcp"
    cidr = "0.0.0.0/0"
  }
  rule {
    from_port = 8443
    to_port = 8444
    ip_protocol = "tcp"
    cidr = "0.0.0.0/0"
  }
  rule {
    from_port = 10250
    to_port = 10250
    ip_protocol = "tcp"
    cidr = "0.0.0.0/0"
  }
  rule {
    from_port = 24224
    to_port = 24224
    ip_protocol = "tcp"
    cidr = "0.0.0.0/0"
  }
  rule {
    from_port = 53
    to_port = 53
    ip_protocol = "udp"
    cidr = "0.0.0.0/0"
  }
  rule {
    from_port = 4789
    to_port = 4789
    ip_protocol = "udp"
    cidr = "0.0.0.0/0"
  }
  rule {
    from_port = 24224
    to_port = 24224
    ip_protocol = "udp"
    cidr = "0.0.0.0/0"
  }
}

resource "openstack_compute_floatingip_v2" "os3-master-floatip" {
  region = "${var.openstack_region}"
  pool = "os1_public"
}

resource "openstack_compute_floatingip_v2" "os3-node-floatip" {
  count = "${var.num_nodes}"
  region = "${var.openstack_region}"
  pool = "os1_public"
}


resource "openstack_blockstorage_volume_v1" "master-docker-vol" {
  name = "mastervol"
  size = 75
}

resource "openstack_blockstorage_volume_v1" "node-docker-vol" {
  count = "${var.num_nodes}"
  name = "${concat("node-docker-vol", count.index)}"
  size = 75
}

resource "openstack_compute_instance_v2" "ose-master" {
  name = "os3-master"
  region = "${var.openstack_region}"
  image_id = "${var.master_image_id}"
  flavor_name = "${var.master_instance_size}"
  availability_zone = "${var.openstack_availability_zone}"
  key_pair = "${var.openstack_keypair}"
  security_groups = ["default", "os3-sec-group"]
  floating_ip = "${openstack_compute_floatingip_v2.os3-master-floatip.address}"
  metadata {
    ssh_user = "cloud-user"
  }
  volume {
    volume_id = "${openstack_blockstorage_volume_v1.master-docker-vol.id}"
  }
}

resource "openstack_compute_instance_v2" "ose-node" {
  count = "${var.num_nodes}"
  name = "${concat("os3-node", count.index)}"
  region = "${var.openstack_region}"
  image_id = "${var.node_image_id}"
  flavor_name = "${var.node_instance_size}"
  availability_zone = "${var.openstack_availability_zone}"
  key_pair = "${var.openstack_keypair}"
  security_groups = ["default", "os3-sec-group"]
  floating_ip = "${element(openstack_compute_floatingip_v2.os3-node-floatip.*.address, count.index)}"
  metadata {
    ssh_user = "cloud-user"
  }
  volume {
    volume_id = "${element(openstack_blockstorage_volume_v1.node-docker-vol.*.id, count.index)}"

  }
}
