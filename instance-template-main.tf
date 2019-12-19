


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

 // Use an existing disk resource
  disk {
    // Instance Templates reference disks by name, not self link
    source      = google_compute_disk.foobar.name
    auto_delete = false
    boot        = false
  }
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


//create instance from template

resource "google_compute_instance_from_template" "tpl" {
  name = "instance-from-template"
  zone = "us-central1-a"

  source_instance_template = google_compute_instance_template.tpl.self_link

  // Override fields from instance template
  can_ip_forward = false
  labels = {
    my_key = "my_value"
  }
}
