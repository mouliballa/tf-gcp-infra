
provider "google" {
project = "gce-challange"
  region  = "us-centra11"
  zone    = "us-central1-a"
}

// REFERRENCE LINK- https://github.com/terraform-providers/terraform-provider-google/issues/2122
// https://www.terraform.io/docs/providers/google/r/compute_instance_template.html
resource "google_compute_instance_template" "my-template" {
     name        = "appserver-template"
     description = "This template is used to create app server instances."
     machine_type         = "n1-standard-1"
#    min_cpu_platform = "default"
  #   allow_stopping_for_update = "true"
     enable_display = "false"
// boot_disk - not supported

  disk {
    source_image = "debian-cloud/debian-9"
    auto_delete  = true
    boot         = true
  }
// scratch_disk-not supported

// service_account { }

//labels

labels = {
    environment = "dev"
  }

scheduling {
preemptible = "false"
on_host_maintenance = "MIGRATE"
automatic_restart = "true"
#node_affinities = "name"
}

//  deletion_protection - not supported for template
 metadata_startup_script = <<-EOF
              #!/bin/bash
     sudo apt get update
     sudo  apt get install apache2 &
     EOF

metadata = {
    complete = "yes"
  }
network_interface {
    network = "default"

    access_config {
      // Ephemeral IP
    }
  }
 can_ip_forward = "true"

// attached_disk { }
lifecycle {
create_before_destroy = true
  }
}

//https://www.terraform.io/docs/providers/google/r/compute_disk.html
resource "google_compute_disk" "custom-disk" {
  count     = "2"
  name  = "test-disk${count.index}"
  type  = "pd-ssd"
  zone  = "us-central1-a"
labels = {
    environment = "dev"
  }
size = 4
physical_block_size_bytes = 4096
}

resource "google_compute_instance_from_template" "member" {
  count           = "2"
  name            = "my-vm${count.index}"
  zone            = "us-central1-a"
  description     = "A replica set member"

  source_instance_template = "${google_compute_instance_template.my-template.self_link}"

  // Override fields from instance template
  
  attached_disk {
  source      = "${google_compute_disk.custom-disk.*.self_link[count.index]}"
  }
}


