
// Configure the Google Cloud provider

provider "google" {

credentials = "${file("${var.credentials}")}"

project = "${var.gcp_project}" 

region = "${var.region}"

zone    = "${var.zone}"

}

// Create VPC

resource "google_compute_network" "vpc" {

name = "${var.name}-vpc"

auto_create_subnetworks = "false"

}

// Create public Subnet1

resource "google_compute_subnetwork" "subnet1" {

name = "${var.name}-pub-sub1"

ip_cidr_range = "${var.public_subnet1_cidr}"

network = "${var.name}-vpc"

depends_on = [google_compute_network.vpc]

region = "${var.region}"

}

// Create public Subnet2

resource "google_compute_subnetwork" "subnet2" {

name = "${var.name}-pub-sub2"

ip_cidr_range = "${var.public_subnet2_cidr}"

network = "${var.name}-vpc"

depends_on = [google_compute_network.vpc]

region = "${var.region}"

}

// Create private Subnet1

resource "google_compute_subnetwork" "subnet3" {

name = "${var.name}-priv-sub1"

ip_cidr_range = "${var.private_subnet1_cidr}"

network = "${var.name}-vpc"

depends_on = [google_compute_network.vpc]

region = "${var.region}"

}

// Create private Subnet2

resource "google_compute_subnetwork" "subnet4" {

name = "${var.name}-prvi-sub2"

ip_cidr_range = "${var.private_subnet2_cidr}"

network = "${var.name}-vpc"

depends_on = [google_compute_network.vpc]

region = "${var.region}"

}
// VPC firewall configuration

resource "google_compute_firewall" "firewall" {

name = "${var.name}-firewall"

network = "${google_compute_network.vpc.name}"

allow {

protocol = "icmp"

}

allow {

protocol = "tcp"

ports = ["22"]

}
source_ranges = ["0.0.0.0/0","${var.public_subnet1_cidr}", "${var.public_subnet2_cidr}"]

}

resource "google_compute_router" "router" {
  name    = "my-router"
  region = "${var.region}"
  network = "${var.name}-vpc"
}
resource "google_compute_router_nat" "nat_gateway" {
  name   = "my-router-nat"
  router = "my-router"
  region = "${var.region}"

  nat_ip_allocate_option = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"
  subnetwork {
    name                    = "${var.name}-priv-sub1"
    source_ip_ranges_to_nat = ["ALL_IP_RANGES"]
  }
}
// Create Instance in subnet1
resource "google_compute_instance" "instance1" {
    name = "vmpub1"
    machine_type ="n1-standard-1"

    boot_disk {
        initialize_params {
            image = "rhel-6-v20200714"
        }
    }
    network_interface {
        network = "${var.name}-vpc"
        subnetwork = "${var.name}-pub-sub1"
        }
}

// Create Instance in subnet3
resource "google_compute_instance" "instance2" {
    name = "vmprivate1"
    machine_type ="n1-standard-2"
    metadata_startup_script = "startup"
    boot_disk {
        initialize_params {
            image = "rhel-6-v20200714"
        }
    }
    network_interface {
        network = "${var.name}-vpc"
        subnetwork = "${var.name}-priv-sub1"
    }
}
