
provider "google" {
project = "gce-challange"
  region  = "us-centra11"
  zone    = "us-central1-a"
}

// https://www.terraform.io/docs/providers/google/r/compute_instance.html
resource "google_compute_instance" "my-vm"{
    name = "my-test"
    zone = "us-central1-a"
    machine_type = "n1-standard-1"
#    min_cpu_platform = "defaut" 
//f1-small and g1-small predefined machine types are shared-core general purpose VMs. These will not have the CPU platform selection options
    allow_stopping_for_update = "true"
    enable_display = "false"
    
boot_disk {
 initialize_params {
      image = "debian-cloud/debian-9"
    }
  }
scratch_disk {
interface = "SCSI"
}

// service_account { }

//labels

labels = {
    environment = "dev"
  }

deletion_protection = "true" //to destory you need to unchekc mnaully
 metadata_startup_script = <<-EOF
              #!/bin/bash
     sudo apt get update
     sudo  apt get install apache2 &
     EOF

metadata = {
    complete = "yes"
  }

scheduling {
preemptible = "false"
on_host_maintenance = "MIGRATE"
automatic_restart = "true"
#node_affinities = "name"
}

 network_interface {
    network = "default"

    access_config {
      // Ephemeral IP
    }
  }
can_ip_forward = true

// attached_disk { }
lifecycle {
    ignore_changes = [attached_disk]
  }
}


//https://www.terraform.io/docs/providers/google/r/compute_disk.html
resource "google_compute_disk" "custom-disk" {
  name  = "test-disk"
  type  = "pd-ssd"
  zone  = "us-central1-a"
labels = {
    environment = "dev"
  }
size = 4
physical_block_size_bytes = 4096
}

//attach disk - https://www.terraform.io/docs/providers/google/r/compute_attached_disk.html
resource "google_compute_attached_disk" "default" {
  disk     = google_compute_disk.custom-disk.self_link
  instance = google_compute_instance.my-vm.self_link
}


