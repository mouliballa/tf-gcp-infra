


provider "google" {
  project     = "gce-challange"
  region      = "us-central1"
  zone        = "us-central1-a"
}

resource "google_compute_instance_template" "tpl" {
name        = "appserver-template"
description = "This template is used to create app server instances."
tags = ["foo", "bar"]
labels = {
    environment = "dev"
  }

instance_description = "description assigned to instances"
  machine_type         = "f1-micro"
  can_ip_forward       = false

  scheduling {
    automatic_restart   = true
    on_host_maintenance = "MIGRATE"
}

// Create a new boot disk from an image
  disk {
    source_image = "debian-cloud/debian-9"
    auto_delete  = true
    boot         = true
  }
/*
 // Use an existing disk resource
  disk {
    // Instance Templates reference disks by name, not self link
    source      = google_compute_disk.foobar.name
    auto_delete = false
    boot        = false
  } */
network_interface {
    network = "default"
  }
lifecycle {
    create_before_destroy = true
  }
  metadata = {
   test  = "yes"
  }
  service_account {
    scopes = ["cloud-platform"]
  }
}


data "google_compute_image" "my_image" {
  family  = "debian-9"
  project = "debian-cloud"
}

 resource "google_compute_disk" "foobar" {
  name  = "existing-disk"
  image = data.google_compute_image.my_image.self_link
  size  = 10
  type  = "pd-ssd"
  zone  = "us-central1-a"
}


//create instance group from template
//The Google Compute Engine Instance Group Manager API creates and manages pools of Compute Engine virtual machine instances from a common instance template.

resource "google_compute_health_check" "autohealing" {
  name                = "autohealing-health-check"
  check_interval_sec  = 5
  timeout_sec         = 5
  healthy_threshold   = 2
  unhealthy_threshold = 10 # 50 seconds

  http_health_check {
#    request_path = "/healthz"
    port         = "80"
  }
}

resource "google_compute_instance_group_manager" "test-group" {
  name = "appserver-template-group"
  base_instance_name = "app"
  zone               = "us-central1-a"

  version {
    instance_template  = google_compute_instance_template.tpl.self_link
  }

#  target_pools = [google_compute_target_pool.tpl.self_link]
  target_size  = 2

  named_port {
    name = "customhttp"
    port = 80
  }
lifecycle {
    create_before_destroy = true
  }
  auto_healing_policies {
    health_check      = google_compute_health_check.autohealing.self_link
    initial_delay_sec = 300
  }
}

