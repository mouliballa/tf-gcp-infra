// befault the forward rule will assign internal IP to LB ig ip_address specified none so we need to reserve IP 

resource "google_compute_global_address" "my-lb-ip" {
name = "my-lb-ip"
}

// https://www.terraform.io/docs/providers/google/r/compute_target_http_proxy.html
resource "google_compute_target_http_proxy" "my-proxy" {
  name    = "my-proxy"
  url_map = "${google_compute_url_map.my-url-map.self_link}"
}

// https://www.terraform.io/docs/providers/google/r/compute_url_map.html
resource "google_compute_url_map" "my-url-map" {
  name        = "my-url-map"
  description = "url-map description"

  default_service = "https://compute.googleapis.com/compute/v1/projects/gce-challange/global/backendServices/my-backend-service"
}

// https://www.terraform.io/docs/providers/google/r/compute_global_forwarding_rule.html
resource "google_compute_global_forwarding_rule" "my-frontend-service" {
  name       = "my-frontend-service"
  ip_address = "${google_compute_global_address.my-lb-ip.address}"
//  ip_protocol = "HTTP"
  load_balancing_scheme = "EXTERNAL"
  port_range = "80"
  target = "${google_compute_target_http_proxy.my-proxy.self_link}"
}
