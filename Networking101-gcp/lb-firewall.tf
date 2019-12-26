// elements of an HTTP/HTTPS load balancer setup
// Add an HTTP firewalling rule allowing network access to the Backend VM instances
// Create Managed Instance Groups with the VM instance configurations
// Create the HTTP Load Balancer with backends to route requests to available instances

// Add an HTTP Firewall rule
resource "google_compute_firewall" "nw101-allow-http" {
  name    = "nw101-allow-http"
  network = google_compute_network.networking101.self_link
  direction = "INGRESS"
  source_ranges = ["0.0.0.0/0"]
  target_tags = ["http-server"]
  allow {
    protocol = "tcp"
    ports =  ["80"]
  }
}

