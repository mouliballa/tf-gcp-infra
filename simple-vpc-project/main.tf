resource "google_compute_network" "auto_network" {
  name = "auto-network"
}

resource "google_compute_network" "vpc-prod" {
  name = "prod-network"
  description = "mycustom vpc"
  auto_create_subnetworks = "false"
}

// https://www.terraform.io/docs/providers/google/r/compute_subnetwork.html
resource "google_compute_subnetwork" "prod-subnet1" {
  name          = "prod-subnet1"
  ip_cidr_range = "10.10.1.0/24"
  region        = "us-central1"
    private_ip_google_access = "true"
   log_config    {
   aggregation_interval = "INTERVAL_5_SEC"
   flow_sampling = "0.5"
   metadata = "INCLUDE_ALL_METADATA"
}
network       = google_compute_network.vpc-prod.self_link
}

resource "google_compute_subnetwork" "prod-subnet2" {
  name          = "prod-subnet2"
  ip_cidr_range = "10.10.2.0/24"
  region        = "us-central1"
    private_ip_google_access = "true"
   log_config    {
   aggregation_interval = "INTERVAL_5_SEC"
   flow_sampling = "0.5"
   metadata = "INCLUDE_ALL_METADATA"
}
network       = google_compute_network.vpc-prod.self_link
}

resource "google_compute_subnetwork" "prod-subnet3" {
  name          = "prod-subnet3"
  ip_cidr_range = "10.11.1.0/24"
  region        = "us-west1"
    private_ip_google_access = "true"
   log_config    {
   aggregation_interval = "INTERVAL_5_SEC"
   flow_sampling = "0.5"
   metadata = "INCLUDE_ALL_METADATA"
}
network       = google_compute_network.vpc-prod.self_link
}


resource "google_compute_instance" "pvm1" {
  name = "pvm1"
  zone = "us-central1-a"
  machine_type = "f1-micro"
  tags = ["allow-ssh", "allow-health-check"]
  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-9"
    }
  }

 network_interface {
    network    = "prod-network" 
    subnetwork =  "prod-subnet1"
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


resource "google_compute_instance" "pvm2" {
  name = "pvm2"
  zone = "us-central1-b"
  machine_type = "f1-micro"
  tags = ["allow-ssh", "allow-health-check"]
  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-9"
    }
  }

 network_interface {
    network    = "prod-network" 
    subnetwork =  "prod-subnet2"
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

resource "google_compute_instance" "pvm3" {
  name = "pvm3"
  zone = "us-west1-a"
  machine_type = "f1-micro"
  tags = ["allow-ssh", "allow-health-check"]
  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-9"
    }
  }

 network_interface {
    network    = "prod-network" 
    subnetwork =  "prod-subnet3"
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

resource "google_compute_instance" "tvm4" {
  name = "tvm4"
  zone = "us-central1-a"
  machine_type = "f1-micro"
  tags = ["allow-ssh", "allow-health-check"]
  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-9"
    }
  }

 network_interface {
    network    = "auto-network" 
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

resource "google_compute_instance" "dvm5" {
  name = "dvm5"
  zone = "us-central1-a"
  machine_type = "f1-micro"
  tags = ["allow-ssh", "allow-health-check"]
  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-9"
    }
  }

 network_interface {
    network    = "default" 
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


// allow ping from test to prod

resource "google_compute_firewall" "prodvpc-firewall" {
  name    = "prod-to-default"
  network = google_compute_network.vpc-prod.name
  direction = "INGRESS"
  target_tags = ["allow-health-check"]
  source_ranges = ["0.0.0.0/0"]
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
// internal IPs are not resolved becasue they are in different network

// for bastion host remove IP from any prod instance and try to treat any machine asbastion host and try to access
