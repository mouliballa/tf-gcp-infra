//Backend configuration
resource "google_compute_health_check" "my-http-hc" {
  name = "my-http-hc"
  check_interval_sec = 5
  healthy_threshold = 2
  unhealthy_threshold = 2
  timeout_sec = 5
http_health_check {
    request_path       = "/"
    port               = "80"
    proxy_header       = "NONE"
  }
}

//https://www.terraform.io/docs/providers/google/r/compute_backend_service.html
resource "google_compute_backend_service" "my-backend-service" {
 name = "my-backend-service"
 description      = "region backend"
  protocol         = "HTTP"
  port_name        = "http"
  timeout_sec      = 30
  session_affinity = "NONE"

  backend {
    balancing_mode = "RATE"
    max_rate_per_instance = 50
    capacity_scaler = 1
// REF LINK FOR APIS https://cloud.google.com/compute/docs/reference/rest/v1/
    group = "https://compute.googleapis.com/compute/v1/projects/gce-challange/regions/europe-west1/instanceGroups/europe-west1-mig"
  }
  
  backend {
  balancing_mode = "RATE"
    max_rate_per_instance = 50
    capacity_scaler = 1
    group = "https://compute.googleapis.com/compute/v1/projects/gce-challange/regions/us-east1/instanceGroups/us-east1-mig"
  }
  health_checks = [google_compute_health_check.my-http-hc.self_link]
}
