resource "google_compute_network" "networking101" {
  name = "networking101"
  description = "networkinglab-101 vpc"
  auto_create_subnetworks = "false"
}

// https://www.terraform.io/docs/providers/google/r/compute_subnetwork.html
resource "google_compute_subnetwork" "asia-east1" {
  name          = "asia-east1"
  ip_cidr_range = "10.40.0.0/16"
  region        = "asia-east1"
    private_ip_google_access = "true"
   log_config    {
   aggregation_interval = "INTERVAL_5_SEC"
   flow_sampling = "0.5"
   metadata = "INCLUDE_ALL_METADATA"
}
network       = google_compute_network.networking101.self_link
}

resource "google_compute_subnetwork" "europe-west1" {
  name          = "europe-west1"
  ip_cidr_range = "10.30.0.0/16"
  region        = "europe-west1"
    private_ip_google_access = "true"
   log_config    {
   aggregation_interval = "INTERVAL_5_SEC"
   flow_sampling = "0.5"
   metadata = "INCLUDE_ALL_METADATA"
}
network       = google_compute_network.networking101.self_link
}

resource "google_compute_subnetwork" "us-east1" {
  name          = "us-east1"
  ip_cidr_range = "10.20.0.0/16"
  region        = "us-east1"
    private_ip_google_access = "true"
   log_config    {
   aggregation_interval = "INTERVAL_5_SEC"
   flow_sampling = "0.5"
   metadata = "INCLUDE_ALL_METADATA"
}
network       = google_compute_network.networking101.self_link
}

resource "google_compute_subnetwork" "us-west1-s1" {
  name          = "us-west1-s1"
  ip_cidr_range = "10.10.0.0/16"
  region        = "us-west1"
    private_ip_google_access = "true"
   log_config    {
   aggregation_interval = "INTERVAL_5_SEC"
   flow_sampling = "0.5"
   metadata = "INCLUDE_ALL_METADATA"
}
network       = google_compute_network.networking101.self_link
}


resource "google_compute_subnetwork" "us-west1-s2" {
  name          = "us-west1-s2"
  ip_cidr_range = "10.11.0.0/16"
  region        = "us-west1"
    private_ip_google_access = "true"
   log_config    {
   aggregation_interval = "INTERVAL_5_SEC"
   flow_sampling = "0.5"
   metadata = "INCLUDE_ALL_METADATA"
}
network       = google_compute_network.networking101.self_link
}

resource "google_compute_instance" "asia1-vm" {
  name = "asia1-vm"
  zone = "asia-east1-b"
  machine_type = "f1-micro"
  tags = ["allow-ssh", "allow-health-check"]
  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-9"
    }
  }

 network_interface {
    network    = "networking101"
    subnetwork =  "asia-east1"
    access_config {
}
  }
metadata_startup_script = <<-EOF
                        #! /bin/bash
                        apt-get update
						apt-get -y install traceroute mtr tcpdump iperf whois host dnsutils siege
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

resource "google_compute_instance" "e1-vm" {
  name = "e1-vm"
  zone = "us-east1-b"
  machine_type = "f1-micro"
  tags = ["allow-ssh", "allow-health-check"]
  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-9"
    }
  }

 network_interface {
    network    = "networking101"
    subnetwork =  "us-east1"
    access_config {
}
  }
metadata_startup_script = <<-EOF
                        #! /bin/bash
                        apt-get update
						apt-get -y install traceroute mtr tcpdump iperf whois host dnsutils siege
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

resource "google_compute_instance" "eu1-vm" {
  name = "eu1-vm"
  zone = "europe-west1-d"
  machine_type = "f1-micro"
  tags = ["allow-ssh", "allow-health-check"]
  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-9"
    }
  }

 network_interface {
    network    = "networking101"
    subnetwork =  "europe-west1"
    access_config {
}
  }
metadata_startup_script = <<-EOF
                        #! /bin/bash
                        apt-get update
						apt-get -y install traceroute mtr tcpdump iperf whois host dnsutils siege
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

resource "google_compute_instance" "w1-vm" {
  name = "w1-vm"
  zone = "us-west1-b"
  machine_type = "f1-micro"
  tags = ["allow-ssh", "allow-health-check"]
  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-9"
    }
  }

 network_interface {
    network    = "networking101"
    subnetwork =  "us-west1-s1"
    access_config {
}
  }
metadata_startup_script = <<-EOF
                        #! /bin/bash
                        apt-get update
						apt-get -y install traceroute mtr tcpdump iperf whois host dnsutils siege
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


resource "google_compute_instance" "w2-vm" {
  name = "w2-vm"
  zone = "us-west1-b"
  machine_type = "f1-micro"
  tags = ["allow-ssh", "allow-health-check"]
  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-9"
    }
  }

 network_interface {
    network    = "networking101"
    subnetwork =  "us-west1-s2"
    network_ip = "10.11.0.100"
    access_config {
}
  }
metadata_startup_script = <<-EOF
                        #! /bin/bash
                        apt-get update
						apt-get -y install traceroute mtr tcpdump iperf whois host dnsutils siege
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

resource "google_compute_firewall" "networking101-allow-internal" {
  name    = "networking101-allow-internal"
  network = google_compute_network.networking101.self_link
  direction = "INGRESS"
  source_ranges = ["10.0.0.0/8"]
  allow {
    protocol = "tcp"
    ports =  ["0-65535"]
  }

 allow {
    protocol = "udp"
    ports    = ["0-65535"]
  }
}

resource "google_compute_firewall" "networking101-allow-ssh" {
  name    = "networking101-allow-ssh"
  network = google_compute_network.networking101.self_link
  direction = "INGRESS"
  source_ranges = ["0.0.0.0/0"]
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

}

resource "google_compute_firewall" "networking101-allow-icmp" {
  name    = "networking101-allow-icmp"
  network = google_compute_network.networking101.self_link
  direction = "INGRESS" 
  source_ranges = ["0.0.0.0/0"]
  allow {
    protocol = "icmp"
  }
}


