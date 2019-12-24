
provider "google"{
project = "gce-challange"
region = "us-central1"
zone = "us-central1-a"
}

// this is the setup for https://cloud.google.com/load-balancing/docs/internal/setting-up-internal

resource "google_compute_network" "vpc_network" {
  name = "lb-network"
  description = "mycustom vpc"
  auto_create_subnetworks = "false"
}

// https://www.terraform.io/docs/providers/google/r/compute_subnetwork.html
resource "google_compute_subnetwork" "vpc-subnet" {
  name          = "lb-subnet"
  ip_cidr_range = "10.1.2.0/24"
  region        = "us-central1"
private_ip_google_access = "true"
  log_config    {
aggregation_interval = "INTERVAL_5_SEC"
flow_sampling = "0.5"
metadata = "INCLUDE_ALL_METADATA"
}
network       = google_compute_network.vpc_network.self_link
}


// firewall rules
resource "google_compute_firewall" "vpc-firewall1" {
  name    = "fw-allow-lb-subnet"
  network = google_compute_network.vpc_network.name
  direction = "INGRESS"
  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

  allow {
    protocol = "udp"
}

source_ranges = ["10.1.2.0/24"]

}

resource "google_compute_firewall" "vpc-firewall2" {
  name    = "fw-allow-ssh"
  network = google_compute_network.vpc_network.name
  direction = "INGRESS"
   allow {
    protocol = "tcp"
    ports    = ["22"]
  }

}

resource "google_compute_firewall" "vpc-firewall3" {
  name    = "fw-allow-health-check"
  network = google_compute_network.vpc_network.name
  direction = "INGRESS"
  target_tags = ["allow-health-check"]
  source_ranges = ["130.211.0.0/22", "35.191.0.0/16"]
  allow {
    protocol = "tcp"
  }

 allow {
    protocol = "udp"
  }

allow {
    protocol = "icmp"
  }
}

// create instance

resource "google_compute_instance" "vm-a" {
  count = 2
  zone = "us-central1-a"
  name = "vm-a${count.index}"
  machine_type = "f1-micro"
  tags = ["allow-ssh", "allow-health-check"]
  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-9"
    }
  }

 network_interface {
    subnetwork    = "${google_compute_subnetwork.vpc-subnet.self_link}"
    access_config {
}
  }
metadata_startup_script = <<-EOF
                        #! /bin/bash
			apt-get update
			apt-get install apache2 -y
			a2ensite default-ssl
			a2enmod ssl
			vm_hostname="$(curl -H "Metadata-Flavor:Google" \
						http://169.254.169.254/computeMetadata/v1/instance/name)"
			echo "Page served from: $vm_hostname" | \
						tee /var/www/html/index.html
			systemctl restart apache2
			EOF

}


resource "google_compute_instance" "vm-c" {
  count = 2
  name = "vm-c${count.index}"
  zone = "us-central1-c"
  machine_type = "f1-micro"
  tags = ["allow-ssh", "allow-health-check"]
  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-9"
    }
  }


 network_interface {
    subnetwork    = "${google_compute_subnetwork.vpc-subnet.self_link}"
    access_config {
}
  }
metadata_startup_script = <<-EOF
	#! /bin/bash
	apt-get update
	apt-get install apache2 -y
	a2ensite default-ssl
	a2enmod ssl
	vm_hostname="$(curl -H "Metadata-Flavor:Google" \
		http://169.254.169.254/computeMetadata/v1/instance/name)"
	echo "Page served from: $vm_hostname" | \
		tee /var/www/html/index.html
	systemctl restart apache2
	EOF

}

variable "instances_count" {
  type        = number
  description = "The id of the machine image (AMI) to use for the server."
  default = "2"
}

/// instance group -- need to update instances manually here 
resource "google_compute_instance_group" "ig-a" {
  name        = "ig-a"
  description = "Terraform test instance group"
  zone = "us-central1-a"
#  count= 1  
//  instances =  ["vm-a1", "vm-a0"]
//    google_compute_instance.appserver.name.self_link
//    "google_compute_instance.vm-a1" 
//$ar.instances_count.index
}


resource "google_compute_instance_group" "ig-c" {
  name        = "ig-c"
  description = "Terraform test instance group"
  zone = "us-central1-c"
#  count = 1

//  instances = ["vm-c1", "vm-c0"]
//    google_compute_instance.vm-c[count.index].self_link
//   "google_compute_instance.vm-c1"

}

//vm-client
resource "google_compute_instance" "vm-client" {
  name         = "vm-client"
  machine_type = "f1-micro"
  zone         = "us-central1-a"
  tags = ["allow-ssh"]

  boot_disk {
    	initialize_params {
      	image = "debian-cloud/debian-9"
    }
  }

  network_interface {
//    network = "lb-network" 
    subnetwork   = "lb-subnet"
    access_config {
      
    }
  }
}
