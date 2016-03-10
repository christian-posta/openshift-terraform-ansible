variable "gce_access_key" {}
variable "gce_project" {}
variable "master_instance_type" {default = "n1-standard-2"}
variable "node_instance_type" {default = "n1-standard-2"}
variable "gce_availability_zone" {default = "us-east1-b"}
variable "gce_region" {default = "us-east1"}
variable "gce_ami" {default = "centos-7-v20160301"}
variable "num_nodes" { default = "2" }

provider "google" {
    credentials = "${file("account.json")}"
    region = "${var.gce_region}"
    project = "${var.gce_project}"
}

resource "google_compute_instance" "ose-master" {
    name = "master"
    machine_type = "${var.master_instance_type}"
    zone = "${var.gce_availability_zone}"
    disk {
        image = "${var.gce_ami}"
    }
    // Local SSD disk
    disk {
        type = "local-ssd"
        scratch = true
    }

    metadata {
        sshKeys = "${var.gce_access_key}"
    }

    network_interface {
        network = "default"
        access_config {
            // Ephemeral IP
        }
    }
}

resource "google_compute_instance" "ose-node" {
    count = "${var.num_nodes}"
    name = "${concat("node", count.index)}"
    machine_type = "${var.node_instance_type}"
    zone = "${var.gce_availability_zone}"
    disk {
        image = "${var.gce_ami}"
    }
    // Local SSD disk
    disk {
        type = "local-ssd"
        scratch = true
    }

    metadata {
        sshKeys = "${var.gce_access_key}"
    }

    network_interface {
        network = "default"
        access_config {
            // Ephemeral IP
        }
    }
}
