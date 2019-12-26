// https://www.terraform.io/docs/providers/template/d/file.html
data "template_file" "user_data" {  
template = file("./startup.sh")
}
// lifeycle block nstance Templates cannot be updated after creation with the Google Cloud Platform API. In order to update an Instance Template, Terraform will destroy the existing resource and create a replacement. In order to effectively use an Instance Template resource with an Instance Group Manager resource, it's recommended to specify create_before_destroy in a lifecycle block. Either omit the Instance Template name attribute, or specify a partial name with name_prefix
resource "google_compute_instance_template" "europe-west1-template" {
  name_prefix  = "europe-west1-"
  description = "This template is used to create servers in europe-west1"
  region = "us-east1"
  instance_description = "description assigned to instances"
  machine_type         = "f1-micro"
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
  network_interface {
    network = "default"
//	subnetwork = "europe-west1"
  access_config {
}
  }
  tags = ["http-server"]
   metadata = {
    startup-script = data.template_file.user_data.rendered
// gs://networking101-lab/startup.sh
  }
lifecycle {
    create_before_destroy = true
  }
}

resource "google_compute_instance_template" "us-east1-template" {
  name_prefix     = "us-east1-"
  description = "This template is used to create servers in us-east1."
  region = "europe-east1"
  instance_description = "description assigned to instances"
  machine_type         = "f1-micro"
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
  network_interface {
    network = "default"
//    subnetwork = "us-east1"
access_config {
}
}
  tags = ["http-server"]
   metadata = {
   startup-script = data.template_file.user_data.rendered
// gs://networking101-lab/startup.sh
  }
lifecycle {
    create_before_destroy = true
  }
}



//regional Managed Instance Groups
//https://www.terraform.io/docs/providers/google/r/compute_region_autoscaler.html 
resource "google_compute_region_autoscaler" "us-east1-autoscaler" {
    region = "us-east1"
    name   = "us-east1-autoscaler"
    target = google_compute_region_instance_group_manager.us-east1-mig.self_link
  autoscaling_policy {
    max_replicas    = 5
    min_replicas    = 1
    cooldown_period = 60
	load_balancing_utilization {
	 target = "0.8"
	 } 
    }
  }

// regiional instnace  group manager
resource "google_compute_region_instance_group_manager" "us-east1-mig" {
  name               = "us-east1-mig"
  region             = "us-east1"
  base_instance_name = "us-east1-mig"
version {
instance_template  = google_compute_instance_template.us-east1-template.self_link
}
}

resource "google_compute_region_autoscaler" "europe-west1-autoscaler" {
    region = "europe-west1"
    name   = "europe-west1-autoscaler"
    target = google_compute_region_instance_group_manager.europe-west1-mig.self_link
  autoscaling_policy {
    max_replicas    = 5
    min_replicas    = 1
    cooldown_period = 60
        load_balancing_utilization {
         target = "0.8"
         }
    }
  }
  
  resource "google_compute_region_instance_group_manager" "europe-west1-mig" {
  name               = "europe-west1-mig"
  region             = "europe-west1"
  base_instance_name = "europe-west1-mig"
version {
instance_template  = google_compute_instance_template.europe-west1-template.self_link
}
}
//   target_pools = [google_compute_target_pool.foo.self_link]


