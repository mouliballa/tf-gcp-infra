// HEALTH CHECK https://www.terraform.io/docs/providers/google/r/compute_health_check.html

resource "google_compute_health_check" "http" {
  name = "hc-http-80"
  check_interval_sec = 5
  healthy_threshold = 5
  unhealthy_threshold = 2
  timeout_sec = 5
http_health_check {
   //port_name          = "health-check-port"
    // port_specification = "USE_NAMED_PORT"
    //host               = "1.2.3.4"
    request_path       = "/"
    port               = "80"
    proxy_header       = "NONE"
//    proxy_header       = "NONE"
  //  response           = "I AM HEALTHY"
  }
}

data "google_compute_instance_group" "all" {
    name = "ig-a"
    zone = "us-central1-a"
}


// for internal region https://www.terraform.io/docs/providers/google/r/compute_region_backend_service.html#backend
resource "google_compute_region_backend_service" "health" {
  name          = "be-ilb"
  region        = "us-central1"
  protocol = "TCP"
  session_affinity  = "CLIENT_IP"
  health_checks = [google_compute_health_check.http.self_link]
  load_balancing_scheme = "INTERNAL"
backend {
group = "https://compute.googleapis.com/compute/v1/projects/gce-challange/zones/us-central1-a/instanceGroups/ig-a"
}
backend {
group = "https://compute.googleapis.com/compute/v1/projects/gce-challange/zones/us-central1-c/instanceGroups/ig-c"
}
}


// forwarding rules  https://www.terraform.io/docs/providers/google/r/compute_forwarding_rule.html
resource "google_compute_forwarding_rule" "fr-ilb" {
  name                  = "fr-ilb"
  region                = "us-central1"
  load_balancing_scheme = "INTERNAL"
  backend_service       = "${google_compute_region_backend_service.health.self_link}"
  ip_address            = "10.1.2.99"
  ip_protocol           = "TCP"
  ports                 = ["80", "443"]
  network               = "lb-network"
  subnetwork            = "lb-subnet"

}
