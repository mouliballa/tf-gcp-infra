provider "google"{
project = "gce-challange"
region = "us-central1"
zone = "us-central1-a"
}


// firewall rules
resource "google_compute_firewall" "default" {
  name    = "test-firewall"
  network = google_compute_network.vpc_network.name

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["80", "8080", "1000-2000"]
  }

  source_tags = ["web"]
}

// create VPC 
resource "google_compute_network" "vpc_network" {
  name = "vpc-network"
  description = "mycustom vpc"
  auto_create_subnetworks = "false"

}


// https://www.terraform.io/docs/providers/google/r/compute_subnetwork.html
resource "google_compute_subnetwork" "network-with-private-secondary-ip-ranges" {
  name          = "test-subnetwork"
  ip_cidr_range = "10.2.0.0/16"
  region        = "us-central1"
private_ip_google_access = "true"
  log_config    {
aggregation_interval = "INTERVAL_5_SEC"
flow_sampling = "0.5"
metadata = "INCLUDE_ALL_METADATA"
}
  network       = google_compute_network.vpc_network.self_link
  secondary_ip_range {
    range_name    = "tf-test-secondary-range-update1"
    ip_cidr_range = "192.168.10.0/24"
  }
}
 
// reserve internal IP https://www.terraform.io/docs/providers/google/r/compute_address.html
resource "google_compute_address" "internal_with_subnet_and_address" {
  name         = "my-internal-address"
  subnetwork   = google_compute_subnetwork.network-with-private-secondary-ip-ranges.self_link
  address_type = "INTERNAL"
  address      = "10.2.0.42"
  purpose      = "GCE_ENDPOINT"
  region       = "us-central1"
}
// reserver external static iphttps://www.terraform.io/docs/providers/google/r/compute_global_address.html

resource "google_compute_address" "static" {
  name = "ipv4-address"
}

output "staicip" {
value = "google_compute_address.static.address"
}

// image details
data "google_compute_image" "debian_image" {
  family  = "debian-9"
  project = "debian-cloud"
}

// instance details
resource "google_compute_instance" "instance_with_ip" {
  name         = "vm-instance"
  machine_type = "f1-micro"
  zone         = "us-central1-a"

  boot_disk {
    initialize_params {
      image = data.google_compute_image.debian_image.self_link
    }
  }

  network_interface {
    network = "vpc-network" 
    subnetwork   = google_compute_subnetwork.network-with-private-secondary-ip-ranges.self_link
    access_config {
      nat_ip = google_compute_address.static.address #internal_with_subnet_and_address.address
      network_tier = "PREMIUM"
    }
  }
}


resource "google_compute_global_address" "default" {
  name = "global-appserver-ip"
# network = "vpc-network"
network       = "${google_compute_network.vpc_network.self_link}"
 address_type = "INTERNAL"
 purpose = "VPC_PEERING"
 prefix_length = "20"
}
