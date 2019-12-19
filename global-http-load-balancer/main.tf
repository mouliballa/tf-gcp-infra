provider "google"{
project = "gce-challange"
region = "us-central1"
zone = "us-central1-a"
}

resource "google_compute_global_address" "paas-monitor" {
  name = "paas-monitor"
}

resource "google_compute_global_forwarding_rule" "paas-monitor" {
  name       = "paas-monitor-port-80"
  target     = "${google_compute_target_http_proxy.paas-monitor.self_link}"
  ip_address = "${google_compute_global_address.paas-monitor.address}"
  port_range = "80"
  depends_on = ["google_compute_global_address.paas-monitor"]
}

resource "google_compute_target_http_proxy" "paas-monitor" {
  name    = "paas-monitor"
  url_map = "${google_compute_url_map.paas-monitor.self_link}"
}

resource "google_compute_url_map" "paas-monitor" {
  name        = "paas-monitor"
  description = "paas-monitor description"

  default_service = "${google_compute_backend_service.paas-monitor.self_link}"
}

resource "google_compute_backend_service" "paas-monitor" {
  name             = "paas-monitor-backend"
  description      = "region backend"
  protocol         = "HTTP"
  port_name        = "paas-monitor"
  timeout_sec      = 10
  session_affinity = "NONE"

  backend {
    group = "${module.instance-group-region-a.instance_group_manager}"
  }

  backend {
    group = "${module.instance-group-region-b.instance_group_manager}"
  }

  backend {
    group = "${module.instance-group-region-c.instance_group_manager}"
  }

  health_checks = ["${module.instance-group-region-a.health_check}"]
}

module "instance-group-region-a" {
  source = "./backend"
  region = "us-central1"
}

module "instance-group-region-b" {
  source = "./backend"
  region = "europe-west4"
}

module "instance-group-region-c" {
  source = "./backend"
  region = "asia-east1"
}

resource "google_compute_firewall" "paas-monitor" {
  ## firewall rules enabling the load balancer health checks
  name    = "paas-monitor-firewall"
  network = "default"

  description = "allow Google health checks and network load balancers access"

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["1337"]
  }

  source_ranges = ["35.191.0.0/16", "130.211.0.0/22", "209.85.152.0/22", "209.85.204.0/22"]
  target_tags   = ["paas-monitor"]
}

//dns config
resource "google_dns_managed_zone" "tld" {
  name        = "paas-monitor-tld"
  dns_name    = "${var.domain-name}."
  description = "top level domain name for the paas-monitor ${var.domain-name}"
}

output "tld-name-servers" {
  value = "${google_dns_managed_zone.tld.name_servers}"
} 

resource "google_dns_record_set" "paas-monitor" {
  name = "paas-monitor.${google_dns_managed_zone.tld.dns_name}"
  type = "A"
  ttl  = 300

  managed_zone = "${google_dns_managed_zone.tld.name}"

  rrdatas = ["${google_compute_global_address.paas-monitor.address}"]
}

output "ip-address" {
    value = "${google_compute_global_address.paas-monitor.address}"
}



